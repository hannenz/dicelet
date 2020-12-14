namespace Dicelet {

	/**
	 * Class that represents a single die
	 */
	public class Die {

		/**
		 * @var int 	n_faces, nr of faces of this dice
		 */
		public int n_faces {get; set;}

		/**
		 * @var int 	Result of theh last roll
		 */
		public int last_roll {get; set; }


		public Die(int n_faces) {
			this.n_faces = n_faces; 
			this.last_roll = 0;
		}


		/**
		 * Roll a dice
		 *
		 * @return int 		The result of the dice's roll
		 */
		public int roll() {
			last_roll = Random.int_range(1, this.n_faces + 1);
			return last_roll;
		}
	}
}
