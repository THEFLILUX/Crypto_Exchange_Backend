import 'dart:convert';

import 'package:crypto_exchange_frontend/preferences/aes_encrypt.dart';

UserResponse userResponseFromJson(String str) =>
    UserResponse.fromJson(json.decode(str) as Map<String, dynamic>);
String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  UserResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        status: json['status'] as int,
        message: json['message'] as String,
        data: json['data'] == null
            ? []
            : List<UserModel>.from(
                (json['data'] as List<dynamic>)
                    .map((x) => UserModel.fromJson(x as Map<String, dynamic>)),
              ),
      );

  int status;
  String message;
  List<UserModel> data;

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

UserModel userModelFromJson(String str) =>
    UserModel.fromJson(json.decode(str) as Map<String, dynamic>);
String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.country,
    this.email,
    this.password,
    this.publicKey,
    this.privateKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        firstName: AESEncrypt.decryptString(json['firstName'] as String),
        lastName: AESEncrypt.decryptString(json['lastName'] as String),
        country: AESEncrypt.decryptString(json['country'] as String),
        email: json['email'] as String,
        password: (json['password'] == null)
            ? ''
            : AESEncrypt.decryptString(json['password'] as String),
        publicKey: json['publicKey'] as String? ?? '',
        privateKey: json['privateKey'] as String? ?? '',
      );

  String? id;
  String? firstName;
  String? lastName;
  String? country;
  String? email;
  String? password;
  String? publicKey;
  String? privateKey;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName':
            (firstName == null) ? '' : AESEncrypt.encryptString(firstName!),
        'lastName':
            (lastName == null) ? '' : AESEncrypt.encryptString(lastName!),
        'country': (country == null) ? '' : AESEncrypt.encryptString(country!),
        'email': email,
        'password': AESEncrypt.encryptString(password!),
        'publicKey': publicKey,
        'privateKey': privateKey,
      };

  UserModel copy() => UserModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        country: country,
        email: email,
        password: password,
        publicKey: publicKey,
        privateKey: privateKey,
      );
}
