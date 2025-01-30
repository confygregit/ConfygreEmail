import 'package:objectbox/objectbox.dart';

@Entity()
class ComponentsCacheModel {
  int id;
  bool introductionScreen;

  ComponentsCacheModel({
    this.id = 0,
    required this.introductionScreen
  });
}