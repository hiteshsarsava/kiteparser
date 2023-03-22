import 'dart:convert';

/// quantity : 121
/// price : 132
/// orders : 123

Depth depthFromJson(String str) => Depth.fromJson(json.decode(str));

String depthToJson(Depth data) => json.encode(data.toJson());

class Depth {
  Depth({
    num? quantity,
    num? price,
    num? orders,
  }) {
    _quantity = quantity;
    _price = price;
    _orders = orders;
  }

  Depth.fromJson(dynamic json) {
    _quantity = json['quantity'];
    _price = json['price'];
    _orders = json['orders'];
  }

  num? _quantity;
  num? _price;
  num? _orders;

  Depth copyWith({
    num? quantity,
    num? price,
    num? orders,
  }) =>
      Depth(
        quantity: quantity ?? _quantity,
        price: price ?? _price,
        orders: orders ?? _orders,
      );

  num? get quantity => _quantity;

  num? get price => _price;

  num? get orders => _orders;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['quantity'] = _quantity;
    map['price'] = _price;
    map['orders'] = _orders;
    return map;
  }

  void setQuantity(int int) {
    _quantity = int;
  }

  void setPrice(double d) {
    _price = d;
  }

  void setOrders(int int) {
    _orders = int;
  }
}
