import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:markets/src/helpers/app_config.dart' as config;
import 'package:markets/src/models/filter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;

  Filter filter;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFilter();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName.toString().toUpperCase() ?? S.of(context).home,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1.3,color:Theme.of(context).primaryColor)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
                settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection =
                  settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'slider':
                  return HomeSliderWidget(slides: _con.slides);
                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  );
                case 'top_markets_heading':
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset("assets/img/trending_products.png",
                                height: 28,
                                width: 28,
                                color: Theme.of(context).hintColor),
                            Expanded(
                              child: Text(
                                S.of(context).top_markets,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (currentUser.value.apiToken == null) {
                                  _con.requestForCurrentLocation(context).then((value)
                                  {
                                    setState(() {
                                      filter.delivery = true;
                                    });
                                  });
                                } else {
                                  var bottomSheetController = widget
                                      .parentScaffoldKey.currentState
                                      .showBottomSheet(
                                    (context) =>
                                        DeliveryAddressBottomSheetWidget(
                                            scaffoldKey:
                                                widget.parentScaffoldKey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                    ),
                                  );
                                  bottomSheetController.closed.then((value)async {
                                    if(filter != null){
                                      filter.delivery = true;
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString('filter', json.encode(filter.toMap()));
                                    }
                                    _con.refreshHome();
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: filter != null && !filter.delivery
                                      ? Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).delivery,
                                  style: TextStyle(
                                      color: filter != null && !filter.delivery
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            InkWell(
                              onTap: () async{
                                if(filter != null){
                                  filter.delivery = false;
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString('filter', json.encode(filter.toMap()));
                                }
                                setState(() {
                                  settingsRepo.deliveryAddress.value?.latitude =
                                      null;
                                  settingsRepo.deliveryAddress.value?.address =
                                      null;
                                });
                                _con.refreshHome();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: filter != null && filter.delivery
                                      ? Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).pickup,
                                  style: TextStyle(
                                      color: filter != null && filter.delivery
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value?.address != null && filter != null && filter.delivery)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context).near_to +
                                  " " +
                                  (settingsRepo.deliveryAddress.value?.address),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  );
                case 'top_markets':
                  return CardsCarouselWidget(
                      marketsList: _con.topMarkets,
                      heroTag: 'home_top_markets');
                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      leading: Image.asset("assets/img/trending_products.png",
                      height: 28,
                      width: 28,
                      color: Theme.of(context).hintColor),
                    title: Text(
                      S.of(context).trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                case 'trending_week':
                  return ProductsCarouselWidget(
                      productsList: _con.trendingProducts,
                      heroTag: 'home_product_carousel');
                  case 'featured_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      leading: Image.asset("assets/img/trending.png",
                      height: 28,
                      width: 28,
                      color: Theme.of(context).hintColor),
                    title: Text(
                      S.of(context).featured_products,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  );
                case 'featured':
                  return ProductsCarouselWidget(
                      productsList: _con.featuredProducts,
                      heroTag: 'home_product_carousel');
                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Image.asset("assets/img/product_categories.png",
                          height: 28,
                          width: 28,
                          color: Theme.of(context).hintColor),
                      title: Text(
                        S.of(context).product_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'categories':
                  return CategoriesCarouselWidget(
                    categories: _con.categories,
                  );
                case 'popular_heading':
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Image.asset("assets/img/most_popular.png",
                          height: 28,
                          width: 28,
                          color: Theme.of(context).hintColor),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'popular':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridWidget(
                      marketsList: _con.popularMarkets,
                      heroTag: 'home_markets',
                    ),
                  );
                /*case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  );*/
                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }

  void getFilter() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  }
}
