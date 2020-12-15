using Plank;

namespace Dicelet {

	public class DiceCup {

		/**
		 * List of dice in the cup;
		 */
		public List<Die> dice;
		
		/**
		 * @var int
		 * Sum of all dice in the cup
		 */
		public int sum;


		public DiceCup(int[] faces) {

			sum = 0;
			dice = new List<Die>();

			for (int i = 0; i < faces.length; i++) {
				dice.insert_sorted(new Die(faces[i]), (a, b) => {
					if (a.n_faces == b.n_faces) {
						return 0;
					}
					return a.n_faces > b.n_faces ? 1 : -1;
				});
			}
		}


		public int roll() {
			sum = 0;
			foreach (Die die in dice) {
				sum += die.roll();
			}
			return sum;
		}


		public string to_string() {
			string str = "";
			int n = 0, f = 0;
			foreach (Die die in this.dice) {
				if (f > 0 && f != die.n_faces) {
					str += "%uD%u + ".printf(n, f);
					f = die.n_faces;
					n = 1;
				}
				else {
					f = die.n_faces;
					n++;
				}
			}
			str += "%uD%u".printf(n, f);
			return str;
		}
	}
}
