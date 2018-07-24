import 'package:flutter/material.dart';
import 'package:login/auth.dart';

import 'dart:async';
import 'package:login/pages/group/sub/newGame_page.dart';
import 'package:login/pages/group/sub/newGroup.dart';

class New extends StatefulWidget {
  New({Key key, this.auth, this.onSignOut, this.currentUser}) : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  NewState createState() => NewState();
}

enum FormType { public, private }

class NewState extends State<New> {
  static final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.public;
  final BaseAuth auth = Auth();

  String mCurrentUser;
  String _authHint = "";
  bool userFound = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Container(
      child: setScreen(),
    ));
  }

  initState() {
    super.initState();
    userIdFound();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget loading() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  setScreen() {
    if (userFound == false) {
      return loading();
    } else {
      return _newGame();
    }
  }

  Future<bool> userIdFound() async {
    await _getCurrentUser();
    userFound = true;
    print(userFound);
    setState(() {
      setScreen();
    });

    return userFound;
  }

  _getCurrentUser() async {
    mCurrentUser = await auth.currentUser();
    print('Current user: ' + mCurrentUser);
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  Widget paddedHorizontal({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: .0),
      child: child,
    );
  }

  Widget paddedTwo({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: child,
    );
  }

  Widget _newGame() {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("New game"),
        ),
        backgroundColor: Colors.grey[300],
        body: new SingleChildScrollView(
            child: new Container(
                padding: const EdgeInsets.all(1.0),
                child: new Column(children: [
                  new Card(
                      child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new Form(
                                child: new Column(
                                    children: usernameAndPassword()))),
                      ])),
                ]))));
  }

  List<Widget> usernameAndPassword() {
    return [
      new ListTile(
        title: Row(
          children: <Widget>[
            padded(
              child: new Icon(
                Icons.people,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
            padded(
                child: new Text(
              "  New Group",
              style: new TextStyle(color: Colors.blue, fontSize: 18.0),
            ))
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewGroup()),
          );
        },
      ),
      new Divider(
        height: .0,
        color: Colors.black,
      ),
      new ListTile(
        title: Row(
          children: <Widget>[
            padded(
              child: new Icon(
                Icons.account_balance,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
            padded(
                child: new Text(
              "  New League",
              style: new TextStyle(color: Colors.blue, fontSize: 18.0),
            ))
          ],
        ),
        onTap: null,
      ),
      new Divider(
        height: .0,
        color: Colors.black,
      ),
      new ListTile(
        title: Row(
          children: <Widget>[
            padded(
              child: new Icon(
                Icons.play_arrow,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
            padded(
                child: new Text(
              "  New Game",
              style: new TextStyle(color: Colors.blue, fontSize: 18.0),
            ))
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewGame()),
          );
        },
      ),
      new Divider(
        height: .0,
        color: Colors.black,
      ),
      new Container(
          //height: 80.0,
          padding: const EdgeInsets.all(32.0),
          child: new Text(_authHint,
              key: new Key('hint'),
              style: new TextStyle(fontSize: 18.0, color: Colors.grey),
              textAlign: TextAlign.center))
    ];
  }
}
