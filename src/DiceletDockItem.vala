using Plank;
using Cairo;
using Linux;

namespace Dicelet {

	protected List<Die> dice;


	public class DiceletDockItem : DockletItem {

		protected List<Die> dice;

		protected List<DiceCup> dicecups;

		protected int current_set;

		Gdk.Pixbuf icon_pixbuf;

		DiceletPreferences prefs;

		protected int sum = 0;


		public DiceletDockItem.with_dockitem_file(GLib.File file) {
			GLib.Object(Prefs: new DiceletPreferences.with_file(file));
		}


		/* Constructor */
		construct {

			// Init Logger (logsto console, Do `killall plank ; sudo plank` in terminal` to see the log
			Logger.initialize("dicelet");
			Logger.DisplayLevel = LogLevel.NOTIFY;

			dicecups = new List<DiceCup>();

			dicecups.append(new DiceCup({4}));
			dicecups.append(new DiceCup({6}));
			dicecups.append(new DiceCup({6, 6}));
			dicecups.append(new DiceCup({3, 2, 3, 7, 7, 1, 2, 2}));
			dicecups.append(new DiceCup({8}));
			dicecups.append(new DiceCup({10}));
			dicecups.append(new DiceCup({12}));
			dicecups.append(new DiceCup({20}));
			current_set = 1;



			// Get preferences (Where do we set them?? They are not in gsettings!!
			prefs = (DiceletPreferences) Prefs;

			// Set Icon and Text (Tooltip);
			Icon = "resource://" + Dicelet.G_RESOURCE_PATH + "/icons/icon_red.png";
			Text = "Roll a dice";

			// Load icons, TODO: Draw the icons with cairo, 
			// like here: https://github.com/ricotz/plank/blob/20c16a0b6a9da41b12524b0208efa13bc6762826/docklets/CPUMonitor/CPUMonitorDockItem.vala#L124
			try {
				icon_pixbuf= new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/dice.svg");
			}
			catch (Error e) {
				warning("Error: " + e.message);
			}
		}


		/* Destructor */
		~DiceletDockItem () {
		}




		/**
		 * Draw the icon
		 *
		 * @param Plank.Surface 		Cairo surface to draw upon
		 * @return void
		 */
		protected override void draw_icon(Plank.Surface surface) {

			Cairo.Context ctx = surface.Context;
			Gdk.Pixbuf pb;

			pb = icon_pixbuf.scale_simple(surface.Width, surface.Height,
										  Gdk.InterpType.BILINEAR);
			Gdk.cairo_set_source_pixbuf(ctx, pb, 0, 0);
			ctx.paint();

			ctx.set_source_rgb(1.0, 1.0, 1.0);
			ctx.select_font_face("Roboto", Cairo.FontSlant.NORMAL,
								 Cairo.FontWeight.BOLD);
			ctx.set_font_size(12);
			ctx.move_to(10, 30);
			var dicecup = dicecups.nth_data(current_set);
			ctx.show_text("%s: %u".printf(dicecup.to_string(), sum));

		}



		protected void roll() {

			var dicecup = this.dicecups.nth_data(this.current_set);
			sum = dicecup.roll();
		}


		/**
		 * Callback for when the icon gets clicked
		 *
		 * @param PopupButton
		 * @param Gdk.ModifierType
		 * @param uint32
		 * @return AnimationType
		 */
		protected override AnimationType on_clicked(PopupButton button, Gdk.ModifierType mod, uint32 event_time) {

			if (button == PopupButton.LEFT) {

				roll();
				Logger.notification("Rolled a %s, result (sum): %u".printf(dicecups.nth_data(current_set).to_string(), sum));

				return AnimationType.BOUNCE;
			}
			return AnimationType.NONE;
		}



		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();
			for (int i = 0; i < dicecups.length(); i++) {
				var dicecup = dicecups.nth_data(i);
				string str = dicecup.to_string();
				int n = i;

				var item = create_literal_menu_item(str);
				item.activate.connect(() => {
					this.current_set = n;
					Logger.notification ("Current set: %u: %s".printf(this.current_set, this.dicecups.nth_data(this.current_set).to_string()));
					reset_icon_buffer();
				});
				items.add(item);
			}

			return items;
		}
	}
}
