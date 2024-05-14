import 'dart:convert';

TransactionModel transactionModelFromJson(String str) =>
    TransactionModel.fromJson(json.decode(str) as Map<String, dynamic>);
String transactionModelToJson(TransactionModel data) =>
    json.encode(data.toJson());

class TransactionModel {
  TransactionModel({
    this.from,
    this.to,
    this.amount,
    this.fee,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        from: json['from'] as String,
        to: json['to'] as String,
        amount:
            (json['amount'] == null) ? 0.0 : (json['amount'] as num).toDouble(),
        fee: (json['fee'] == null) ? 0.0 : (json['fee'] as num).toDouble(),
      );

  String? from;
  String? to;
  double? amount;
  double? fee;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'amount': amount,
        'fee': fee,
      };
}
