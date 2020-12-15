using Plank;
using Cairo;
using Linux;

namespace Dicelet {



	public class DiceletDockItem : DockletItem {

		protected List<DiceCup> dicecups;

		protected int current_set;

		// Gdk.Pixbuf icon_pixbuf;

		DiceletPreferences prefs;

		protected int sum = 0;

		Gee.HashMap<string, Gdk.Pixbuf> icons;


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
			dicecups.append(new DiceCup({8}));
			dicecups.append(new DiceCup({10}));
			dicecups.append(new DiceCup({12}));
			dicecups.append(new DiceCup({20}));
			dicecups.append(new DiceCup({100}));
			current_set = 1;

			// Load icons
			Gdk.Pixbuf icon;
			icons = new Gee.HashMap<string, Gdk.Pixbuf>();

			try {
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/dice.svg");
				icons.set("default", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d4.svg");
				icons.set("1D4", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d6.svg");
				icons.set("1D6", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d8.svg");
				icons.set("1D8", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d10.svg");
				icons.set("1D10", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d12.svg");
				icons.set("1D12", icon);
				icon = new Gdk.Pixbuf.from_resource(Dicelet.G_RESOURCE_PATH + "/data/1d20.svg");
				icons.set("1D20", icon);
			}
			catch (Error e) {
				warning("Error: " + e.message);
			}


			// Get preferences (Where do we set them?? They are not in gsettings!!
			prefs = (DiceletPreferences) Prefs;

			// Set Icon and Text (Tooltip);
			Icon = "resource://" + Dicelet.G_RESOURCE_PATH + "/icons/icon_red.png";
			Text = "Roll a dice";
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

			string cupname;
			var dicecup = dicecups.nth_data(current_set);
			cupname = dicecup.to_string();

			Cairo.Context ctx = surface.Context;
			Gdk.Pixbuf pb;

			var icon = icons[cupname];
			if (icon == null) {
				icon = icons["default"];
			}

			pb = icon.scale_simple(surface.Width, surface.Height, Gdk.InterpType.BILINEAR);
			Gdk.cairo_set_source_pixbuf(ctx, pb, 0, 0);
			ctx.paint();

			if (sum == 0) {
				return;
			}

			ctx.set_source_rgba(0, 0, 0, 0.5);
			ctx.new_path();
			ctx.rectangle(10, 10, surface.Width - 20, surface.Height - 10);
			ctx.fill();

			ctx.set_source_rgb(1.0, 1.0, 1.0);
			ctx.select_font_face("Roboto", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
			ctx.set_font_size(26);

			var text = "%u".printf(sum);
			Cairo.TextExtents extents;
			ctx.text_extents(text, out extents);

			double x = (surface.Width / 2) - (extents.width / 2 + extents.x_bearing);
			double y = (surface.Height / 2) - (extents.height / 2 + extents.y_bearing);

			ctx.move_to(x, y);
			ctx.show_text(text);

			ctx.select_font_face("Roboto", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
			ctx.set_font_size(9);
			ctx.text_extents(cupname, out extents);

			x = (surface.Width / 2) - (extents.width / 2 + extents.x_bearing);
			y += 8;
			ctx.move_to(x, y);
			ctx.show_text(cupname);
		}



		/**
		 * Roll that dice :-)
		 */
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
				reset_icon_buffer();
				return AnimationType.BOUNCE;
			}
			return AnimationType.NONE;
		}



		/**
		 * Populate context menu
		 *
		 * @return Gee.ArrayList
		 */ 
		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();
			for (int i = 0; i < dicecups.length(); i++) {
				var dicecup = dicecups.nth_data(i);
				string str = "%s%s".printf(i == this.current_set ? "✓ " : "  ", dicecup.to_string());
				int n = i;

				var item = create_literal_menu_item(str);
				item.activate.connect(() => {
					this.current_set = n;
					this.sum = 0;
					reset_icon_buffer();
				});
				items.add(item);
			}

			return items;
		}
	}
}
