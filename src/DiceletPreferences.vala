using Plank;

namespace Dicelet {

	public class DiceletPreferences : DockItemPreferences {

		public DiceletPreferences.with_file(GLib.File file) {
			base.with_file(file);
		}

		protected override void reset_properties() {
		}
	}
}
