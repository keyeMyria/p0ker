import 'package:flutter/material.dart';
import 'package:login/widgets/primary_button.dart';
import 'package:login/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Login extends StatefulWidget {
  Login({Key key, this.title, this.auth, this.onSignIn, this.currentUser}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;
  final String currentUser;

  @override
  LoginState createState() => new LoginState();
}

enum FormType { login, register }

class LoginState extends State<Login> {
  static final formKey = new GlobalKey<FormState>();

  final myController = new TextEditingController();

  final CollectionReference collectionReference =
      Firestore.instance.collection('users');

  String finalUsername;

  String uid;
  String _username;
  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = '';

  bool usernameAvailable = false;

  void dispose() {
    myController.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.signIn(_email, _password);
          uid = userId;
          widget.onSignIn();
        } else if (usernameAvailable == true) {
          String userId = await widget.auth.createUser(_email, _password);
          uid = userId;
          widget.onSignIn();
          saveUserData();
        }
        setState(() {});
      } catch (e) {
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void saveUserData() {
    Firestore.instance
        .document("users/$uid")
        .setData({"uid": uid, 'email': _email, "brukernavn": _username});
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  String getFinalUsername() {
    return finalUsername;
  }

  void checkUsername() async {
    _username = myController.text.trim().toLowerCase();

    Firestore.instance
        .collection("users")
        .where("brukernavn", isEqualTo: _username)
        .getDocuments()
        .then((string) {
      if (string.documents.isEmpty) {
        setState(() {
          debugPrint("true");
          usernameAvailable = true;
          _authHint = "";
          validateAndSubmit();
          finalUsername = _username;
        });
      } else {
        setState(() {
          _authHint = "Brukernavn er opptatt";
          debugPrint("false");
          usernameAvailable = false;
        });
      }
    });
  }

  List<Widget> usernameAndPassword() {
    switch (_formType) {
      case FormType.register:
        return [
          padded(
              child: new TextFormField(
            key: new Key('Brukernavn'),
            decoration: new InputDecoration(labelText: 'Brukernavn'),
            autocorrect: false,
            // focusNode: _focus,
            validator: (val) =>
                val.isEmpty ? 'Brukernavn kan ikke være tomt' : null,
            onSaved: (val) => _username = val.trim().toLowerCase(),
            controller: myController,
          )),
          padded(
              child: new TextFormField(
            key: new Key('email'),
            decoration: new InputDecoration(labelText: 'Email'),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val.trim().toLowerCase(),
          )),
          padded(
              child: new TextFormField(
            key: new Key('password'),
            decoration: new InputDecoration(labelText: 'Password'),
            obscureText: true,
            autocorrect: false,
            validator: (val) =>
                val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val.trim().toLowerCase(),
          )),
        ];
      case FormType.login:
        return [
          padded(
              child: new TextFormField(
            key: new Key('email'),
            decoration: new InputDecoration(labelText: 'Email'),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val.trim().toLowerCase(),
          )),
          padded(
              child: new TextFormField(
            key: new Key('password'),
            decoration: new InputDecoration(labelText: 'Password'),
            obscureText: true,
            autocorrect: false,
            validator: (val) =>
                val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val.trim().toLowerCase(),
          )),
        ];
    }
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          new PrimaryButton(
              key: new Key('login'),
              text: 'Login',
              height: 44.0,
              onPressed: validateAndSubmit),
          new FlatButton(
              key: new Key('need-account'),
              child: new Text("Need an account? Register"),
              onPressed: moveToRegister),
        ];
      case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('register'),
            text: 'Create an account',
            height: 44.0,
            onPressed: checkUsername,
          ),
          new FlatButton(
              key: new Key('need-login'),
              child: new Text("Have an account? Login"),
              onPressed: moveToLogin),
        ];
    }
    return null;
  }

  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        backgroundColor: Colors.grey[300],
        body: new SingleChildScrollView(
            child: new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Column(children: [
                  new Card(
                      child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new Form(
                                key: formKey,
                                child: new Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children:
                                      usernameAndPassword() + submitWidgets(),
                                ))),
                      ])),
                  hintText()
                ]))));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
