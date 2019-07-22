import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/screens/subforum.dart';
import 'package:knocky/widget/Drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/widget/tab-navigator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  List<Subforum> _subforums = new List<Subforum>();
  bool _loginIsOpen;
  bool _isFetching = false;
  StreamSubscription<List<Subforum>> _dataSub;
  int _selectedTab = 0;
  final navigatorKey = GlobalKey<NavigatorState>();

  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  void initState() {
    super.initState();

    _loginIsOpen = false;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    getSubforums();
    ScopedModel.of<AuthenticationModel>(context)
        .getLoginStateFromSharedPreference(context);
  }

  @override
  void dispose() {
    super.dispose();
    _dataSub.cancel();
  }

  Future<void> getSubforums() {
    setState(() {
      _isFetching = true;
    });

    _dataSub?.cancel();
    _dataSub = KnockoutAPI().getSubforums().asStream().listen((subforums) {
      setState(() {
        _subforums = subforums;
        _isFetching = false;
      });
    });

    return _dataSub.asFuture();
  }

  Future<bool> _onWillPop() async {
    if (navigatorKeys[_selectedTab].currentState.canPop()) {
      !await navigatorKeys[_selectedTab].currentState.maybePop();
      return false;
    }
    return true;
    

    /*if (_loginIsOpen) {
      return false;
    } else {
      return true;
    }*/
  }

  bool notNull(Object o) => o != null;

  void onTapItem(Subforum item) {
    print('Clicked item ' + item.id.toString());

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SubforumScreen(
                subforumModel: item,
              )),
    );
  }

  Widget _buildOffstageNavigator(int tabItem, BuildContext rootContext) {
    return Offstage(
      offstage: _selectedTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: DrawerWidget(
          onLoginOpen: () {
            setState(() {
              _loginIsOpen = true;
            });
          },
          onLoginCloses: () {
            setState(() {
              _loginIsOpen = false;
            });
          },
          onLoginFinished: () {
            setState(() {
              _loginIsOpen = false;
            });
          },
        ),
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(0, context),
          _buildOffstageNavigator(1, context),
          _buildOffstageNavigator(2, context),
          _buildOffstageNavigator(3, context),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (int index) {
            if (index != _selectedTab) {
              setState(() {
                _selectedTab = index;
              });
            } else {
              if(navigatorKeys[_selectedTab].currentState.canPop()) {
               navigatorKeys[_selectedTab].currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              }
            }
            
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list), title: Text('Forum')),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.solidNewspaper),
                title: Text('Subscriptions')),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.solidClock), title: Text('Latest')),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.fire), title: Text('Popular'))
          ],
        ),
      ),
    );
  }
}
