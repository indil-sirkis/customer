// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:stripe_payment/stripe_payment.dart';
//
// class StripeTransactionResponse {
//   String message;
//   bool success;
//   StripeTransactionResponse({this.message, this.success});
// }
//
// class StripeService {
//   static String apiBase = 'https://api.stripe.com/v1';
//   static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
//   static String secret = 'sk_test_51JMX2aEybuBT11PN9bmqgTvGuV7FA1QePFXtr5LopviPCNSCDBr1tO1nZIoA8ZTYxz7njT7nVrfj11wWRSglNYwA00P5JbR2om';
//   static Map<String, String> headers = {
//     'Authorization': 'Bearer ${StripeService.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };
//   static init() {
//     StripePayment.setOptions(
//         StripeOptions(
//             publishableKey: "pk_test_51JMX2aEybuBT11PNUy37nU5x5wpIPluslp5FaiBEzT6QTXtAQIQRfM3eUAVsTn5aX2qhS5yoxUsVY5VjSaVLId2200mr7b8bWt",
//             merchantId: "Test",
//             androidPayMode: 'test'
//         )
//     );
//   }
//
//   static Future<StripeTransactionResponse> payViaExistingCard({String amount, String currency, CreditCard card}) async{
//     try {
//       var paymentMethod = await StripePayment.createPaymentMethod(
//           PaymentMethodRequest(card: card)
//       );
//       var paymentIntent = await StripeService.createPaymentIntent(
//           amount,
//           currency
//       );
//       var response = await StripePayment.confirmPaymentIntent(
//           PaymentIntent(
//               clientSecret: paymentIntent['client_secret'],
//               paymentMethodId: paymentMethod.id
//           )
//       );
//
//       if (response.status == 'succeeded') {
//         return new StripeTransactionResponse(
//             message: 'Transaction successful',
//             success: true
//         );
//       } else {
//         return new StripeTransactionResponse(
//             message: 'Transaction failed',
//             success: false
//         );
//       }
//     } on PlatformException catch(err) {
//       return StripeService.getPlatformExceptionErrorResult(err);
//     } catch (err) {
//       print("err:::${err.toString()}");
//       return new StripeTransactionResponse(
//           message: 'Transaction failed: ${err.toString()}',
//           success: false
//       );
//     }
//   }
//
//   static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency}) async {
//     try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//           CardFormPaymentRequest()
//       );
//       var paymentIntent = await StripeService.createPaymentIntent(
//           amount,
//           currency
//       );
//       var response = await StripePayment.confirmPaymentIntent(
//           PaymentIntent(
//               clientSecret: paymentIntent['client_secret'],
//               paymentMethodId: paymentMethod.id
//           )
//       );
//       if (response.status == 'succeeded') {
//         return new StripeTransactionResponse(
//             message: 'Transaction successful',
//             success: true
//         );
//       } else {
//         return new StripeTransactionResponse(
//             message: 'Transaction failed',
//             success: false
//         );
//       }
//     } on PlatformException catch(err) {
//       return StripeService.getPlatformExceptionErrorResult(err);
//     } catch (err) {
//       return new StripeTransactionResponse(
//           message: 'Transaction failed: ${err.toString()}',
//           success: false
//       );
//     }
//   }
//
//   static getPlatformExceptionErrorResult(err) {
//     String message = 'Something went wrong';
//     if (err.code == 'cancelled') {
//       message = 'Transaction cancelled';
//     }
//
//     return new StripeTransactionResponse(
//         message: message,
//         success: false
//     );
//   }
//
//   static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//         'payment_method_types[]': 'card'
//       };
//       var response = await http.post(
//           Uri.parse(StripeService.paymentApiUrl),
//           body: body,
//           headers: StripeService.headers
//       );
//       print(response.body);
//       return jsonDecode(response.body);
//     } catch (err) {
//       print('err charging user: ${err.toString()}');
//     }
//     return null;
//   }
// }