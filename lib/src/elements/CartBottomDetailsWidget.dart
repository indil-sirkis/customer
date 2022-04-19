import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:markets/src/models/market.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  Timing selectedTiming;

  DateTime startTime,endTime;
  DateTime currentTime;

  CartBottomDetailsWidget({
    Key key,
    @required CartController con,
  })  : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    currentTime = DateFormat('dd-MM-yyyy HH:mm').parse(DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()));
    if(_con.carts.isNotEmpty) {
      print("LEN:::${_con.carts
          .elementAt(0)
          .product
          .market
          .timing
          .length}");
      var day = DateFormat('EEEE').format(DateTime.now());
      for (int i = 0; i < _con.carts
          .elementAt(0)
          .product
          .market
          .timing
          .length; i++) {
        Timing timing = _con.carts
            .elementAt(0)
            .product
            .market
            .timing[i];
        if (timing.day == day) {
          selectedTiming = timing;
          String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
          startTime = DateFormat('dd-MM-yyyy HH:mm').parse('${today} ${selectedTiming.open}');
          endTime = DateFormat('dd-MM-yyyy HH:mm').parse('${today} ${selectedTiming.close}');
        }
      }
    }
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: 200,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: '0')
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      if (Helper.canDelivery(_con.carts[0].product.market, carts: _con.carts))
                        Helper.getPrice(_con.carts[0].product.market.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: S.of(context).free)
                      else
                        Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: S.of(context).free)
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 10),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: MaterialButton(
                          elevation: 0,
                          onPressed: () {
                            print("Start${startTime}");
                            print("endTime${endTime}");
                            if(!_con.carts[0].product.market.closed && (selectedTiming != null && selectedTiming.closedfull == 0) && (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))) {
                              bool isActive = true;
                              for(int i=0; i<_con.carts.length; i++){
                                if(!_con.carts[i].product.active){
                                  isActive = false;
                                }
                              }
                              if(isActive) {
                                _con.goCheckout(context);
                              }else{
                                Fluttertoast.showToast(msg: "Remove not available product");
                              }
                            }else{
                              Fluttertoast.showToast(msg: "Store closed");
                            }
                          },
                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          color: !_con.carts[0].product.market.closed && (selectedTiming != null && selectedTiming.closedfull == 0) && (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Text(
                            S.of(context).checkout,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(_con.total, context,
                            style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)), zeroPlaceholder: 'Free'),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
