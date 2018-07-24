import 'package:flutter/material.dart';
import 'package:login/auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:login/utils/uidata.dart';
import 'dart:async';

import 'sub/new.dart';
import 'sub/newGame_page.dart';

class GamePage extends StatefulWidget {
  GamePage({Key key, this.auth, this.onSignOut, this.currentUser})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  static final formKey = new GlobalKey<FormState>();


  String mCurrentUser;
  String groupid;
  List list;

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
    // _fetch();
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
      return _groupSearch();
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
    mCurrentUser = await widget.auth.currentUser();
    print('Current user: ' + mCurrentUser);
    return mCurrentUser;
  }

  Widget _groupSearch() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .document(mCurrentUser)
            .collection("groups")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Text(
              '',
              style: new TextStyle(fontSize: 30.0),
            );
          }
          return new Scaffold(
            appBar: new AppBar(
              actions: <Widget>[
                IconButton(
                    icon: new Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 40.0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => New()),
                      );
                    })
              ],
              title: new Text("Groups"),
            ),
            backgroundColor: Colors.grey[300],
            body: new ListView(
                children: snapshot.data.documents.map((document) {
              return new SingleChildScrollView(
                padding: const EdgeInsets.all(5.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              new BorderRadius.all(const Radius.circular(8.0))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            document['name'],
                            style: Theme
                                .of(context)
                                .textTheme
                                .body1
                                .apply(fontWeightDelta: 700),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            document['name'],
                            style: Theme.of(context).textTheme.caption.apply(
                                fontFamily: UIData.ralewayFont,
                                color: Colors.pink),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              document['info'],
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: UIData.ralewayFont),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              );
            }).toList()),
          );
        },
      );
    } catch (e) {
      return null;
    }
  }

  void _fetch() {
    Firestore.instance
        .document("users/$mCurrentUser/groups/$mCurrentUser")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          groupid = datasnapshot.data["groupid"];

          debugPrint(groupid);
        });
      } else {
        debugPrint("failed");
      }
    });
  }
}

