import 'package:flutter/material.dart';
import 'auth.dart';
import 'user_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_page.dart';


import 'package:flutter_search_bar/flutter_search_bar.dart';





class MyHomePage extends StatefulWidget {
  MyHomePage({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  final Key keyOne = PageStorageKey('pageOne');
  final Key keyTwo = PageStorageKey('pageTwo');
  final Key keyThree = PageStorageKey('pageThree');

  final BaseAuth auth = Auth();
  

  int currentTab = 0;

  PageOne one;
  GamePage two;
  DisplaySearch three;
  List<Widget> pages;
  Widget currentPage;

  List<Data> dataList;
  final PageStorageBucket bucket = PageStorageBucket();



  @override
  void initState() {
    dataList = [
      Data(1, false, "Example-1"),
      Data(2, false, "Example-2"),
      Data(3, false, "Example-3"),
      Data(4, false, "Example-4"),
      Data(5, false, "Example-5"),
      Data(6, false, "Example-6"),
      Data(7, false, "Example-7"),
      Data(8, false, "Example-8"),
      Data(9, false, "Example-9"),
      Data(10, false, "Example-10"),
    ];
    one = PageOne(
      key: keyOne,
      dataList: dataList,
    );
    two = GamePage(
      key: keyTwo,
      auth: auth,
    );

    three = DisplaySearch(
      key: keyThree,
      auth: auth,
      
    );

    pages = [one, two, three];

    currentPage = one;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text("Persistance Example"),
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white))),
        ],
      ),*/
      body: PageStorage(
        child: currentPage,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (int index) {
          setState(() {
            currentTab = index;
            currentPage = pages[index];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            title: Text("Settings"),
          ),
        ],
      ),
    );
  }
}

class PageOne extends StatefulWidget {
  final List<Data> dataList;
  PageOne({
    Key key,
    this.dataList,
  }) : super(key: key);

  @override
  PageOneState createState() => PageOneState();
}

class PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.dataList.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            key: PageStorageKey('${widget.dataList[index].id}'),
            title: Text(widget.dataList[index].title),
            // onExpansionChanged: (b) => setState(() {
            //       widget.dataList[index].expanded = b;
            //       PageStorage.of(context).writeState(context, b,
            //           identifier: ValueKey(
            //             '${widget.dataList[index].id}',
            //           ));
            //     }),
            // initiallyExpanded: widget.dataList[index].expanded,
            //  PageStorage.of(context).readState(
            //           context,
            //           identifier: ValueKey(
            //             '${widget.dataList[index].id}',
            //           ),
            //         ) ??
            //     false,
            children: <Widget>[
              Container(
                color: index % 2 == 0 ? Colors.orange : Colors.limeAccent,
                height: 100.0,
              ),
            ],
          );
        });
  }
}




class Data {
  final int id;
  bool expanded;
  final String title;
  Data(this.id, this.expanded, this.title);
}





