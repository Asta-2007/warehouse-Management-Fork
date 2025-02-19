import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketHelper with ChangeNotifier {
  WebsocketHelper(this.channel) {
    connect();
  }

  Stream? broadCastStream;
  Timer? _reconnectTimer;
  WebSocketChannel? channel;
  bool isConnected = false;
  final Duration _reconnectDelay = Duration(seconds: 5);

  final verifikasiHasLogin = StreamController<Map>.broadcast();
  final checkUserHasBorrows = StreamController<String>.broadcast();
  final streamControllerAll = StreamController<Map>.broadcast();
  final storage = FlutterSecureStorage();

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
            debugPrint("attempting to reconnect .....");
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
            debugPrint("attempting to reconnect .....");
            connect();
            notifyListeners();
          },
        );
      }
      debugPrint("error reconnect $e");
    }
  }

  void processConnectionServer(Stream? connections) {
    connections?.listen(
      (message) async {
        // process code in another thread
        final streamData = await compute(jsonDecodes, message);

        switch (streamData['endpoint']) {
          case "VERIFIKASI":
            print(streamData);
            notifyListeners();
            verifikasiHasLogin.sink.add(streamData);
            break;

          case "CHECKUSER":
            checkUserHasBorrows.sink.add(streamData['message']);
            notifyListeners();

            break;
          default:
            notifyListeners();
            streamControllerAll.sink.add(streamData);
            break;
        }
      },
      onDone: () {
        debugPrint('connection close ');

        isConnected = false;
        reconnet();
        notifyListeners();
      },
      onError: (e) {
        debugPrint("$e  connect");

        isConnected = false;
        reconnet();
        notifyListeners();
      },
    );
  }

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();
      await compute(processConnectionServer, broadCastStream);
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

  void checkUserHasBorrow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    final now = DateTime.now();
    final lastRequest = DateTime.parse(
      prefs.getString('RequestUser') ??
          now.subtract(Duration(seconds: 2)).toIso8601String(),
    );
    if (now.difference(lastRequest).inSeconds >= 2) {
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

    channel?.sink.add(json.encode(
      {
        "endpoint": "hasBorrowOnce",
        "data": {
          "name": getToken ?? '',
        }
      },
    ));
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

  Stream<String?> verifikasiLogin() async* {
    final token = await storage.read(key: 'token');
    await Future.delayed(Duration(microseconds: 1));
    yield token;
  }

  void chekVerifikasi() async {
    try {
      final getToken = await storage.read(key: 'token');

      if (getToken != null) {
        Timer.periodic(
          Duration(seconds: 10),
          (_) {
            channel?.sink.add(json.encode(
              {
                "endpoint": "verifikasi",
                "data": {
                  "token": getToken,
                }
              },
            ));

            print("token get $getToken");
            return;
          },
        );

        // To cancel the subscription later:
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  void removeTokenIfExp() async {
    await for (final status in verifikasiHasLogin.stream) {
      int count = 1;
      if (status['status'] == "NOT-VERIFIKASI") {
        notifyListeners();
        final getToken = await storage.read(key: 'token');
        await storage.delete(key: 'token');
        print("affter delete $getToken");
        count++;
        print("count $count");
        return;
      }
    }
  }
}
