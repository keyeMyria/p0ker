import 'package:flutter/material.dart';
import 'package:login/auth.dart';
import 'package:login/pages/group/game_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/widgets/primary_button.dart';

import 'dart:async';
import 'dart:math';

class NewGame extends StatefulWidget {
  NewGame({Key key, this.auth, this.onSignOut, this.currentUser})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  NewGameState createState() => NewGameState();
}

enum FormType { public, private }

class NewGameState extends State<NewGame> {
  static final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.public;
  final BaseAuth auth = Auth();

  String mCurrentUser;

  // New game
  String _gameName;
  String _gameAdress;
  String _gameDate;
  String _gameTime;
  int _gameMaxPlayers;
  String _gameSBlind;
  String _gameBBlind;
  String _gameInfo;

  int gameId;
  bool gameIdAvailable = false;

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

  void setGameId() {
    try {
      var random = new Random().nextInt(999999999);
      gameId = random;
      checkGameId();
    } catch (e) {
      setState(() {
        print(e);
      });
      print(e);
    }
  }

  void checkGameId() async {
    Firestore.instance
        .collection("groups/gutta/games")
        .where("gameid", isEqualTo: gameId)
        .getDocuments()
        .then((string) {
      if (string.documents.isEmpty) {
        setState(() {
          debugPrint("true");
          gameIdAvailable = true;
          _saveGame();
        });
      } else {
        setState(() {
          debugPrint("false");
          gameIdAvailable = false;
          setGameId();
        });
      }
    });
  }

  void _saveGame() {
    Firestore.instance.document("groups/gutta/games/$gameId").setData({
      "gameid": gameId,
      'name': _gameName,
      "adress": _gameAdress,
      "date": _gameDate,
      "time": _gameTime,
      "maxplayers": _gameMaxPlayers,
      "sblind": _gameSBlind,
      "bblind": _gameBBlind,
      "info": _gameInfo,
    });
    Firestore.instance.document("users/$mCurrentUser/games/$gameId").setData({
      "gameid": gameId,
      'name': _gameName,
      "adress": _gameAdress,
      "date": _gameDate,
      "time": _gameTime,
      "maxplayers": _gameMaxPlayers,
      "sblind": _gameSBlind,
      "bblind": _gameBBlind,
      "info": _gameInfo,
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
                                  usernameAndPassword() + _additionalInfo(),
                            ))),
                        new Container(
                            padding: const EdgeInsets.all(16.0),
                            child: new Form(
                                child: new Column(
                              children: submitWidgets(),
                            ))),
                      ])),
                ]))));
  }

  int val = 5;

  List<Widget> usernameAndPassword() {
    switch (_formType) {
      case FormType.public:
        return [
          padded(
              child: new TextField(
            key: new Key('Name'),
            decoration: new InputDecoration(labelText: 'Name'),
            autocorrect: false,
            onChanged: (String str) {
              setState(() {
                _gameName = str;
              });
            },
          )),
          padded(
              child: new TextField(
            key: new Key('Adress'),
            decoration: new InputDecoration(labelText: 'Adress'),
            autocorrect: false,
            onChanged: (String str) {
              setState(() {
                _gameAdress = str;
              });
            },
          )),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              paddedTwo(
                child: new RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: new Text("Select date"),
                  color: Colors.blue,
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ),
              paddedTwo(
                child: new RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  color: Colors.blue,
                  child: new Text("Select time"),
                  onPressed: () {
                    _selectTime(context);
                  },
                ),
              ),
            ],
          ),
          paddedTwo(
            child: new Text(
              "Maximum players",
              textAlign: TextAlign.left,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
          ),
          new Slider(
            value: val.toDouble(),
            min: 0.0,
            max: 9.0,
            divisions: 9,
            label: '$val',
            onChanged: (double newValue) {
              setState(() {
                val = newValue.round();
                _gameMaxPlayers = val;
                print(val);
              });
            },
          ),
        ];
      case FormType.private:
        return [
          padded(
              child: new TextField(
            key: new Key('Name'),
            decoration: new InputDecoration(labelText: 'Name'),
            autocorrect: false,
            onChanged: (String str) {
              setState(() {
                _gameName = str;
              });
            },
          )),
        ];
    }
  }

  List<Widget> _additionalInfo() {
    return [
      new Column(
        children: <Widget>[
          padded(
              child: new TextField(
            key: new Key("sblind"),
            decoration: new InputDecoration(labelText: "Small Blind"),
            onChanged: (String str) {
              setState(() {
                _gameSBlind = str;
              });
            },
          )),
        ],
      ),
      new Column(
        children: <Widget>[
          padded(
              child: new TextField(
            key: new Key("bblind"),
            decoration: new InputDecoration(labelText: "Big Blind"),
            onChanged: (String str) {
              setState(() {
                _gameBBlind = str;
              });
            },
          )),
        ],
      ),
      padded(
          child: new TextField(
        key: new Key('info'),
        decoration: new InputDecoration(labelText: 'Additional information'),
        maxLines: 3,
        autocorrect: false,
        onChanged: (String str) {
          setState(() {
            _gameInfo = str;
          });
        },
      )),
    ];
  }

  List<Widget> submitWidgets() {
    return [
      new PrimaryButton(
        key: new Key('start'),
        text: 'Start game',
        height: 44.0,
        onPressed: setGameId,
      ),
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

  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2018),
      lastDate: new DateTime(2019),
    );

    if (picked != null && picked != _date) {
      debugPrint("Date selected : ${_date.toString()}");
      setState(() {
        _date = picked;
        _gameDate = _date.toString();
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && picked != _time) {
      print("Time selected ${_time.toString()}");
      setState(() {
        _time = picked;
        _gameTime = _time.toString();
      });
    }
  }
}
