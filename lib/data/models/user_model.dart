import 'package:hive_ce/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  double currentWeight;

  @HiveField(2)
  double targetWeight;

  @HiveField(3)
  String fastingGoal;

  @HiveField(4)
  bool onboardingCompleted;

  UserModel({
    required this.username,
    required this.currentWeight,
    required this.targetWeight,
    required this.fastingGoal,
    required this.onboardingCompleted,
  });
}
