import 'dart:io';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  PaymentMethodsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  PaymentMethodList list;


  @override
  Widget build(BuildContext context) {
    list = new PaymentMethodList(context,widget.routeArgument.id);
    // if (!setting.value.payPalEnabled)
    //   list.paymentsList.removeWhere((element) {
    //     return element.id == "paypal";
    //   });
    // if (!setting.value.razorPayEnabled)
    //   list.paymentsList.removeWhere((element) {
    //     return element.id == "razorpay";
    //   });
    if (!setting.value.stripeEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "stripe";
      });
    // if (!Platform.isIOS)
    //   list.paymentsList.removeWhere((element) {
    //     return element.id == "apple";
    //   });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          S.of(context).payment_mode,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3,color: Theme.of(context).primaryColor)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).primaryColor, labelColor: Theme.of(context).primaryColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            list.paymentsList.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Image.asset("assets/img/payment.png",height: 40,width: 40),
                      title: Text(
                        S.of(context).payment_options,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(S.of(context).select_your_preferred_payment_mode),
                    ),
                  )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Image.asset("assets/img/payment.png",height: 40,width: 40),
                title: Text(
                  S.of(context).payment_options_close,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4.merge(TextStyle(fontSize: 16)),
                ),

                // subtitle: Text(S.of(context).select_your_preferred_payment_mode),
              ),
            ),
            SizedBox(height: 10),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.paymentsList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return PaymentMethodListItemWidget(paymentMethod: list.paymentsList.elementAt(index));
              },
            ),
            SizedBox(height: 10),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.cashList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return PaymentMethodListItemWidget(paymentMethod: list.cashList.elementAt(index));
              },
            ),
          ],
        ),
      ),
    );
  }


}
