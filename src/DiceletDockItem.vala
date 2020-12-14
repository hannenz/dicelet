using Plank;
using Cairo;
using Linux;

namespace Dicelet {

	protected List<Die> dice;


	public class DiceSet {

		public List<Die> dice;

		public DiceSet(int[] faces) {
			dice = new List<Die>();
			for (int i = 0; i < faces.length; i++) {
				dice.append(new Die(faces[i]));
			}
		}

		public string to_string() {
			string str = "";
			foreach (Die die in this.dice) {
				str += ", D%u".printf(die.n_faces);
			}
			return str;
		}
	}



	public class DiceletDockItem : DockletItem {

		protected List<Die> dice;

		protected List<DiceSet> dicesets;

		protected int current_set;

		Gdk.Pixbuf icon_pixbuf;

		DiceletPreferences prefs;

	

		protected int sum = 0;


		public DiceletDockItem.with_dockitem_file(GLib.File file) {
			GLib.Object(Prefs: new DiceletPreferences.with_file(file));
		}


		/* Constructor */
		construct {
			dicesets = new List<DiceSet>();
			dicesets.append(new DiceSet({4}));
			dicesets.append(new DiceSet({6}));
			dicesets.append(new DiceSet({8}));
			dicesets.append(new DiceSet({10}));
			dicesets.append(new DiceSet({12}));
			dicesets.append(new DiceSet({20}));
			current_set = 1;

			// Init Logger (logsto console, Do `killall plank ; sudo plank` in terminal` to see the log
			Logger.initialize("dicelet");
			Logger.DisplayLevel = LogLevel.NOTIFY;

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
			// var diceset = dicesets.nth_data(current_set);
			// ctx.show_text("%uD%u".printf(diceset.n_dice, diceset.n_faces));

		}



		protected void roll() {

			sum = 0;
			var diceset = this.dicesets.nth_data(this.current_set);
			foreach(Die die in diceset.dice) {
				var result = die.roll();
				Logger.notification("Let me tell you: %u".printf(result));
				sum += result;
			}
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
				Logger.notification("Rolled a %u".printf(sum));

				return AnimationType.BOUNCE;
			}
			return AnimationType.NONE;
		}



		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();
			for (int i = 0; i < dicesets.length(); i++) {
				var diceset = dicesets.nth_data(i);
				string str = diceset.to_string();

				var item = create_literal_menu_item(str);
				item.activate.connect(() => {
					Logger.notification ("Current: %u".printf(i));
					current_set = i;
					reset_icon_buffer();
				});
				items.add(item);
			}

			return items;
		}
	}
}
