import 'dart:convert';

import 'package:kiteparser/kite/depth.dart';

/// mode : ""
/// tradable : true
/// token : 5465466546465
/// lastTradedPrice : 4654654644656
/// highPrice : 465465654656
/// lowPrice : 12313131332
/// openPrice : 79879879989
/// closePrice : 132132132
/// change : 3213213232
/// lastTradeQuantity : 79879879898
/// averageTradePrice : 21323
/// volumeTradedToday : 3132131324654648
/// totalBuyQuantity : 98798798798
/// totalSellQuantity : 67879879
/// lastTradedTime : ""
/// oi : 32132
/// openInterestDayHigh : 123.21
/// openInterestDayLow : 13.132
/// tickTimestamp : ""

///Decode Tick json
Tick tickFromJson(String str) => Tick.fromJson(json.decode(str));

///Encode Tick json
String tickToJson(Tick data) => json.encode(data.toJson());

class Tick {
  Tick({
    String? mode,
    bool? tradable,
    num? token,
    num? lastTradedPrice,
    num? highPrice,
    num? lowPrice,
    num? openPrice,
    num? closePrice,
    num? change,
    num? lastTradeQuantity,
    num? averageTradePrice,
    num? volumeTradedToday,
    num? totalBuyQuantity,
    num? totalSellQuantity,
    DateTime? lastTradedTime,
    num? oi,
    num? openInterestDayHigh,
    num? openInterestDayLow,
    DateTime? tickTimestamp,
  }) {
    _mode = mode;
    _tradable = tradable;
    _token = token;
    _lastTradedPrice = lastTradedPrice;
    _highPrice = highPrice;
    _lowPrice = lowPrice;
    _openPrice = openPrice;
    _closePrice = closePrice;
    _change = change;
    _lastTradeQuantity = lastTradeQuantity;
    _averageTradePrice = averageTradePrice;
    _volumeTradedToday = volumeTradedToday;
    _totalBuyQuantity = totalBuyQuantity;
    _totalSellQuantity = totalSellQuantity;
    _lastTradedTime = lastTradedTime;
    _oi = oi;
    _openInterestDayHigh = openInterestDayHigh;
    _openInterestDayLow = openInterestDayLow;
    _tickTimestamp = tickTimestamp;
    _depth = depth;
  }

  ///Decode Tick json
  Tick.fromJson(dynamic json) {
    _mode = json['mode'];
    _tradable = json['tradable'];
    _token = json['token'];
    _lastTradedPrice = json['lastTradedPrice'];
    _highPrice = json['highPrice'];
    _lowPrice = json['lowPrice'];
    _openPrice = json['openPrice'];
    _closePrice = json['closePrice'];
    _change = json['change'];
    _lastTradeQuantity = json['lastTradeQuantity'];
    _averageTradePrice = json['averageTradePrice'];
    _volumeTradedToday = json['volumeTradedToday'];
    _totalBuyQuantity = json['totalBuyQuantity'];
    _totalSellQuantity = json['totalSellQuantity'];
    _lastTradedTime = json['lastTradedTime'];
    _oi = json['oi'];
    _openInterestDayHigh = json['openInterestDayHigh'];
    _openInterestDayLow = json['openInterestDayLow'];
    _tickTimestamp = json['tickTimestamp'];
    _depth = json['depth'];
  }

  String? _mode;
  bool? _tradable;
  num? _token;
  num? _lastTradedPrice;
  num? _highPrice;
  num? _lowPrice;
  num? _openPrice;
  num? _closePrice;
  num? _change;
  num? _lastTradeQuantity;
  num? _averageTradePrice;
  num? _volumeTradedToday;
  num? _totalBuyQuantity;
  num? _totalSellQuantity;
  DateTime? _lastTradedTime;
  num? _oi;
  num? _openInterestDayHigh;
  num? _openInterestDayLow;
  DateTime? _tickTimestamp;
  Map<String, List<Depth>>? _depth;

  String? get mode => _mode;

  bool? get tradable => _tradable;

  num? get token => _token;

  num? get lastTradedPrice => _lastTradedPrice;

  num? get highPrice => _highPrice;

  num? get lowPrice => _lowPrice;

  num? get openPrice => _openPrice;

  num? get closePrice => _closePrice;

  num? get change => _change;

  num? get lastTradeQuantity => _lastTradeQuantity;

  num? get averageTradePrice => _averageTradePrice;

  num? get volumeTradedToday => _volumeTradedToday;

  num? get totalBuyQuantity => _totalBuyQuantity;

  num? get totalSellQuantity => _totalSellQuantity;

  DateTime? get lastTradedTime => _lastTradedTime;

  num? get oi => _oi;

  num? get openInterestDayHigh => _openInterestDayHigh;

  num? get openInterestDayLow => _openInterestDayLow;

  DateTime? get tickTimestamp => _tickTimestamp;

  Map<String, List<Depth>>? get depth => _depth;

  ///Encode Tick json
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mode'] = _mode;
    map['tradable'] = _tradable;
    map['token'] = _token;
    map['lastTradedPrice'] = _lastTradedPrice;
    map['highPrice'] = _highPrice;
    map['lowPrice'] = _lowPrice;
    map['openPrice'] = _openPrice;
    map['closePrice'] = _closePrice;
    map['change'] = _change;
    map['lastTradeQuantity'] = _lastTradeQuantity;
    map['averageTradePrice'] = _averageTradePrice;
    map['volumeTradedToday'] = _volumeTradedToday;
    map['totalBuyQuantity'] = _totalBuyQuantity;
    map['totalSellQuantity'] = _totalSellQuantity;
    map['lastTradedTime'] = _lastTradedTime;
    map['oi'] = _oi;
    map['openInterestDayHigh'] = _openInterestDayHigh;
    map['openInterestDayLow'] = _openInterestDayLow;
    map['tickTimestamp'] = _tickTimestamp;
    map['depth'] = _depth;
    return map;
  }

  ///Setter for _change
  void setNetPriceChangeFromClosingPrice(double d) {
    _change = d;
  }

  ///Setter for _lastTradedTime
  void setLastTradedTime(DateTime? dateTime) {
    _lastTradedTime = dateTime;
  }

  ///Setter for _oi
  void setOi(double convertToDouble) {
    _oi = convertToDouble;
  }

  ///Setter for _openInterestDayHigh
  void setOpenInterestDayHigh(double convertToDouble) {
    _openInterestDayHigh = convertToDouble;
  }

  ///Setter for _openInterestDayLow
  void setOpenInterestDayLow(double convertToDouble) {
    _openInterestDayLow = convertToDouble;
  }

  ///Setter for _tickTimestamp
  void setTickTimestamp(DateTime? dateTime) {
    _tickTimestamp = dateTime;
  }

  ///Setter for _depth
  void setMarketDepth(Map<String, List<Depth>>? depthData) {
    _depth = depthData;
  }

  ///Setter for _mode
  void setMode(String modeFull) {
    _mode = modeFull;
  }

  ///Setter for _tradable
  void setTradable(bool tradable) {
    _tradable = tradable;
  }

  ///Setter for _token
  void setInstrumentToken(int int) {
    _token = int;
  }

  ///Setter for _lastTradedPrice
  void setLastTradedPrice(double lastTradedPrice) {
    _lastTradedPrice = lastTradedPrice;
  }

  ///Setter for _highPrice
  void setHighPrice(double d) {
    _highPrice = d;
  }

  ///Setter for _lowPrice
  void setLowPrice(double d) {
    _lowPrice = d;
  }

  ///Setter for _openPrice
  void setOpenPrice(double d) {
    _openPrice = d;
  }

  ///Setter for _closePrice
  void setClosePrice(double closePrice) {
    _closePrice = closePrice;
  }
}
