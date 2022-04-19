import 'package:flutter/widgets.dart';

import '../../generated/l10n.dart';

class PaymentMethods {
  String id;
  String name;
  String description;
  String logo;
  String route;
  String amountTotal;
  bool isDefault;
  bool selected;

  PaymentMethods(this.id, this.name, this.description, this.route, this.logo, {this.isDefault = false, this.selected = false, this.amountTotal});
}

class PaymentMethodList {
  List<PaymentMethods> _paymentsList;
  List<PaymentMethods> _cashList;
  List<PaymentMethods> _pickupList;

  PaymentMethodList(BuildContext _context,String amountTotal) {
    this._paymentsList = [
      // new PaymentMethods("visacard", S.of(_context).visa_card, S.of(_context).click_to_pay_with_your_visa_card, "/Checkout", "assets/img/visacard.png",amountTotal: amountTotal,
          // isDefault: true),
      // new PaymentMethods("mastercard", S.of(_context).mastercard, S.of(_context).click_to_pay_with_your_mastercard, "/Checkout", "assets/img/mastercard.png",amountTotal: amountTotal),
      // new PaymentMethods("razorpay", S.of(_context).razorpay, S.of(_context).clickToPayWithRazorpayMethod, "/Checkout", "assets/img/razorpay.png",amountTotal: amountTotal),
      // new PaymentMethods("paypal", S.of(_context).paypal, S.of(_context).click_to_pay_with_your_paypal_account, "/Checkout", "assets/img/paypal.png",amountTotal: amountTotal),
      new PaymentMethods("stripe", S.of(_context).pay_online, S.of(_context).click_to_pay_online, "/Checkout", "assets/img/pay_card.png",amountTotal: amountTotal),
      // new PaymentMethods("apple", S.of(_context).pay_with_apple_pay, S.of(_context).click_to_pay_with_your_card, "/Apple", "assets/img/pay_card.png",amountTotal: amountTotal),
    ];
    this._cashList = [
      new PaymentMethods("cod", S.of(_context).cash_on_delivery, S.of(_context).tap_to_pay_cash_on_delivery, "/CashOnDelivery", "assets/img/cash.png"),
    ];
    this._pickupList = [
      new PaymentMethods("pop", S.of(_context).pay_on_pickup, S.of(_context).click_to_pay_on_pickup, "/PayOnPickup", "assets/img/pay_pickup.png"),
      new PaymentMethods("delivery", S.of(_context).delivery_address, S.of(_context).click_to_pay_on_pickup, "/PaymentMethod", "assets/img/pay_pickup.png"),
    ];
  }

  List<PaymentMethods> get paymentsList => _paymentsList;
  List<PaymentMethods> get cashList => _cashList;
  List<PaymentMethods> get pickupList => _pickupList;
}
