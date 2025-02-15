import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketHelper with ChangeNotifier {
  WebsocketHelper(this.channel) {
    connect();
    grantedForReturnItem();
  }

  Stream? broadCastStream;
  Timer? _reconnectTimer;
  WebSocketChannel? channel;
  bool isConnected = false;
  final Duration _reconnectDelay = Duration(seconds: 5);

  final verifikasiHasLogin = StreamController<Map>.broadcast();
  final checkUserHasBorrows = StreamController<String>.broadcast();
  final streamControllerAll = StreamController<Map>.broadcast();

  @override
  void dispose() {
    channel?.sink.close();

    verifikasiHasLogin.close();
    checkUserHasBorrows.close();
    streamControllerAll.close();
    _reconnectTimer!.cancel();
    super.dispose();
  }

  static Map jsonDecodes(dynamic jsons) {
    return json.decode(jsons);
  }

  void closeWebSocket() {
    if (channel != null) {
      channel?.sink.close();
      channel = null; // Clear the WebSocketChannel reference
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      broadCastStream = null;
      isConnected = false;
      notifyListeners();
    }
    notifyListeners();
  }

  void reconnet() async {
    closeWebSocket();
    try {
      if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
        _reconnectTimer = Timer(
          _reconnectDelay,
          () {
            print("attempting to reconnect .....");
            connect();
            notifyListeners();
          },
        );
      }
    } catch (e) {
      if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
        _reconnectTimer = Timer(
          _reconnectDelay,
          () {
            print("attempting to reconnect .....");
            connect();
            notifyListeners();
          },
        );
      }
      print(e);
    }
  }

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();
      broadCastStream?.listen(
        (message) async {
          // process code in another thread
          final streamData = await compute(jsonDecodes, message);

          switch (streamData['endpoint']) {
            case "VERIFIKASI":
              notifyListeners();
              verifikasiHasLogin.sink.add(streamData);
              break;

            case "CHECKUSER":
              checkUserHasBorrows.sink.add(streamData['message']);
              notifyListeners();
              print(streamData);
              break;
            default:
              notifyListeners();
              streamControllerAll.sink.add(streamData);
              break;
          }
        },
        onDone: () {
          print('connection close ');

          isConnected = false;
          reconnet();
          notifyListeners();
        },
        onError: (e) {
          print("$e  co");

          isConnected = false;
          reconnet();
          notifyListeners();
        },
      );

      isConnected = true;
      notifyListeners();
    } catch (e, s) {
      debugPrint("$e");
      debugPrint("$s");

      isConnected = false;
      reconnet();
      notifyListeners();
    }
  }

  //sent Frequent Request
  void getDataBorrow() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrow"}));
  }

  //sent once Request
  void getDataBorrowOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrowOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataCategoryUser() {
    channel?.sink.add(json.encode({"endpoint": "getDataCollectionAvaileble"}));
  }

  //sent once Request
  void getDataCategoryUserOnce() {
    channel?.sink
        .add(json.encode({"endpoint": "getDataCollectionAvailebleOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataAllCollection() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollection"}));
  }

  //sent once Request
  void getDataAllCollectionOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollectionOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataPending() {
    channel?.sink.add(json.encode({"endpoint": "getDataPending"}));
  }

  //sent once Request
  void getDataPendingOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataPendingOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getAllKeyCategory() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategory"}));
  }

  //sent once Request
  void getAllKeyCategoryOnce() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategoryOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataGranted() {
    channel?.sink.add(json.encode({"endpoint": "getDataGranted"}));
  }

  //sent once Request
  void getDataGrantedOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataGrantedOnce"}));
    notifyListeners();
  }

  void grantedForReturnItem() async {
    await for (var data in streamControllerAll.stream) {
      if (data['endpoint'] == "GRANTED") {
        if (data.containsKey('message')) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('hasBorrow');
          notifyListeners();
          return;
        }
      }
    }
  }

  void checkUserHasBorrow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    final now = DateTime.now();
    final lastRequest = DateTime.parse(
      prefs.getString('RequestUser') ??
          now.subtract(Duration(seconds: 2)).toIso8601String(),
    );
    if (now.difference(lastRequest).inSeconds >= 2) {
      print("tokenUser $getToken");
      if (getToken != null) {
        channel?.sink.add(
          json.encode(
            {
              "endpoint": "checkUserBorrow",
              "data": {
                "name": getToken,
              }
            },
          ),
        );
      }
      prefs.setString('RequestUser', now.toIso8601String());
    }
  }

// for first request
  void userHasBorrowsOnce() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    print("$getToken user name");

    channel?.sink.add(json.encode(
      {
        "endpoint": "hasBorrowOnce",
        "data": {
          "name": getToken ?? '',
        }
      },
    ));
  }

  void testDeleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasBorrow');
    return;
  }

  Future<Map> message() async {
    await Future.delayed(Duration(seconds: 10));
    return {"message": "respone"};
  }

  void sendMessage(Map<String, dynamic> message) {
    channel?.sink.add(
      json.encode(message),
    );
  }

  void sendRequestReturnItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    channel?.sink.add(
      json.encode(
        {
          'endpoint': "waitPermision",
          'data': {
            "name": getToken ?? "",
          }
        },
      ),
    );
  }

  Stream<String> verifikasi() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('token');

    try {
      DateTime now = DateTime.now();
      DateTime lastRequest = DateTime.parse(
        prefs.getString('lastRequest') ??
            now.subtract(Duration(minutes: 10)).toIso8601String(),
      );

      // debugPrint("$getToken token wsHelper");
      // debugPrint("${prefs.getString('lastRequest')} exp wsHelper");

      if (now.difference(lastRequest).inMinutes >= 10) {
        if (getToken != null) {
          channel?.sink.add(json.encode(
            {
              "endpoint": "verifikasi",
              "data": {
                "token": getToken,
              }
            },
          ));
        }
        prefs.setString('lastRequest', now.toIso8601String());
      }

      await for (final status in streamControllerAll.stream) {
        if (status['endpoint'] == "VERIFIKASI") {
          yield status['status'];
        }
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  Stream<Map> responseLogin() async* {
    Map data = {};

    await for (var map in streamControllerAll.stream) {
      if (map['endpoint'] == 'LOGIN') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<Map> responseRegister() async* {
    Map data = {};

    await for (var map in streamControllerAll.stream) {
      if (map['endpoint'] == 'RIGISTER') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }
}
