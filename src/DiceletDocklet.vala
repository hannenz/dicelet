/**
 * DiceletDocklet
 *
 * @author Johannes Braun <johannes.braun@hannenz.de>
 * @package dicelet
 * @version 2020-11-13
 */

public static void docklet_init(Plank.DockletManager manager) {
	manager.register_docklet(typeof(Dicelet.DiceletDocklet));
}

namespace Dicelet {

	/**
	 * Resource path for the icon
	 */
	public const string G_RESOURCE_PATH = "/de/hannenz/dicelet";


	public class DiceletDocklet : Object, Plank.Docklet {

		public unowned string get_id() {
			return "dicelet";
		}

		public unowned string get_name() {
			return "Dicelet";
		}

		public unowned string get_description() {
			return "Roll a dice right from the dock";
		}

		public unowned string get_icon() {
			return "resource://" + Dicelet.G_RESOURCE_PATH + "/data/dice.svg";
		}

		public bool is_supported() {
			return false;
		}

		public Plank.DockElement make_element(string launcher, GLib.File file) {
			return new DiceletDockItem.with_dockitem_file(file);
		}
	}
}
