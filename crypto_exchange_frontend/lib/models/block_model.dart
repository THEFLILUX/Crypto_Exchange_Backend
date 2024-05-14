import 'dart:convert';

import 'package:crypto_exchange_frontend/models/models.dart';

BlockModel blockModelFromJson(String str) =>
    BlockModel.fromJson(json.decode(str) as Map<String, dynamic>);
String blockModelToJson(BlockModel data) => json.encode(data.toJson());

class BlockModel {
  BlockModel({
    required this.id,
    required this.index,
    required this.previousHash,
    required this.proof,
    required this.timestamp,
    required this.miner,
    required this.signature,
    required this.transaction,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
        id: json['id'] as String,
        index: json['index'] as int,
        previousHash: json['previousHash'] as String,
        proof: (json['proof'] == null) ? 0 : json['proof'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        miner: json['miner'] as String,
        signature: json['signature'] as String,
        transaction: TransactionModel.fromJson(
          json['transaction'] as Map<String, dynamic>,
        ),
      );

  String id;
  int index;
  String previousHash;
  int proof;
  DateTime timestamp;
  String miner;
  String signature;
  TransactionModel transaction;

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'previousHash': previousHash,
        'proof': proof,
        'timestamp': timestamp.toIso8601String(),
        'miner': miner,
        'signature': signature,
        'transaction': transaction.toJson(),
      };
}
