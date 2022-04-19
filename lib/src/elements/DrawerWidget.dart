import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  _DrawerWidgetState() : super(ProfileController()) {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              currentUser.value.apiToken != null
                  ? Navigator.of(context).pushNamed('/Profile')
                  : Navigator.of(context).pushNamed('/Login');
            },
            child: currentUser.value.apiToken != null
                ? UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                    accountName: Text(
                      currentUser.value.name,
                      style: Theme.of(context).textTheme.headline6.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                    accountEmail: Text(
                      currentUser.value.email,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    currentAccountPicture: Stack(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(80)),
                            child: CachedNetworkImage(
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: currentUser.value.image.thumb,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 80,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error_outline),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: currentUser.value.verifiedPhone ?? false
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                )
                              : SizedBox(),
                        )
                      ],
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).welcome,
                            style: Theme.of(context).textTheme.headline4.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor))),
                        SizedBox(height: 5),
                        Text(S.of(context).loginAccountOrCreateNewOneForFree,
                            style: Theme.of(context).textTheme.bodyText2.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor))),
                        SizedBox(height: 15),
                        Wrap(
                          spacing: 10,
                          children: <Widget>[
                            MaterialButton(
                              elevation: 0,
                              onPressed: () {
                                Navigator.of(context).pushNamed('/Login');
                              },
                              color: Theme.of(context).primaryColor,
                              height: 40,
                              child: Wrap(
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 9,
                                children: [
                                  Image.asset("assets/img/login.png",
                                      height: 24,
                                      width: 24,
                                      color: Theme.of(context).accentColor),
                                  Text(
                                    S.of(context).login,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .merge(TextStyle(
                                            color: Theme.of(context)
                                                .accentColor)),
                                  ),
                                ],
                              ),
                              shape: StadiumBorder(),
                            ),
                            MaterialButton(
                              elevation: 0,
                              color:
                                  Theme.of(context).primaryColor,
                              height: 40,
                              onPressed: () {
                                Navigator.of(context).pushNamed('/SignUp');
                              },
                              child: Wrap(
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 9,
                                children: [
                                  Image.asset("assets/img/register.png",
                                      height: 24,
                                      width: 24,
                                      color: Theme.of(context).accentColor),
                                  Text(
                                    S.of(context).register,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .merge(TextStyle(
                                            color:
                                                Theme.of(context).accentColor)),
                                  ),
                                ],
                              ),
                              shape: StadiumBorder(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).accentColor.withOpacity(0.5),
              child: ListView(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Pages', arguments: 2);
                    },
                    leading: Icon(
                      Icons.home_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      S.of(context).home,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Pages', arguments: 0);
                    },
                    leading: Image.asset("assets/img/notifications.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).notifications,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Pages', arguments: 3);
                    },
                    leading: Image.asset("assets/img/my_orders.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).my_orders,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Favorites');
                    },
                    leading: Image.asset("assets/img/favourites.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).favorite_products,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Pages', arguments: 4);
                    },
                    leading: Image.asset("assets/img/messages.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).messages,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      S.of(context).application_preferences,
                      style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color:Colors.black)),
                    ),
                    trailing: Icon(
                      Icons.remove,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Help');

                    },
                    leading: Image.asset("assets/img/help_support.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).help__support,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      if (currentUser.value.apiToken != null) {
                        Navigator.of(context).pushNamed('/Settings');
                      } else {
                        Navigator.of(context).pushReplacementNamed('/Login');
                      }
                    },
                    leading: Image.asset("assets/img/settings.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).settings,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  // ListTile(
                  //   onTap: () {
                  //     Navigator.of(context).pushNamed('/Languages');
                  //   },
                  //   leading: Icon(
                  //     Icons.translate_outlined,
                  //     color: Theme.of(context).primaryColor.withOpacity(1),
                  //   ),
                  //   title: Text(
                  //     S.of(context).languages,
                  //     style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                  //   ),
                  // ),
                  ListTile(
                    onTap: () {
                      if (Theme.of(context).brightness == Brightness.dark) {
                        setBrightness(Brightness.light);
                        setting.value.brightness.value = Brightness.light;
                      } else {
                        setting.value.brightness.value = Brightness.dark;
                        setBrightness(Brightness.dark);
                      }
                      setting.notifyListeners();
                    },
                    leading: Image.asset("assets/img/dark_mode.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? S.of(context).light_mode
                          : S.of(context).dark_mode,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      if (currentUser.value.apiToken != null) {
                        logout().then((value) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/Pages', (Route<dynamic> route) => false,
                              arguments: 2);
                        });
                      } else {
                        Navigator.of(context).pushNamed('/Login');
                      }
                    },
                    leading: Image.asset(currentUser.value.apiToken != null
                        ? "assets/img/logout.png" :"assets/img/login.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      currentUser.value.apiToken != null
                          ? S.of(context).log_out
                          : S.of(context).login,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  ),
                  currentUser.value.apiToken == null
                      ? ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/SignUp');
                    },
                    leading: Image.asset("assets/img/register.png",
                        height: 24, width: 24, color: Theme.of(context).primaryColor),
                    title: Text(
                      S.of(context).register,
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                  )
                      : SizedBox(height: 0),
                  setting.value.enableVersion
                      ? ListTile(
                    dense: true,
                    title: Text(
                      S.of(context).version + " " + setting.value.appVersion,
                      style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                    trailing: Icon(
                      Icons.remove,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  )
                      : SizedBox(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
