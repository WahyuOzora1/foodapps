import 'package:foodapps/service/authentication.dart';
import 'package:flutter/material.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onLoggedIn});
  final BaseAuth auth;
  final VoidCallback onLoggedIn;
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  String _email, _password, _errorMessage;

  //delklarasi form untuk login
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  //cek apakah form  valid sebelum perform login atau signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //perform login atau register
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print("user sign id : $userId");
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showDialogVerification();
          print("Sign up id: $userId");
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 &&
            userId != null &&
            _formMode == FormMode.LOGIN) {
          widget.onLoggedIn();
        }
      } catch (e) {
        print("Error : $e");
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else {
            _errorMessage = e.message;
          }
        });
      }
    }
  }

  @override
  void initState() {
    //TODO: implement iniState
    super.initState();
    _errorMessage = "";
    _isLoading = false;
  }

  void _changeFormKeSingUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormKeLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO: implement build
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Apps'),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  //widget untuk circular progress
  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _showDialogVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verifiy Your Account'),
          content: Text('Link to verify account has been sent your email'),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  _changeFormKeLogin();
                  Navigator.of(context).pop();
                },
                child: Text('Dismiss'))
          ],
        );
      },
    );
  }

  //widget Show Body
  Widget _showBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _displayLogo(),
              _displayEmailInput(),
              _displayPassword(),
              _displayPrimaryButton(),
              _displaySecondaryButton(),
              _displayMessageError(),
            ],
          )),
    );
  }

  Widget _displayMessageError() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            height: 1.0,
            fontSize: 13.0),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _displayLogo() {
    return new Hero(
      tag: 'logo udacoding',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('images/udacoding.png'),
        ), //mengatur posisi kiri kanan atas kanan
      ),
    );
  }

  Widget _displayEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.email,
              color: Colors.green,
            )),
        validator: (value) => value.isEmpty ? 'Email cant be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _displayPassword() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.green,
            )),
        validator: (value) => value.isEmpty ? 'Password cant be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _displayPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.green,
          child: _formMode == FormMode.LOGIN
              ? new Text('Login',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white))
              : new Text(
                  'Create Account',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white),
                ),
          onPressed: () {
            _validateAndSubmit();
          },
        ),
      ),
    );
  }

  Widget _displaySecondaryButton() {
    return new FlatButton(
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormKeSingUp
          : _changeFormKeLogin,
      child: _formMode == FormMode.LOGIN
          ? new Text(
              'Create an Account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            )
          : new Text('Dont have an account? Please Sign In',
              style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              )),
    );
  }
}
