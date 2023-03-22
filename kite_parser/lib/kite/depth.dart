import 'dart:convert';

/// quantity : 121
/// price : 132
/// orders : 123

///Used to decode Depth json
Depth depthFromJson(String str) => Depth.fromJson(json.decode(str));

///Encode Depth json
String depthToJson(Depth data) => json.encode(data.toJson());

///Model class for Depth class
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

  ///Used to decode Depth json
  Depth.fromJson(dynamic json) {
    _quantity = json['quantity'];
    _price = json['price'];
    _orders = json['orders'];
  }

  num? _quantity;
  num? _price;
  num? _orders;

  ///Clone new Depth object
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

  ///Encode Depth json
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['quantity'] = _quantity;
    map['price'] = _price;
    map['orders'] = _orders;
    return map;
  }

  ///Setter for quantity
  void setQuantity(int int) {
    _quantity = int;
  }

  ///Setter for price
  void setPrice(double d) {
    _price = d;
  }

  ///Setter for order
  void setOrders(int int) {
    _orders = int;
  }
}
