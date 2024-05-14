import 'dart:convert';

import 'package:crypto_exchange_frontend/models/models.dart';
import 'package:crypto_exchange_frontend/preferences/preferences.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;

class BlockService extends ChangeNotifier {
  BlockService() {
    getUsersAndBalance();
  }

  // URL Backend
  // final List<String> _baseUrl = ['20.222.41.230', '40.124.84.39'];
  final String _baseUrl = '127.0.0.1:80';

  List<UserModel> availableUsers = [];
  double balance = 0;
  late UserModel selectedUser;

  List<BlockModel> blocks = [];
  List<MinerModel> miners = [];

  bool isLoadingUsersAndBalance = false;
  bool isLoadingBlockchain = false;
  bool isLoadingMiners = false;

  int verificationState = 0;
  String verificationMessage = '';

  Future<List<UserModel>> getUsersAndBalance() async {
    isLoadingUsersAndBalance = true;
    notifyListeners();

    // Hacer request para obtener el saldo del usuario
    balance = await getUserBalance(initialLoad: true);

    // Hacer request para obtener la lista de usuarios disponibles
    // final urlUsers = Uri.http(_baseUrl[0], '/getAvailableUsers/${Preferences.userEmail}');
    final urlUsers =
        Uri.http(_baseUrl, '/getAvailableUsers/${Preferences.userEmail}');
    final responseUsers = await http.get(urlUsers);
    final decodedUsers =
        json.decode(responseUsers.body) as Map<String, dynamic>?;

    if (decodedUsers == null) {
      isLoadingUsersAndBalance = false;
      notifyListeners();
      return [];
    }

    if (decodedUsers['data'] == null) {
      isLoadingUsersAndBalance = false;
      notifyListeners();
      return [];
    }

    final userResponse = userResponseFromJson(responseUsers.body);
    availableUsers = userResponse.data;

    isLoadingUsersAndBalance = false;
    notifyListeners();

    return availableUsers;
  }

  Future<double> getUserBalance({required bool initialLoad}) async {
    if (!initialLoad) {
      isLoadingUsersAndBalance = true;
      notifyListeners();
    }

    // final urlBalance = Uri.http(_baseUrl[0], '/getBalance/${Preferences.userEmail}');
    final urlBalance =
        Uri.http(_baseUrl, '/getBalance/${Preferences.userEmail}');
    final responseBalance = await http.get(urlBalance);
    final decodedBalance =
        json.decode(responseBalance.body) as Map<String, dynamic>?;

    if (decodedBalance == null) {
      balance = 0;
      if (!initialLoad) {
        isLoadingUsersAndBalance = false;
        notifyListeners();
      }
      return 0;
    } else {
      balance =
          ((decodedBalance['data'] as Map<String, dynamic>)['balance'] as num)
              .toDouble();
      if (!initialLoad) {
        isLoadingUsersAndBalance = false;
        notifyListeners();
      }
      return ((decodedBalance['data'] as Map<String, dynamic>)['balance']
              as num)
          .toDouble();
    }
  }

  Future<String?> newTransaction(
    TransactionModel transaction,
    String signature,
  ) async {
    // Enviar request al servidor principal o réplica
    // Random r = Random();
    // bool isMain = r.nextBool();
    // String selectedServer = (isMain) ? _baseUrl[0] : _baseUrl[1];

    // Hacer request para crear la transacción
    // final url = Uri.http(selectedServer, '/newTransaction', {'signature': signature});
    final url = Uri.http(_baseUrl, '/newTransaction', {'signature': signature});
    final response =
        await http.post(url, body: transactionModelToJson(transaction));
    final decodedData = json.decode(response.body) as Map<String, dynamic>?;

    if (decodedData == null) {
      return 'Error de conexión con el servidor';
    }

    if (decodedData['status'] == 200) {
      return null;
    } else {
      return decodedData['message'] as String;
    }
  }

  Future<List<BlockModel>> getBlockchain() async {
    isLoadingBlockchain = true;
    notifyListeners();

    // Hacer request para obtener la lista de bloques
    // final url = Uri.http(_baseUrl[0], '/getBlockchain');
    final url = Uri.http(_baseUrl, '/getBlockchain');
    final response = await http.get(url);
    final decodedData = json.decode(response.body) as Map<String, dynamic>?;

    if (decodedData == null) {
      isLoadingBlockchain = false;
      notifyListeners();
      return [];
    }

    if (decodedData['data'] == null) {
      isLoadingBlockchain = false;
      notifyListeners();
      return [];
    }

    blocks = decodedData['data'] == null
        ? []
        : List<BlockModel>.from(
            (decodedData['data'] as List<dynamic>).map(
              (block) => BlockModel.fromJson(block as Map<String, dynamic>),
            ),
          );

    isLoadingBlockchain = false;
    notifyListeners();

    return blocks;
  }

  Future<List<MinerModel>> getMiners() async {
    isLoadingMiners = true;
    notifyListeners();

    // Hacer request para obtener la lista de mineros
    // final url = Uri.http(_baseUrl[0], '/getMiners');
    final url = Uri.http(_baseUrl, '/getMiners');
    final response = await http.get(url);
    final decodedData = json.decode(response.body) as Map<String, dynamic>?;

    if (decodedData == null) {
      isLoadingMiners = false;
      notifyListeners();
      return [];
    }

    if (decodedData['data'] == null) {
      isLoadingMiners = false;
      notifyListeners();
      return [];
    }

    miners = decodedData['data'] == null
        ? []
        : List<MinerModel>.from(
            (decodedData['data'] as List<dynamic>).map(
              (miner) => MinerModel.fromJson(miner as Map<String, dynamic>),
            ),
          );

    isLoadingMiners = false;
    notifyListeners();

    return miners;
  }

  Future<String?> verifyBlockchain() async {
    verificationState = 1;
    notifyListeners();

    // Hacer request para verificar la blockchain
    // final url = Uri.http(_baseUrl[0], '/validateBlockchain');
    final url = Uri.http(_baseUrl, '/validateBlockchain');
    final response = await http.get(url);
    final decodedData = json.decode(response.body) as Map<String, dynamic>?;
    debugPrint(decodedData.toString());

    if (decodedData == null) {
      verificationState = 3;
      verificationMessage = 'Error de conexión con el servidor';
      notifyListeners();
      return 'Error de conexión con el servidor';
    }

    if (decodedData['status'] == 200) {
      verificationState = 2;
      verificationMessage = decodedData['message'] as String;
      notifyListeners();
      return null;
    } else {
      verificationState = 3;
      verificationMessage = decodedData['message'] as String;
      notifyListeners();
      return decodedData['message'] as String;
    }
  }

  void setInitialVerificationState() {
    verificationState = 0;
    notifyListeners();
  }
}
