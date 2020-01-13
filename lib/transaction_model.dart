import 'package:jiffy/jiffy.dart';

class TransactionModel {
  String id;
  double amount = 0;
  double fee = 0;
  double net = 0;
  Jiffy created;

  TransactionModel.fromMap(Map data) {
    var amt = data["amount"] ?? 0;
    var fee = data["fee"] ?? 0;
    var net = data["net"] ?? 0;
    var date = data["created"] != null ? Jiffy.unix(data["created"]) : null;

    this.id = data["id"] ?? null;
    this.created = date;

    this.fee = fee > 0 ? fee / 100 : 0;
    this.net = net > 0 ? net / 100 : 0;
    this.amount = amt > 0 ? amt / 100 : 0;
  }

  Map toMap() {
    return {
      "id": this.id,
      "created": "${this.created.yMd}",
      "amount": this.amount,
      "net": this.net,
      "fee": this.fee,
    };
  }

  String toString() {
    return "$id, $amount, $fee, $net, ${this.created.yMd}";
  }
}