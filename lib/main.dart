import 'package:foodapps/root.dart';
import 'package:foodapps/service/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  // runApp(MaterialApp(
  //   home: RootPage(
  //     auth: Auth(),
  //   ),
  // ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authObj = Auth();
    return StreamProvider<UserModel>.value(
      value: _authObj.user,
      child: MaterialApp(
        title: 'Flutter Firebase',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: RootPage(
          auth: _authObj,
        ),
      ),
    );
  }
}
