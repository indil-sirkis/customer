import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:markets/src/models/setting.dart';
import 'package:markets/src/repository/settings_repository.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_stripe/flutter_stripe.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState> scaffoldKey;
  model.Address deliveryAddress;
  PaymentMethodList list;
  Map<String, dynamic> paymentIntentData;

  DeliveryPickupController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    super.listenForCarts();
    listenForDeliveryAddress();
    print(settingRepo.deliveryAddress.value.toMap());
  }

  void listenForDeliveryAddress() async {
    this.deliveryAddress = settingRepo.deliveryAddress.value;
  }

  void addAddress(model.Address address) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
      });
    }).whenComplete(() {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).new_address_added_successfully),
      ));
    });
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
      });
    }).whenComplete(() {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).the_address_updated_successfully),
      ));
    });
  }

  PaymentMethods getPickUpMethod() {
    return list.pickupList.elementAt(0);
  }

  PaymentMethods getDeliveryMethod() {
    return list.pickupList.elementAt(1);
  }

  void toggleDelivery() {
    list.pickupList.forEach((element) {
      if (element != getDeliveryMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getDeliveryMethod().selected = !getDeliveryMethod().selected;
    });
  }

  void togglePickUp() {
    list.pickupList.forEach((element) {
      if (element != getPickUpMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected;
    });
  }

  PaymentMethods getSelectedMethod() {
    return list.pickupList.firstWhere((element) => element.selected,orElse: () {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).select_mode_of_delivery),
      ));
    });
  }

  @override
  void goCheckout(BuildContext context) {
    print("PRINT:::${total.toStringAsFixed(setting.value?.currencyDecimalDigits)}");
    if (getSelectedMethod() != null) {
      // if(getSelectedMethod().route == "/PayOnPickup") {
      //   Navigator.of(state.context).pushNamed(getSelectedMethod().route);
      // }else{
      // }
      Navigator.of(state.context).pushNamed(getSelectedMethod().route,arguments: RouteArgument(id:calculateAmount(total.toStringAsFixed(setting.value?.currencyDecimalDigits))));
      // checkout(context, total);
    }
  }
  Future<void> checkout(context,double total)async{
    Stripe.publishableKey = setting.value.stripe_key;
    /// retrieve data from the backend

    try {

      paymentIntentData =
      await createPaymentIntent(total, "USD"); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              applePay: true,
              googlePay: true,
              testEnv: true,
              style: ThemeMode.dark,
              merchantDisplayName: 'Indil')).then((value){
      });


      ///now finally display payment sheeet
      displayPaymentSheet(context);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(context) async {

    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
            clientSecret: paymentIntentData['client_secret'],
            confirmPayment: true,
          )).then((newValue){


        print('payment intent'+paymentIntentData['id'].toString());
        print('payment intent'+paymentIntentData['client_secret'].toString());
        print('payment intent'+paymentIntentData['amount'].toString());
        print('payment intent'+paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;

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
  createPaymentIntent(double amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount.toStringAsFixed(setting.value?.currencyDecimalDigits)),
        'currency': currency,
        'payment_method_types[]': 'card'
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
    final a = ((double.parse(amount)) * 100).toInt();
    return a.toString();
  }
}
