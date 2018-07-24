import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/auth.dart';
import 'dart:async';

class Friends extends StatefulWidget {
  const Friends();

  @override
  FriendsState createState() => FriendsState();
}

class FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Band",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homee(),
    );
  }
}

class Homee extends StatefulWidget {
  const Homee({Key key, this.auth, this.currentUser, this.onSignOut})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final String currentUser;

  @override
  HomeeState createState() => HomeeState();
}

class HomeeState extends State<Homee> {
  static final formKey = new GlobalKey<FormState>();

  final BaseAuth auth = Auth();

  bool userFound = false;
  String mCurrentUser;
  bool getStatus = false;

  String type;
  int groupId;

  Map<String, String> data = new Map<String, String>();
  String username;
  String email;
  String uid;
  String add;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add to group"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Next", style: new TextStyle(
                color: Colors.white,
                fontSize: 18.0
              ),),
              onPressed: _addToFireStore,
            )
          ],
        ),
        body: setScreen());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
              child: Container(
            color: Colors.grey[200],
            child: Text(
              document["brukernavn"],
              style: Theme.of(context).textTheme.headline,
            ),
          )),
          new Divider(
            height: .0,
            color: Colors.black,
          ),
        ],
      ),
      onTap: () {
        if (getStatus == false) {
          getGroupStatus();
        }
        add = document.documentID;
        getUser();
        print(add);
      },
    );
  }

  // void addToMap() {
    
    
  //   data.addEntries(username[uid]);
       
      
    
  //   print("added");
    
  // }

  void _addToFireStore() {
    Firestore.instance
        .collection("groups/$type/groups/$groupId/members")
        .add(data)
        .whenComplete(() {
      debugPrint("Document Added");
    }).catchError((e) => print(e));
  }

  getUser() {
    Firestore.instance.document("users/$add").get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          username = datasnapshot.data["brukernavn"];
          email = datasnapshot.data["email"];
          uid = datasnapshot.data["uid"];
          print("$username, $email, $uid");
          // addToMap();
        });
      }
    });
  }

  addToGroup() {
    Firestore.instance.document("groups/$type/groups/$groupId/members/$add").setData({
      "uid": uid,
      'name': username,
      
      "email": email
    });
  }

  getGroupStatus() {
    Firestore.instance
        .document("users/$mCurrentUser/creation/0")
        .get()
        .then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          groupId = datasnapshot.data["id"];
          type = datasnapshot.data["type"];
          print("$groupId $type");
          getStatus = true;
        });
      }
    });
  }

  

  List<Widget> row() {
    return [friendSearch()];
  }

  Widget friendSearch() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users/$mCurrentUser/friends")
            .where("brukernavn", isGreaterThan: "0")
            .snapshots(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) return const Text("Loading...");
          return ListView.builder(
            itemExtent: 50.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, snapshot.data.documents[index]),
          );
        });
  }

  initState() {
    super.initState();
    userIdFound();
    getGroupStatus();
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
      return friendSearch();
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
}
