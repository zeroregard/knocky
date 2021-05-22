import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/drawerController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/screens/event.dart';
import 'package:knocky/screens/login.dart';
import 'package:knocky/screens/significantThreads.dart';

import 'drawerListTile.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> with TickerProviderStateMixin {
  final AuthController authController = Get.put(AuthController());
  final MainDrawerController mainDrawerController =
      Get.put(MainDrawerController());

  navigateTo(Widget screen) {
    Get.to(screen);
  }

  onListTileTap(BuildContext context, Function onTap) {
    Get.back();
    //Navigator.of(context).pop(); // close the drawer
    onTap();
  }

  @override
  void initState() {
    super.initState();
    mainDrawerController.fetchRandomAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mainDrawerController.isUserListOpen.value = false;
    super.dispose();
  }

  Widget loggedInDrawerHeader() {
    return UserAccountsDrawerHeader(
      margin: EdgeInsets.only(bottom: 0),
      accountName: Text(authController.username.value),
      accountEmail: null,
      onDetailsPressed: () => mainDrawerController.isUserListOpen.value =
          !mainDrawerController.isUserListOpen.value,
      decoration: BoxDecoration(
        image: authController.isAuthenticated.value
            ? DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                    "${KnockoutAPI.CDN_URL}/${authController.background.value}"),
              )
            : null,
        color: Colors.redAccent,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
            "${KnockoutAPI.CDN_URL}/${authController.avatar.value}"),
      ),
    );
  }

  List<Widget> loggedInDrawerItems() {
    if (!authController.isAuthenticated.value) return [];

    return [
      DrawerListTile(
        iconData: FontAwesomeIcons.thList,
        title: 'Forum',
        onTap: () => {},
      ),
      DrawerListTile(
        iconData: FontAwesomeIcons.solidNewspaper,
        title: 'Subscriptions',
        onTap: () => {},
      ),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidClock,
          title: 'Latest Threads',
          onTap: () => onListTileTap(
              context,
              () => navigateTo(SignificantThreadsScreen(
                    threadsToShow: SignificantThreads.Latest,
                  )))),
      DrawerListTile(
        iconData: FontAwesomeIcons.fire,
        title: 'Popular Threads',
        onTap: () => onListTileTap(
          context,
          () => navigateTo(
            SignificantThreadsScreen(
              threadsToShow: SignificantThreads.Popular,
            ),
          ),
        ),
      ),
      DrawerListTile(
        iconData: FontAwesomeIcons.cog,
        title: 'Settings',
        onTap: () => {},
      ),
      Obx(() => !authController.isAuthenticated.value
          ? DrawerListTile(
              iconData: FontAwesomeIcons.signInAlt,
              title: 'Log in',
              onTap: () => {
                navigateTo(LoginScreen()),
              },
            )
          : Container()),
      Divider(color: Colors.white),
      DrawerListTile(
          iconData: FontAwesomeIcons.bullhorn,
          title: 'Events',
          onTap: () => onListTileTap(context, () => navigateTo(EventScreen()))),
      DrawerListTile(
          iconData: FontAwesomeIcons.discord,
          title: 'Discord',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidComment,
          title: 'Mentions',
          onTap: () => {}),
    ];
  }

  List<Widget> guestDrawerItems() {
    if (authController.isAuthenticated.value) return [];
    return [
      DrawerListTile(
        iconData: FontAwesomeIcons.thList,
        title: 'Forum',
        onTap: () => {},
      ),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidClock,
          title: 'Latest Threads',
          onTap: () => onListTileTap(
              context,
              () => navigateTo(SignificantThreadsScreen(
                    threadsToShow: SignificantThreads.Latest,
                  )))),
      DrawerListTile(
        iconData: FontAwesomeIcons.fire,
        title: 'Popular Threads',
        onTap: () => onListTileTap(
          context,
          () => navigateTo(
            SignificantThreadsScreen(
              threadsToShow: SignificantThreads.Popular,
            ),
          ),
        ),
      ),
      DrawerListTile(
        iconData: FontAwesomeIcons.cog,
        title: 'Settings',
        onTap: () => {},
      ),
      Obx(() => !authController.isAuthenticated.value
          ? DrawerListTile(
              iconData: FontAwesomeIcons.signInAlt,
              title: 'Log in',
              onTap: () => {
                navigateTo(LoginScreen()),
              },
            )
          : Container()),
      Divider(color: Colors.white),
      DrawerListTile(
          iconData: FontAwesomeIcons.bullhorn,
          title: 'Events',
          onTap: () => onListTileTap(context, () => navigateTo(EventScreen()))),
      DrawerListTile(
          iconData: FontAwesomeIcons.discord,
          title: 'Discord',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidComment,
          title: 'Mentions',
          onTap: () => {}),
    ];
  }

  Widget guestDrawerHeader() {
    return DrawerHeader(
      child: Column(
        children: [
          Text('Not logged in'),
        ],
      ),
      decoration: BoxDecoration(
        image: authController.isAuthenticated.value
            ? DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                    "${KnockoutAPI.CDN_URL}/${authController.background.value}"),
              )
            : null,
        color: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(
        () => ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            authController.isAuthenticated.value
                ? loggedInDrawerHeader()
                : guestDrawerHeader(),
            AnimatedCrossFade(
              crossFadeState: mainDrawerController.isUserListOpen.value
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 500),
              sizeCurve: Curves.easeOutCirc,
              firstChild: Container(
                child: Column(children: [
                  DrawerListTile(
                      tileColor: Colors.grey[900],
                      iconData: FontAwesomeIcons.user,
                      title: 'Profile',
                      onTap: () {}),
                  DrawerListTile(
                      tileColor: Colors.grey[900],
                      iconData: FontAwesomeIcons.signOutAlt,
                      title: 'Log Out',
                      onTap: () {
                        mainDrawerController.isUserListOpen.value = false;
                        authController.logout();
                      }),
                ]),
              ),
              secondChild: Container(),
            ),
            ...guestDrawerItems(),
            ...loggedInDrawerItems(),
            Divider(
              color: Colors.white,
            ),
            mainDrawerController.adImageUrl.value != ''
                ? CachedNetworkImage(
                    height: 80,
                    placeholderFadeInDuration: Duration(milliseconds: 200),
                    placeholder: (context, url) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 14),
                            child: CircularProgressIndicator(),
                          ),
                          Text('Loading ad...')
                        ],
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                    imageUrl: mainDrawerController.adImageUrl.value,
                  )
                : Container(),
            Divider(color: Colors.white)
          ],
        ),
      ),
    );
  }
}
