import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class ArtistsPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("users").snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text("There is no expense");
          return new ListView(children: getExpenseItems(snapshot));
        });
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map((doc) => new ListTile(title: new Text(doc["name"]), subtitle: new Text(doc["amount"].toString())))
        .toList();
  }
}

