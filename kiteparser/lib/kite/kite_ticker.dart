library kiteparser;

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'Depth.dart';
import 'Tick.dart';
export 'Tick.dart';

class KiteTicker {
  static String modeLTP = "ltp";
  static String modeFull = "full";
  static String modeQuote = "quote";
  static const String socketUrl = "wss://ws.kite.trade";
  IOWebSocketChannel? _client;
  final _mapListener = HashMap<String, OnDataListener>();
  final Map<num, Tick> latestList = HashMap();

  void setUpSocket(String apiKey, String accessToken,
      SocketConnectionListener connectionListener) {
    final wsUrl = "$socketUrl?api_key=$apiKey&access_token=$accessToken";

    WebSocket.connect(wsUrl).then((ws) {
      _client = IOWebSocketChannel(ws);
      if (_client != null) {
        connectionListener.onConnected(_client!);
        _client?.stream.listen((event) {
          // Debug.trace("DATA $event");
          if (event is! String && Uint8List.fromList(event).length > 3) {
            List<Tick> tickList = parseBinary(event);
            _mapListener.forEach((key, value) {
              _mapListener[key]?.onData(tickList);
            });
            setUpLatestList(tickList);
          }
        }, onError: (error) {
          if (kDebugMode) {
            print("ERROR $error");
          }
          connectionListener.onError(error);
        });
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print("ERROR $error");
      }
      connectionListener.onError(error.toString());
    });
  }

  void addDataListener(String tag, OnDataListener listener) {
    _mapListener[tag] = listener;
  }

  int getLengthFromByteArray(Uint8List bin) {
    ByteBuffer buffer = Int8List.fromList(bin).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getInt16(0);
  }

  Uint8List getBytes(Uint8List bin, int start, int end) {
    Uint8List newBin = Uint8List.fromList(bin);
    return newBin.sublist(start, end);
  }

  double convertToDouble(Uint8List bin) {
    ByteBuffer buffer = Int8List.fromList(bin).buffer;
    ByteData byteData = ByteData.view(buffer);

    if (bin.length < 4) {
      return byteData.getUint16(0).toDouble();
    } else {
      return bin.length < 8
          ? byteData.getInt32(0).toDouble()
          : byteData.getInt64(0).toDouble();
    }
  }

  int convertToLong(Uint8List bin) {
    ByteBuffer buffer = Int8List.fromList(bin).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getInt32(0);
  }

  List<Uint8List> splitPackets(Uint8List bin) {
    List<Uint8List> packets = [];
    int noOfPackets = getLengthFromByteArray(getBytes(bin, 0, 2));
    int j = 2;

    for (int i = 0; i < noOfPackets; ++i) {
      int sizeOfPacket = getLengthFromByteArray(getBytes(bin, j, j + 2));
      Uint8List packet = getBytes(bin, j + 2, j + 2 + sizeOfPacket);
      packets.add(packet);
      j = j + 2 + sizeOfPacket;
    }

    return packets;
  }

  Tick getLtpQuote(Uint8List bin, int x, int dec1, bool tradable) {
    Tick tick1 = Tick(
        mode: modeLTP,
        tradable: tradable,
        token: x,
        lastTradedPrice:
            convertToDouble(getBytes(bin, 4, 8)) / dec1.toDouble());
    return tick1;
  }

  void setChangeForTick(Tick tick, double lastTradedPrice, double closePrice) {
    if (closePrice != 0.0) {
      tick.setNetPriceChangeFromClosingPrice(
          (lastTradedPrice - closePrice) * 100.0 / closePrice);
    } else {
      tick.setNetPriceChangeFromClosingPrice(0.0);
    }
  }

  Tick getQuoteData(Uint8List bin, int x, int dec1, bool tradable) {
    double lastTradedPrice =
        convertToDouble(getBytes(bin, 4, 8)) / dec1.toDouble();
    double closePrice =
        convertToDouble(getBytes(bin, 40, 44)) / dec1.toDouble();
    Tick tick2 = Tick(
      mode: modeQuote,
      token: x,
      tradable: tradable,
      lastTradedPrice: lastTradedPrice,
      lastTradeQuantity: convertToDouble(getBytes(bin, 8, 12)),
      averageTradePrice:
          convertToDouble(getBytes(bin, 12, 16)) / dec1.toDouble(),
      volumeTradedToday: convertToLong(getBytes(bin, 16, 20)),
      totalBuyQuantity: convertToDouble(getBytes(bin, 20, 24)),
      totalSellQuantity: convertToDouble(getBytes(bin, 24, 28)),
      openPrice: convertToDouble(getBytes(bin, 28, 32)) / dec1.toDouble(),
      highPrice: convertToDouble(getBytes(bin, 32, 36)) / dec1.toDouble(),
      lowPrice: convertToDouble(getBytes(bin, 36, 40)) / dec1.toDouble(),
      closePrice: closePrice,
    );
    setChangeForTick(tick2, lastTradedPrice, closePrice);
    return tick2;
  }

  bool isValidDate(int date) {
    if (date <= 0) {
      return false;
    } else {
      try {
        DateTime calendar = DateTime.fromMillisecondsSinceEpoch(date);
        calendar.millisecond;
        return true;
      } catch (var5) {
        return false;
      }
    }
  }

  Tick getFullData(Uint8List bin, int dec, Tick tick) {
    int lastTradedtime = convertToLong(getBytes(bin, 44, 48)) * 1000;
    if (isValidDate(lastTradedtime)) {
      tick.setLastTradedTime(
          DateTime.fromMillisecondsSinceEpoch(lastTradedtime));
    } else {
      tick.setLastTradedTime(null);
    }

    tick.setOi(convertToDouble(getBytes(bin, 48, 52)));
    tick.setOpenInterestDayHigh(convertToDouble(getBytes(bin, 52, 56)));
    tick.setOpenInterestDayLow(convertToDouble(getBytes(bin, 56, 60)));
    int tickTimeStamp = convertToLong(getBytes(bin, 60, 64)) * 1000;
    if (isValidDate(tickTimeStamp)) {
      tick.setTickTimestamp(DateTime.fromMillisecondsSinceEpoch(tickTimeStamp));
    } else {
      tick.setTickTimestamp(null);
    }

    tick.setMarketDepth(getDepthData(bin, dec, 64, 184));
    return tick;
  }

  Map<String, List<Depth>> getDepthData(
      Uint8List bin, int dec, int start, int end) {
    Uint8List depthBytes = getBytes(bin, start, end);

    List<Depth> buy = [];
    List<Depth> sell = [];

    for (int k = 0; k < 10; ++k) {
      int s = k * 12;
      Depth depth = Depth();
      depth
          .setQuantity(convertToDouble(getBytes(depthBytes, s, s + 4)).toInt());
      depth.setPrice(
          convertToDouble(getBytes(depthBytes, s + 4, s + 8)) / dec.toDouble());
      depth.setOrders(
          convertToDouble(getBytes(depthBytes, s + 8, s + 10)).toInt());
      if (k < 5) {
        buy.add(depth);
      } else {
        sell.add(depth);
      }
    }

    Map<String, List<Depth>> depthMap = HashMap();
    depthMap["buy"] = buy;
    depthMap["sell"] = sell;
    return depthMap;
  }

  List<Tick> parseBinary(Uint8List binaryPackets) {
    List<Tick> ticks = [];
    List<Uint8List> packets = splitPackets(binaryPackets);

    for (int i = 0; i < packets.length; ++i) {
      Uint8List bin = packets[i];
      Uint8List t = getBytes(bin, 0, 4);
      int x = convertToLong(t).toInt();
      int segment = x & 255;
      int dec1 = segment == 3 ? 10000000 : (segment == 6 ? 10000 : 100);
      Tick tick;
      if (bin.length == 8) {
        tick = getLtpQuote(bin, x, dec1, segment != 9);
        ticks.add(tick);
      } else if (bin.length != 28 && bin.length != 32) {
        if (bin.length == 44) {
          tick = getQuoteData(bin, x, dec1, segment != 9);
          ticks.add(tick);
        } else if (bin.length == 184) {
          tick = getQuoteData(bin, x, dec1, segment != 9);
          tick.setMode(modeFull);
          ticks.add(getFullData(bin, dec1, tick));
        }
      } else {
        tick = getIndeciesData(bin, x, segment != 9);
        ticks.add(tick);
      }
    }

    return ticks;
  }

  Tick getIndeciesData(Uint8List bin, int x, bool tradable) {
    int dec = 100;
    Tick tick = Tick();
    tick.setMode(modeQuote);
    tick.setTradable(tradable);
    tick.setInstrumentToken(x);
    double lastTradedPrice =
        convertToDouble(getBytes(bin, 4, 8)) / dec.toDouble();
    tick.setLastTradedPrice(lastTradedPrice);
    tick.setHighPrice(convertToDouble(getBytes(bin, 8, 12)) / dec.toDouble());
    tick.setLowPrice(convertToDouble(getBytes(bin, 12, 16)) / dec.toDouble());
    tick.setOpenPrice(convertToDouble(getBytes(bin, 16, 20)) / dec.toDouble());
    double closePrice = convertToDouble(getBytes(bin, 20, 24)) / dec.toDouble();
    tick.setClosePrice(closePrice);
    setChangeForTick(tick, lastTradedPrice, closePrice);
    if (bin.length > 28) {
      tick.setMode(modeFull);
      int tickTimeStamp = convertToLong(getBytes(bin, 28, 32)) * 1000;
      if (isValidDate(tickTimeStamp)) {
        tick.setTickTimestamp(
            DateTime.fromMillisecondsSinceEpoch(tickTimeStamp));
      } else {
        tick.setTickTimestamp(null);
      }
    }

    return tick;
  }

  void removeListener(String tag) {
    _mapListener.remove(tag);
  }

  void setUpLatestList(List<Tick> tickList) {
    for (var value in tickList) {
      latestList[value.token!] = value;
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

abstract class SocketConnectionListener {
  void onConnected(IOWebSocketChannel client);

  void onError(String error);
}

abstract class OnDataListener {
  void onData(List<Tick> list);
}
