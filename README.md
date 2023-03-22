# kiteparser

This package is used to parse zerodha's kite websocket complex octet stream data to json model.
It uses the kite APIs version v3. You can check more information about it here,[kite-apis](https://kite.trade/docs/connect/v3/websocket)

## Pre requirements
* API_KEY : Sign up or login here. [kite developer](https://developers.kite.trade) Get it from console
* ACCESS_TOKEN : Follow mentioned here steps to get access token : [kite authentication](https://kite.trade/docs/connect/v3/user)

## Getting Started

Add as dependency in pubspec.yaml file

```dart
dependencies:
  flutter:
    sdk: flutter
  kiteparser: ^0.0.4
```

```dart
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
    print(list);
  }

  @override
  void onError(String error) {
    print(error);
  }
}
```


