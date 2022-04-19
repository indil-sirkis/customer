import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markets/src/elements/PaymentSettingsDialog.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../generated/l10n.dart';
import '../StripeService.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class CheckoutWidget extends StatefulWidget {
//  RouteArgument routeArgument;
//  CheckoutWidget({Key key, this.routeArgument}) : super(key: key);
  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  CheckoutController _con;
  String cardType = "";
  GlobalKey<FormState> _paymentSettingsFormKey = new GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController expireController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  
  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3,color: Theme.of(context).primaryColor)),
        ),
      ),
      body: _con.carts.isEmpty
          ? CircularLoadingWidget(height: 400)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 255),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.payment,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              S.of(context).add_your_card_details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        /*new CreditCardsWidget(
                            creditCard: _con.creditCard,
                            onChanged: (creditCard) {
                              _con.updateCreditCard(creditCard);
                            }),*/
                        Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 25),
                              width: 300,
                              height: 195,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(color: Theme
                                      .of(context)
                                      .hintColor
                                      .withOpacity(0.15), blurRadius: 20, offset: Offset(0, 5)),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 21),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _con.creditCard.number != null ?detectCCType(_con.creditCard.number) == CreditCardType.mastercard ? IconButton(onPressed: (){}, icon: SvgPicture.asset("assets/img/mastercard.svg")) : detectCCType(_con.creditCard.number)  == CreditCardType.visa ? IconButton(onPressed: (){}, icon: SvgPicture.asset("assets/img/visa.svg")):SizedBox() : SizedBox(),
                                        ButtonTheme(
                                          padding: EdgeInsets.all(0),
                                          minWidth: 50.0,
                                          height: 10.0,
                                          child: PaymentSettingsDialog(
                                            creditCard: _con.creditCard,
                                            onChanged: () {
                                              _con.updateCreditCard(_con.creditCard);
                                              var type = detectCCType(_con.creditCard.number);
                                              print("TYPE::::${type}");
                                              if (type == CreditCardType.visa) {
                                                cardType = "Visa";
                                              } else if (type == CreditCardType.mastercard) {
                                                cardType = "MasterCard";
                                              } else if (type == CreditCardType.amex) {
                                                cardType = "Amex";
                                              } else if (type == CreditCardType.discover) {
                                                cardType = "Discover";
                                              } else if (type == CreditCardType.dinersclub) {
                                                cardType = "DinersClub";
                                              } else if (type == CreditCardType.jcb) {
                                                cardType = "Jcb";
                                              } else if (type == CreditCardType.unionpay) {
                                                cardType = "UnionPay";
                                              } else if (type == CreditCardType.maestro) {
                                                cardType = "Maestro";
                                              }else if (type == CreditCardType.unknown) {
                                                cardType = "Unknown";
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      S.of(context)
                                          .card_number,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .caption,
                                    ),
                                    Text(
                                      _con.creditCard.number,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1
                                          .merge(TextStyle(letterSpacing: 1.4)),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          S
                                              .of(context)
                                              .expiry_date,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                        Text(
                                          S.of(context)
                                              .cvv,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          '${_con.creditCard.expMonth}/${_con.creditCard.expYear}',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .merge(TextStyle(letterSpacing: 1.4)),
                                        ),
                                        Text(
                                            '${_con.creditCard.cvc.replaceAll(RegExp(r"."), "*")}',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .merge(TextStyle(letterSpacing: 1.4)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 255,
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
                              Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).delivery_fee,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(_con.carts[0].product.market.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          Divider(height: 30),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).total,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline6)
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 40,
                            child: MaterialButton(
                              elevation: 0,
                              onPressed: () {
                                if (_con.creditCard.validated()) {
                                  // StripeService.init();
                                  // payViaExistingCard(context);
                                  Navigator.of(context).pushNamed('/OrderSuccess', arguments: new RouteArgument(param: 'Credit Card (Stripe Gateway)'));
                                } else {
                                  ScaffoldMessenger.of(_con.scaffoldKey?.currentContext).showSnackBar(SnackBar(
                                    content: Text(S.of(context).your_credit_card_not_valid),
                                  ));
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 14),
                              color: Theme.of(context).accentColor,
                              shape: StadiumBorder(),
                              child: Text(
                                S.of(context).confirm_payment,
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  
  /*payViaExistingCard(BuildContext context) async {
    // var expiryArr = card['expiryDate'].split('/');
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(
        message: 'Please wait...'
    );
    await dialog.show();
    CreditCard stripeCard = CreditCard(
        number: _con.creditCard.number,
        expMonth: int.parse(_con.creditCard.expMonth),
        expYear: int.parse(_con.creditCard.expYear),
        cvc: _con.creditCard.cvc,
        name: currentUser.value.name
    );
    var response = await StripeService.payViaExistingCard(
        amount: calculateAmount(_con.total
            .toStringAsFixed(setting.value?.currencyDecimalDigits)),
        currency: setting.value.default_currency_code,
        card: stripeCard
    );
    await dialog.hide();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          duration: new Duration(milliseconds: 1200),
        )
    ).closed.then((_) {
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/OrderSuccess', arguments: new RouteArgument(param: 'Credit Card (Stripe Gateway)'));
    });
  }*/
  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
  void addCard(){
    numberController.text = _con.creditCard.number.isNotEmpty ? _con.creditCard.number : "";
    expireController.text = _con.creditCard.expMonth.isNotEmpty ? _con.creditCard.expMonth + '/' + _con.creditCard.expYear : "";
    cvvController.text = _con.creditCard.cvc.isNotEmpty ? _con.creditCard.cvc : null;
    _con.scaffoldKey.currentState.showBottomSheet(
        (context)  =>
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom
            ),
            child: Container(
                child: Wrap(
                  children: [
                    Column(
                      children: <Widget>[
                        Row(
                          children: [
                            InkWell(onTap:(){
                              setState(() {
                                numberController.text = "";
                                expireController.text = "";
                                cvvController.text = "";
                                _con.creditCard.number = "";
                                _con.creditCard.expYear = "";
                                _con.creditCard.expMonth = "";
                                _con.creditCard.cvc = "";
                              });
                            },child: Padding(padding: EdgeInsets.only(top: 23,left: 16,right: 16,bottom: 30),child: Text("Clear All",style: GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 11,color: Colors.black.withOpacity(0.5)),))),
                            Expanded(child: Padding(padding: EdgeInsets.only(top: 23,left: 16,right: 16,bottom: 30),child: Center(child: Text("Card Details",style: GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.black))))),
                            InkWell(onTap:(){
                              print("VAL:::${_paymentSettingsFormKey.currentState.validate()}");
                              _submit(context);
                            },child: Padding(padding: EdgeInsets.only(top: 23,left: 16,right: 16,bottom: 30),child: Text("Done",style: GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: 11,color: Theme.of(context).accentColor),)))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16,right: 16),
                          child: Form(
                            key: _paymentSettingsFormKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    new LengthLimitingTextInputFormatter(16),
                                    new CardNumberInputFormatter()
                                  ],
                                  controller: numberController,
                                  style: TextStyle(color: Theme.of(context).hintColor),
                                  keyboardType: TextInputType.number,
                                  decoration: getInputDecoration(hintText: 'XXXX XXXX XXXX XXXX', labelText: S.of(context).number),
                                  validator: (input) {
                                    print(input.trim().length);
                                    return input.trim().length < 19 ? S.of(context).not_a_valid_number : null;
                                  },
                                  onSaved: (input) => _con.creditCard.number = input,
                                ),
                                SizedBox(height: 13),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            new LengthLimitingTextInputFormatter(4),
                                            new CardMonthInputFormatter()
                                          ],
                                          controller: expireController,
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                          keyboardType: TextInputType.number,
                                          decoration: getInputDecoration(hintText: 'MM/YY', labelText: S.of(context).exp_date),
                                          // TODO validate date
                                          validator: (input) => !input.contains('/') || input.length != 5 ? S.of(context).not_a_valid_date : null,
                                          onSaved: (input) {
                                            _con.creditCard.expMonth = input.split('/').elementAt(0);
                                            _con.creditCard.expYear = input.split('/').elementAt(1);
                                          }),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          new LengthLimitingTextInputFormatter(3),
                                        ],
                                        controller: cvvController,
                                        obscureText: true,
                                        style: TextStyle(color: Theme.of(context).hintColor),
                                        keyboardType: TextInputType.number,
                                        decoration: getInputDecoration(hintText: 'XXX', labelText: S.of(context).cvc),
                                        validator: (input) => input.trim().length != 3 ? S.of(context).not_a_valid_cvc : null,
                                        onSaved: (input) => _con.creditCard.cvc = input,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    )
                  ],
                )
            ),
          ),
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(
              top: Radius
                  .circular(
                  20))),
        );
  }
  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).focusColor),
      ),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
        TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  void _submit(BuildContext context) {
    print("VAL:::${_paymentSettingsFormKey.currentState.validate()}");
    if (_paymentSettingsFormKey.currentState.validate()) {
      _paymentSettingsFormKey.currentState.save();
      _con.updateCreditCard(_con.creditCard);
      var type = detectCCType(_con.creditCard.number);
      print("TYPE::::${type}");
      if (type == CreditCardType.visa) {
        cardType = "Visa";
      } else if (type == CreditCardType.mastercard) {
        cardType = "MasterCard";
      } else if (type == CreditCardType.amex) {
        cardType = "Amex";
      } else if (type == CreditCardType.discover) {
        cardType = "Discover";
      } else if (type == CreditCardType.dinersclub) {
        cardType = "DinersClub";
      } else if (type == CreditCardType.jcb) {
        cardType = "Jcb";
      } else if (type == CreditCardType.unionpay) {
        cardType = "UnionPay";
      } else if (type == CreditCardType.maestro) {
        cardType = "Maestro";
      }else if (type == CreditCardType.unknown) {
        cardType = "Unknown";
      }
      setState(() {});
      Navigator.pop(context);
    }
  }
}
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
