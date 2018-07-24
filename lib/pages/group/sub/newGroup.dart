import 'package:flutter/material.dart';
import 'package:login/auth.dart';
import 'package:login/pages/group/game_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/widgets/primary_button.dart';
import 'package:login/friends/friends.dart';
import 'dart:async';
import 'dart:math';

class NewGroup extends StatefulWidget {
  NewGroup({Key key, this.auth, this.onSignOut, this.currentUser})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  NewGroupState createState() => NewGroupState();
}

enum FormType { public, private }

class NewGroupState extends State<NewGroup> {
  static final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.public;
  final BaseAuth auth = Auth();

  String mCurrentUser;

  // New game
  String _groupName= "unnamed";
  String _groupInfo = "";
  String groupType = "public";

  int groupId;

  bool gameIdAvailable = false;
  bool userFound = false;
  bool public = true;

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

  void setGroupId() {
    try {
      var random = new Random().nextInt(999999999);
      groupId = random;
      checkGroupId();
      print(groupId);
    } catch (e) {
      setState(() {
        print(e);
      });
      print(e);
    }
  }

  void checkGroupId() async {
    Firestore.instance
        .collection("groups/$groupType/$groupId")
        .where("groupid", isEqualTo: groupId)
        .getDocuments()
        .then((string) {
      if (string.documents.isEmpty) {
        setState(() {
          debugPrint("true");
          gameIdAvailable = true;
          _saveGroup();
          creation();
        });
      } else {
        setState(() {
          debugPrint("false");
          gameIdAvailable = false;
          setGroupId();
        });
      }
    });
  }

  void _saveGroup() {
    Firestore.instance.document("groups/$groupType/groups/$groupId").setData({
      "groupid": groupId,
      'name': _groupName,
      "info": _groupInfo,
      "host": mCurrentUser
    });
    Firestore.instance.document("users/$mCurrentUser/groups/$groupId").setData({
      "groupid": groupId,
      'name': _groupName,
      "info": _groupInfo,
      "host": mCurrentUser
    });
  }

  void creation() {
    Firestore.instance.document("users/$mCurrentUser/creation/0").setData({
      "id": groupId,
      "type": groupType,
    });
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
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
                padding: const EdgeInsets.all(16.0),
                child: new Column(children: [
                  new Card(
                      child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new Form(
                                child: new Column(
                                    children:
                                        nameAndInfo() + publicAndPrivate()))),
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new Form(
                                child: new Column(
                              children: submitWidgets(),
                            ))),
                      ])),
                ]))));
  }

  List<Widget> nameAndInfo() {
    return [
      padded(
          child: new TextField(
        key: new Key('Name'),
        decoration: new InputDecoration(labelText: 'Name'),
        autocorrect: false,
        onChanged: (String str) {
          setState(() {
            _groupName = str;
          });
        },
      )),
      padded(
          child: new TextField(
        key: new Key('info'),
        decoration: new InputDecoration(labelText: 'Additional information'),
        maxLines: 3,
        autocorrect: false,
        onChanged: (String str) {
          setState(() {
            _groupInfo = str;
          });
        },
      )),
      new Container(
        alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10.0),
            child: new Text("You can provide an optional description for your group.",
                key: new Key('hint'),
                style: new TextStyle(fontSize: 10.0, color: Colors.grey),
                textAlign: TextAlign.left))
    ];
  }

  List<Widget> publicAndPrivate() {
    if (public) {
      return [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20.0),
        ),
        Container(
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.centerLeft,
            child: new Text(
              "GROUP TYPE",
              style: new TextStyle(color: Colors.grey),
            )),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
            title: Row(
              children: <Widget>[
                padded(
                  child: new Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
                padded(
                    child: new Text(
                  "  Public",
                  style: new TextStyle(color: Colors.blue, fontSize: 18.0),
                ))
              ],
            ),
            onTap: () {
              setState(() {
                public = true;
                groupType = "public";
              });
            }),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
            title: Row(
              children: <Widget>[
                padded(
                    child: new Text(
                  "          Private",
                  style: new TextStyle(color: Colors.blue, fontSize: 18.0),
                ))
              ],
            ),
            onTap: () {
              setState(() {
                public = false;
                groupType = "private";
              });
            }),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10.0),
            child: new Text(
                "Public groups can be found in search, anyone can see them.",
                key: new Key('hint'),
                style: new TextStyle(fontSize: 10.0, color: Colors.grey),
                textAlign: TextAlign.left))
      ];
    } else {
      return [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20.0),
        ),
        Container(
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.centerLeft,
            child: new Text(
              "GROUP TYPE",
              style: new TextStyle(color: Colors.grey),
            )),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
            title: Row(
              children: <Widget>[
                padded(
                    child: new Text(
                  "          Public",
                  style: new TextStyle(color: Colors.blue, fontSize: 18.0),
                ))
              ],
            ),
            onTap: () {
              setState(() {
                public = true;
                groupType = "public";
              });
            }),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new ListTile(
            title: Row(
              children: <Widget>[
                padded(
                  child: new Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
                padded(
                    child: new Text(
                  "  Private",
                  style: new TextStyle(color: Colors.blue, fontSize: 18.0),
                ))
              ],
            ),
            onTap: () {
              setState(() {
                public = false;
                groupType = "private";
              });
            }),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Divider(
          height: .0,
          color: Colors.black,
        ),
        new Container(
          alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10.0),
            child: new Text("Private groups can only be joined via an invite.",
                key: new Key('hint'),
                style: new TextStyle(fontSize: 10.0, color: Colors.grey),
                textAlign: TextAlign.left))
      ];
    }
  }

  List<Widget> submitWidgets() {
    return [
      new PrimaryButton(
          key: new Key('start'),
          text: 'Create group',
          height: 44.0,
          onPressed: () {
            setGroupId();
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Friends()),
            );
            
          }),
      new FlatButton(
          key: new Key('cancel'),
          child: new Text("Cancel"),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => GamePage()),
            );
          })
    ];
  }
}
