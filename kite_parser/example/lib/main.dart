import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiteparser/kite/kite_ticker.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    implements SocketConnectionListener, OnDataListener {
  final kiteTicker = KiteTicker();

  @override
  void initState() {
    super.initState();
    kiteTicker.setUpSocket(
        'your api key', 'your access token got from login', this);
    kiteTicker.addDataListener('home', this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kite Websocket example'),
        ),
        body: const Center(
          child: Text(''),
        ),
      ),
    );
  }

  @override
  void onConnected(IOWebSocketChannel client) {
    ///Here you can subscribe any instruments
    ///
    client.sink.add(jsonEncode({
      "a": "subscribe",
      "v": [408065, 884737]
    }));
  }

  @override
  void onData(List<Tick> list) {
    if (kDebugMode) {
      print(list);
    }
  }

  @override
  void onError(String error) {
    if (kDebugMode) {
      print(error);
    }
  }
}
