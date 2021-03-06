import 'package:flutter/material.dart';
import 'package:login/auth.dart';
import 'package:login/pages/login/login.dart';

import 'bottom_nav.dart';
import 'package:login/pages/login/home_page.dart';


class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class RootPageState extends State<RootPage> {
  String currentUser;

  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
        currentUser = userId;
        debugPrint(currentUser);
      });
    });
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new Login(
          title: 'Flutter Login',
          auth: widget.auth,
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
        );
      case AuthStatus.signedIn:
        return new MyHomePage(
            auth: widget.auth,
            onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn));
    }
  }
}
