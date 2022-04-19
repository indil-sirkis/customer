import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:markets/src/repository/settings_repository.dart';

import '../StripeService.dart';
import '../models/payment_method.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_stripe/flutter_stripe.dart';

// ignore: must_be_immutable
class PaymentMethodListItemWidget extends StatelessWidget {
  String heroTag;
  PaymentMethods paymentMethod;
  Map<String, dynamic> paymentIntentData;

  PaymentMethodListItemWidget({Key key, this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        print(this.paymentMethod.name);
        // Navigator.of(context).pushNamed(this.paymentMethod.route);
        if(this.paymentMethod.route == "/Checkout") {
          checkout(context, paymentMethod.amountTotal);
          // StripeService.init();
          // payViaExistingCard(context);
        }/*else if(this.paymentMethod.route == "/Apple") {
          checkoutApple(context, paymentMethod.amountTotal);
          // StripeService.init();
          // payViaExistingCard(context);
        }*/else{
          Navigator.of(context).pushNamed(this.paymentMethod.route);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              padding: EdgeInsets.all(10),
              child: Image.asset(paymentMethod.logo,fit: BoxFit.scaleDown),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          paymentMethod.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          paymentMethod.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<void> checkout(context,String total)async{
    print("TOTAL:::${setting.value.default_currency_code}::::${setting.value.defaultCurrency}");
    Stripe.publishableKey = setting.value.stripe_key;
    Stripe.merchantIdentifier = "merchant.com.app.Indil";
    await Stripe.instance.applySettings();
    /// retrieve data from the backend

    try {

      paymentIntentData =
      await createPaymentIntent(total, setting.value.default_currency_code); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              applePay: true,
              googlePay: false,
              style: ThemeMode.light,
              merchantCountryCode: 'GMD',
              merchantDisplayName: 'indil.gm')).then((value){
      });


      ///now finally display payment sheeet
      displayPaymentSheet(context);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(context) async {

    try {
      await Stripe.instance.presentPaymentSheet().then((newValue){


        print('payment intent'+paymentIntentData['id'].toString());
        print('payment intent'+paymentIntentData['client_secret'].toString());
        print('payment intent'+paymentIntentData['amount'].toString());
        print('payment intent'+paymentIntentData['card'].toString());
        print('payment intent'+paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));
        paymentIntentData = null;
        var param = {
          "method":"Credit Card (Stripe Gateway)",
          "status":"succeeded"
        };
        Navigator.of(context).pushNamed("/OrderSuccess",arguments: RouteArgument(param: param));
      }).onError((error, stackTrace){
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });


    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'setup_future_usage':'on_session',
        'use_stripe_sdk':'true',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer ${setting.value.stripe_secret}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100 ;
    return a.toString();
  }

  /*Future<void> checkoutApple(context,String total) async {
    total  = ((int.parse(total)) / 100).toString() ;
    Stripe.publishableKey = setting.value.stripe_key;
    Stripe.merchantIdentifier = "merchant.com.app.Indil";
    await Stripe.instance.applySettings();
    // await Stripe.instance.openApplePaySetup();
    try {
      // 1. Present Apple Pay sheet
      await Stripe.instance.presentApplePay(
        ApplePayPresentParams(
          cartItems: [
            ApplePayCartSummaryItem(
              label: 'Product',
              amount: total,
            ),
          ],
          country: setting.value.defaultCurrency,
          currency: setting.value.default_currency_code,
        ),
      );

      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret(total, setting.value.default_currency_code);
      final clientSecret = response['clientSecret'];

      // 2. Confirm apple pay payment
      await Stripe.instance.confirmApplePayPayment(clientSecret);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Apple Pay payment successfully completed')),
      );
      var param = {
        "method":"Apple Pay",
        "status":"succeeded"
      };
      Navigator.of(context).pushNamed("/OrderSuccess",arguments: RouteArgument(param: param));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret(String amount, String currency) async {
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    final response = await http.post(
      url,
      headers: {
        'Authorization':
        'Bearer ${setting.value.stripe_secret}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: json.encode({
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'setup_future_usage':'on_session',
        'use_stripe_sdk':'true',
      }),
    );
    return json.decode(response.body);
  }*/
}
