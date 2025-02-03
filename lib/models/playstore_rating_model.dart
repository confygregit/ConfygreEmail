import 'package:objectbox/objectbox.dart';

@Entity()
class PlaystoreRatingModel {
  int id;
  bool neverShowAgain;
  int showAtCount;
  String dateIfNot;

  PlaystoreRatingModel({
    this.id = 0,
    required this.neverShowAgain,
    required this.showAtCount,
    required this.dateIfNot,
  });
}