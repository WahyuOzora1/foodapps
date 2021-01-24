import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodapps/model/food_model.dart';
import 'package:foodapps/service/authentication.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String userId;

  HomePage({Key key, this.auth, this.userId, this.onSignOut}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //list food
  List<FoodModel> _foodList;
  //deklarasikan database
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //untuk Query
  Query _foodQuery;

  //deklarasi text controller untuk input nama food
  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onFoodAddedSubscription;
  StreamSubscription<Event> _onFoodChangeSubscription;

  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();

    //lanjutan
    //load data
    _foodList = new List();
    _foodQuery = _database
        .reference()
        .child("Data_makanan")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _onFoodAddedSubscription = _foodQuery.onChildAdded.listen(_onEntryAdded);
    _onFoodChangeSubscription =
        _foodQuery.onChildChanged.listen(_onEntryChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _onFoodAddedSubscription.cancel();
    //tambahkan ketika change
    _onFoodChangeSubscription.cancel();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _foodList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _foodList[_foodList.indexOf(oldEntry)] =
          FoodModel.fromSnapshot(event.snapshot);
    });
  }

  //method update
  _updateFoodList(FoodModel food) {
    food.completed = !food.completed;
    if (food != null) {
      _database
          .reference()
          .child("Data_makanan")
          .child(food.key)
          .set(food.toJson());
    }
  }

  //method untuk delete data food
  _deleteFoodItem(String foodId, int index) {
    _database
        .reference()
        .child("Data_makanan")
        .child(foodId)
        .remove()
        .then((_) {
      print("Delete $foodId successful");
      _foodList.removeAt(index);
    });
  }

  //method on entry add
  _onEntryAdded(Event event) {
    setState(() {
      _foodList.add(FoodModel.fromSnapshot(event.snapshot));
    });
  }

  //method untuk tambah data
  _addNewFoodList(String foodListItem) {
    if (foodListItem.length > 0) {
      FoodModel foodModel =
          new FoodModel(foodListItem.toString(), widget.userId, false);

      _database
          .reference()
          .child("Data_makanan")
          .push()
          .set(foodModel.toJson());
    }
  }

  _showDialogFoodForm(BuildContext context) async {
    _textEditingController.clear();

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(labelText: 'Add Food Item'),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              new FlatButton(
                onPressed: () {
                  //penambahan data
                  _addNewFoodList(_textEditingController.text.toString());

                  //Load ke homepage
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        });
  }

  void _checkEmailVerification() async {
    isEmailVerified = await widget.auth.isEmailVerified();
    if (!isEmailVerified) {
      _showDialogKonfirmasiEmail();
    }
  }

  void _showDialogKonfirmasiEmail() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Silahkan verifikasi akun Anda'),
            content: Text('Please verifiy account in tidak sent to your email'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resentEmailVerifikasi();
                },
                child: Text('Resent Link'),
              ),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  void _resentEmailVerifikasi() {
    widget.auth.sendEmailVerification();
    _showDialogVerifikasiEmail();
  }

  void _showDialogVerifikasiEmail() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verify your account'),
            content:
                Text('Please Verify account in the link sent to your email'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Dismiss'))
            ],
          );
        });
  }

//method untuk log out

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  //menampilkan food list dari database
  Widget _showFoodList() {
    if (_foodList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _foodList.length,
        itemBuilder: (BuildContext context, int index) {
          String foodId = _foodList[index].key;
          String foodName = _foodList[index].foodName;
          bool completed = _foodList[index].completed;
          String userId = _foodList[index].userId;

          return Dismissible(
            key: Key(foodId),
            background: Container(
              color: Colors.green,
            ),
            onDismissed: (direction) async {
              //method swipe untuk bisa delete data
              _deleteFoodItem(foodId, index);
            },
            child: ListTile(
              title: Text(
                "$foodName",
                style: TextStyle(fontSize: 20.0, color: Colors.green),
              ),
              trailing: IconButton(
                icon: (completed)
                    ? Icon(
                        Icons.done_outline,
                        color: Colors.green,
                        size: 20.0,
                      )
                    : Icon(
                        Icons.done,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                onPressed: () {
                  //update
                  _updateFoodList(_foodList[index]);
                },
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'Welcome.Food List Strill Empty',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Apps'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: Text(
                'Logout',
                style: new TextStyle(fontSize: 14.0, color: Colors.white),
              ))
        ],
      ),
      body: _showFoodList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialogFoodForm(context);
        },
        tooltip: 'increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
