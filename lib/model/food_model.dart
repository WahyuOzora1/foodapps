import 'package:firebase_database/firebase_database.dart';

class FoodModel {
  String key;
  String foodName;
  bool completed;
  String userId;

  FoodModel(this.foodName, this.userId, this.completed);

  FoodModel.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        foodName = snapshot.value['foodName'],
        completed = snapshot.value['completed'],
        userId = snapshot.value['userId'];

  toJson() {
    return {
      "userId": userId,
      "foodName": foodName,
      "completed": completed,
    };
  }
}
