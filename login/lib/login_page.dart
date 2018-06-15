import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final CollectionReference collectionReference = Firestore.instance.collection('users');

  bool usernameIsAvailable = false;
  String checkUsername;
  String check = "Username can\'t be empty";
  

  String userId;
  String _email;
  String _password;
  String _username;
  FormType _formType = FormType.login;

  

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          userId =
              await widget.auth.signIn(_email, _password);
          print("Signed in: $userId");
          
        } else /*(usernameIsAvailable == true)*/ {
          userId = await widget.auth
              .createUser(_email, _password);
          print("Registered user: $userId");
          saveUserData();
        }
        /*else {
          check = "Username is taken, please choose another one";
        }*/
        widget.onSignedIn();
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

void saveUserData() {
  collectionReference.add({"uid": userId,'email': _email, 'username': _username,});
}

/*void checkUserNames()  {
  Firestore.instance.collection("users").where("username", isEqualTo: checkUsername).snapshots.
  listen((snapshot) { 
    if(snapshot.documents.isEmpty) {
      debugPrint("Success!");
    }
    else {
      debugPrint("taken");
    }
});
}*/

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter login demo"),
      ),
      body: new Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons(),
            ),
          )),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.register) {
      return [
        new TextFormField(
          decoration: new InputDecoration(labelText: "Brukernavn"),
          validator: (value) => value.isEmpty ? check : null,
          onSaved: (value) => _username = value.trim().toLowerCase(),
          onFieldSubmitted: (String str) {
                  setState(() {
                    checkUsername = str;
                    
                  });
                  // checkUserNames();
                }
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: "Email"),
          validator: (value) => value.isEmpty ? "Email can\'t be empty" : null,
          onSaved: (value) => _email = value.trim().toLowerCase(),
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: "Passord"),
          validator: (value) =>
              value.isEmpty ? "Password can\'t be empty" : null,
          onSaved: (value) => _password = value.trim().toLowerCase(),
          obscureText: true,
        ),
      ];
    } else {
      return [
        new TextFormField(
          decoration: new InputDecoration(labelText: "Email"),
          validator: (value) => value.isEmpty ? "Email can\'t be empty" : null,
          onSaved: (value) => _email = value.trim().toLowerCase(),
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: "Passord"),
          validator: (value) =>
              value.isEmpty ? "Password can\'t be empty" : null,
          onSaved: (value) => _password = value.trim().toLowerCase(),
          obscureText: true,
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text("Login", style: new TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
          child: new Text("Create an account",
              style: new TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        )
      ];
    } else {
      return [
        new RaisedButton(
          child: new Text("Create an account",
              style: new TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
          
        ),
        new FlatButton(
          child: new Text("Have an account? Login",
              style: new TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
  }
