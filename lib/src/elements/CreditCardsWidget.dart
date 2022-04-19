import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentSettingsDialog.dart';
import '../helpers/helper.dart';
import '../models/credit_card.dart';

// ignore: must_be_immutable
class CreditCardsWidget extends StatefulWidget {
  CreditCard creditCard;
  ValueChanged<CreditCard> onChanged;

  CreditCardsWidget({
    this.creditCard,
    this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  _CreditCardsWidgetState createState() => _CreditCardsWidgetState();

}
class _CreditCardsWidgetState extends State<CreditCardsWidget> {

  String cardType = "";
  GlobalKey<FormState> _paymentSettingsFormKey = new GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController expireController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var type = detectCCType(widget.creditCard.number);
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
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    Text(cardType,
                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                    ButtonTheme(
                      padding: EdgeInsets.all(0),
                      minWidth: 50.0,
                      height: 10.0,
                      child: PaymentSettingsDialog(
                        creditCard: widget.creditCard,
                        onChanged: () {
                          widget.onChanged(widget.creditCard);
                          var type = detectCCType(widget.creditCard.number);
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
                  widget.creditCard.number,
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
                      S
                          .of(context)
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
                      '${widget.creditCard.expMonth}/${widget.creditCard.expYear}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .merge(TextStyle(letterSpacing: 1.4)),
                    ),
                    Text(
                      widget.creditCard.cvc,
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
    );
  }

  void addCard(){
    numberController.text = widget.creditCard.number.isNotEmpty ? widget.creditCard.number : "";
    expireController.text = widget.creditCard.expMonth.isNotEmpty ? widget.creditCard.expMonth + '/' + widget.creditCard.expYear : "";
    cvvController.text = widget.creditCard.cvc.isNotEmpty ? widget.creditCard.cvc : null;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.vertical(
                top: Radius
                    .circular(
                    20))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext
              context,
                  StateSetter
                  setStates) {
                return Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            InkWell(onTap:(){
                              setStates(() {
                                numberController.text = "";
                                expireController.text = "";
                                cvvController.text = "";
                                widget.creditCard.number = "";
                                widget.creditCard.expYear = "";
                                widget.creditCard.expMonth = "";
                                widget.creditCard.cvc = "";
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
                                new TextFormField(
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
                                  onSaved: (input) => widget.creditCard.number = input,
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
                                            widget.creditCard.expMonth = input.split('/').elementAt(0);
                                            widget.creditCard.expYear = input.split('/').elementAt(1);
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
                                        onSaved: (input) => widget.creditCard.cvc = input,
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
                );
              });
        });
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
      widget.onChanged(widget.creditCard);
      var type = detectCCType(widget.creditCard.number);
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