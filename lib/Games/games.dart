abstract class Games {

}

class Table implements Games {
  int sixMax = 6;
  int fullTable = 9;
  int players = 0;

  int setTable(int players) {
    if (players > 10) {
      return players;
    }
    return null;
  }

  int getTable() {
    return players;
  }


}