import 'package:ringfit_titles_counter/ringfit_title.dart';

class TitleAchievement {
  TitleAchievement(this.title, this.name, this.total, this.progress);

  RingfitTitle title;
  String name;
  int total;
  int progress;

  double get rating {
    var value = 0.0;
    if (title.rank1 <= progress) {
      value = 1;
      if (title.rank2 <= progress) {
        value = 2;
        if (title.rank3 <= progress) {
          value = 3;
          if (title.rank4 <= progress) {
            value = 4;
          } else {
            // ４の途中
            value += (progress - title.rank3)/(title.rank4 - title.rank3);
          }
        } else {
          // ３の途中
          value += (progress - title.rank2)/(title.rank3 - title.rank2);
        }
      } else {
        // ２の途中
        value += (progress - title.rank1)/(title.rank2 - title.rank1);
      }
    } else {
      // １の途中
      value += progress/title.rank1;
    }
    return value;
  }
}