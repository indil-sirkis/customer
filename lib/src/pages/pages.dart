import 'package:flutter/material.dart';
import 'package:markets/src/elements/DeliveryAddressBottomSheetWidget.dart';

import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../pages/home.dart';
import '../pages/map.dart';
import '../pages/notifications.dart';
import '../pages/orders.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import 'messages.dart';

// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
          break;
        case 2:
          widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 4:
          widget.currentPage = MessagesWidget(parentScaffoldKey: widget.scaffoldKey); //FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        endDrawer: FilterWidget(onFilter: (filter) {
          if(!filter.delivery){
            settingsRepo.deliveryAddress.value?.latitude =
            null;
            settingsRepo.deliveryAddress.value?.address =
            null;
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
          }else if(settingsRepo.deliveryAddress.value?.address == null){
            print("FFFFF:::");
            var bottomSheetController = widget
                .scaffoldKey.currentState
                .showBottomSheet(
                  (context) =>
                  DeliveryAddressBottomSheetWidget(
                      scaffoldKey:
                      widget.scaffoldKey),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
            );
            bottomSheetController.closed.then((value) {
              Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
            });
          }else{
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
          }
        },scaffoldKey: widget.scaffoldKey),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon:Image.asset("assets/img/notifications.png",height: 25,width: 25,color: widget.currentTab == 0 ? Theme.of(context).accentColor:Theme.of(context).focusColor.withOpacity(1)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(widget.currentTab == 1 ? Icons.location_on : Icons.location_on_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
                label: '',
                icon: Container(
                  width: 42,
                  height: 42,
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                    ],
                  ),
                  child: new Icon(widget.currentTab == 2 ? Icons.home : Icons.home_outlined, color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
              icon:Image.asset("assets/img/my_orders.png",height: 25,width: 25,color: widget.currentTab == 3 ? Theme.of(context).accentColor:Theme.of(context).focusColor.withOpacity(1)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon:Image.asset("assets/img/messages.png",height: 25,width: 25,color: widget.currentTab == 4 ? Theme.of(context).accentColor:Theme.of(context).focusColor.withOpacity(1)),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
