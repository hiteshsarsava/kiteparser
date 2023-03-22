library kiteparser;

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:kiteparser/kite/depth.dart';
import 'package:kiteparser/kite/tick.dart';
import 'package:web_socket_channel/io.dart';

export 'tick.dart';

///This class is used to connect to kite web socket and allow parsing of socket data
class KiteTicker {
  static String modeLTP = "ltp";
  static String modeFull = "full";
  static String modeQuote = "quote";
  static const String socketUrl = "wss://ws.kite.trade";
  IOWebSocketChannel? _client;
  final _mapListener = HashMap<String, OnDataListener>();
  final Map<num, Tick> latestList = HashMap();

  ///Set up the connection to kite websocket end points
  ///@apiKey Get it from developer console
  ///@accessToken Get it from login
  ///@connectionListener implement this to class where you want callback after connection successfull
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
            List<Tick> tickList = _parseBinary(event);
            _mapListener.forEach((key, value) {
              _mapListener[key]?.onData(tickList);
            });
            _setUpLatestList(tickList);
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

  ///Attach listener to get the real time socket data
  ///@listener implement this in class where you want listen for data check example
  void addDataListener(String tag, OnDataListener listener) {
    _mapListener[tag] = listener;
  }

  ///Returns length of packet by reading byte array values.
  int _getLengthFromByteArray(Uint8List bin) {
    ByteBuffer buffer = Int8List.fromList(bin).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getInt16(0);
  }

  ///Reads values of specified position in byte array.
  Uint8List _getBytes(Uint8List bin, int start, int end) {
    Uint8List newBin = Uint8List.fromList(bin);
    return newBin.sublist(start, end);
  }

  ///Convert binary data to double datatype
  double _convertToDouble(Uint8List bin) {
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

  ///Convert binary data to long datatype
  int _convertToLong(Uint8List bin) {
    ByteBuffer buffer = Int8List.fromList(bin).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getInt32(0);
  }

  ///Each byte stream contains many packets. This method reads first two bits
  ///and calculates number of packets in the byte stream and split it.
  List<Uint8List> _splitPackets(Uint8List bin) {
    List<Uint8List> packets = [];
    int noOfPackets = _getLengthFromByteArray(_getBytes(bin, 0, 2));
    int j = 2;

    for (int i = 0; i < noOfPackets; ++i) {
      int sizeOfPacket = _getLengthFromByteArray(_getBytes(bin, j, j + 2));
      Uint8List packet = _getBytes(bin, j + 2, j + 2 + sizeOfPacket);
      packets.add(packet);
      j = j + 2 + sizeOfPacket;
    }

    return packets;
  }

  ///Parses LTP data.
  Tick _getLtpQuote(Uint8List bin, int x, int dec1, bool tradable) {
    Tick tick1 = Tick(
        mode: modeLTP,
        tradable: tradable,
        token: x,
        lastTradedPrice:
            _convertToDouble(_getBytes(bin, 4, 8)) / dec1.toDouble());
    return tick1;
  }

  void _setChangeForTick(Tick tick, double lastTradedPrice, double closePrice) {
    if (closePrice != 0.0) {
      tick.setNetPriceChangeFromClosingPrice(
          (lastTradedPrice - closePrice) * 100.0 / closePrice);
    } else {
      tick.setNetPriceChangeFromClosingPrice(0.0);
    }
  }

  ///Get quote data (last traded price, last traded quantity, average traded price,
  /// volume, total bid(buy quantity), total ask(sell quantity), open, high, low, close.)
  Tick _getQuoteData(Uint8List bin, int x, int dec1, bool tradable) {
    double lastTradedPrice =
        _convertToDouble(_getBytes(bin, 4, 8)) / dec1.toDouble();
    double closePrice =
        _convertToDouble(_getBytes(bin, 40, 44)) / dec1.toDouble();
    Tick tick2 = Tick(
      mode: modeQuote,
      token: x,
      tradable: tradable,
      lastTradedPrice: lastTradedPrice,
      lastTradeQuantity: _convertToDouble(_getBytes(bin, 8, 12)),
      averageTradePrice:
          _convertToDouble(_getBytes(bin, 12, 16)) / dec1.toDouble(),
      volumeTradedToday: _convertToLong(_getBytes(bin, 16, 20)),
      totalBuyQuantity: _convertToDouble(_getBytes(bin, 20, 24)),
      totalSellQuantity: _convertToDouble(_getBytes(bin, 24, 28)),
      openPrice: _convertToDouble(_getBytes(bin, 28, 32)) / dec1.toDouble(),
      highPrice: _convertToDouble(_getBytes(bin, 32, 36)) / dec1.toDouble(),
      lowPrice: _convertToDouble(_getBytes(bin, 36, 40)) / dec1.toDouble(),
      closePrice: closePrice,
    );
    _setChangeForTick(tick2, lastTradedPrice, closePrice);
    return tick2;
  }

  ///Validate date of last updated tick
  bool _isValidDate(int date) {
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

  ///Parses full mode data.
  Tick _getFullData(Uint8List bin, int dec, Tick tick) {
    int lastTradedtime = _convertToLong(_getBytes(bin, 44, 48)) * 1000;
    if (_isValidDate(lastTradedtime)) {
      tick.setLastTradedTime(
          DateTime.fromMillisecondsSinceEpoch(lastTradedtime));
    } else {
      tick.setLastTradedTime(null);
    }

    tick.setOi(_convertToDouble(_getBytes(bin, 48, 52)));
    tick.setOpenInterestDayHigh(_convertToDouble(_getBytes(bin, 52, 56)));
    tick.setOpenInterestDayLow(_convertToDouble(_getBytes(bin, 56, 60)));
    int tickTimeStamp = _convertToLong(_getBytes(bin, 60, 64)) * 1000;
    if (_isValidDate(tickTimeStamp)) {
      tick.setTickTimestamp(DateTime.fromMillisecondsSinceEpoch(tickTimeStamp));
    } else {
      tick.setTickTimestamp(null);
    }

    tick.setMarketDepth(_getDepthData(bin, dec, 64, 184));
    return tick;
  }

  ///Reads all bytes and returns map of depth values for offer and bid
  Map<String, List<Depth>> _getDepthData(
      Uint8List bin, int dec, int start, int end) {
    Uint8List depthBytes = _getBytes(bin, start, end);

    List<Depth> buy = [];
    List<Depth> sell = [];

    for (int k = 0; k < 10; ++k) {
      int s = k * 12;
      Depth depth = Depth();
      depth.setQuantity(
          _convertToDouble(_getBytes(depthBytes, s, s + 4)).toInt());
      depth.setPrice(_convertToDouble(_getBytes(depthBytes, s + 4, s + 8)) /
          dec.toDouble());
      depth.setOrders(
          _convertToDouble(_getBytes(depthBytes, s + 8, s + 10)).toInt());
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

  ///This method parses binary data got from kite server to get ticks for each token subscribed.
  ///we have to keep a main Array List which is global and keep deleting element in the list and
  ///add new data element in that place and call notify data set changed.
  ///@return List of parsed ticks.
  List<Tick> _parseBinary(Uint8List binaryPackets) {
    List<Tick> ticks = [];
    List<Uint8List> packets = _splitPackets(binaryPackets);

    for (int i = 0; i < packets.length; ++i) {
      Uint8List bin = packets[i];
      Uint8List t = _getBytes(bin, 0, 4);
      int x = _convertToLong(t).toInt();
      int segment = x & 255;
      int dec1 = segment == 3 ? 10000000 : (segment == 6 ? 10000 : 100);
      Tick tick;
      if (bin.length == 8) {
        tick = _getLtpQuote(bin, x, dec1, segment != 9);
        ticks.add(tick);
      } else if (bin.length != 28 && bin.length != 32) {
        if (bin.length == 44) {
          tick = _getQuoteData(bin, x, dec1, segment != 9);
          ticks.add(tick);
        } else if (bin.length == 184) {
          tick = _getQuoteData(bin, x, dec1, segment != 9);
          tick.setMode(modeFull);
          ticks.add(_getFullData(bin, dec1, tick));
        }
      } else {
        tick = _getIndeciesData(bin, x, segment != 9);
        ticks.add(tick);
      }
    }

    return ticks;
  }

  ///Parses NSE indices data.
  ///@return Tick is the parsed index data.
  Tick _getIndeciesData(Uint8List bin, int x, bool tradable) {
    int dec = 100;
    Tick tick = Tick();
    tick.setMode(modeQuote);
    tick.setTradable(tradable);
    tick.setInstrumentToken(x);
    double lastTradedPrice =
        _convertToDouble(_getBytes(bin, 4, 8)) / dec.toDouble();
    tick.setLastTradedPrice(lastTradedPrice);
    tick.setHighPrice(_convertToDouble(_getBytes(bin, 8, 12)) / dec.toDouble());
    tick.setLowPrice(_convertToDouble(_getBytes(bin, 12, 16)) / dec.toDouble());
    tick.setOpenPrice(
        _convertToDouble(_getBytes(bin, 16, 20)) / dec.toDouble());
    double closePrice =
        _convertToDouble(_getBytes(bin, 20, 24)) / dec.toDouble();
    tick.setClosePrice(closePrice);
    _setChangeForTick(tick, lastTradedPrice, closePrice);
    if (bin.length > 28) {
      tick.setMode(modeFull);
      int tickTimeStamp = _convertToLong(_getBytes(bin, 28, 32)) * 1000;
      if (_isValidDate(tickTimeStamp)) {
        tick.setTickTimestamp(
            DateTime.fromMillisecondsSinceEpoch(tickTimeStamp));
      } else {
        tick.setTickTimestamp(null);
      }
    }

    return tick;
  }

  ///Remove lister the real time socket
  void removeListener(String tag) {
    _mapListener.remove(tag);
  }

  ///Set the latest data of ticks
  void _setUpLatestList(List<Tick> tickList) {
    for (var value in tickList) {
      latestList[value.token!] = value;
    }
  }
}

///Listener for Socket connection
abstract class SocketConnectionListener {
  ///This is callback when websocket connection is successful
  void onConnected(IOWebSocketChannel client);

  ///This is callback when websocket connection is unsuccessful
  void onError(String error);
}

/// Listener for data listener
abstract class OnDataListener {
  ///This is callback when start getting the real time data from socket
  void onData(List<Tick> list);
}
