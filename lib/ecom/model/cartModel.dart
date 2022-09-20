import 'package:loyaltycard/core/db_controller.dart';

class CartProduct {
  final String product_id;
  final String image;
  final String title;
  final String sku;
  final String quantity;
  final String price;
  final String total_price;
  final String order_id;

  CartProduct({
    required this.product_id,
    required this.image,
    required this.title,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.total_price,
    required this.order_id,
  });

  Map<String, Object?> toMap() {
    return {
      'product_id': product_id,
      'image': image,
      'title': title,
      'sku': sku,
      'quantity': quantity,
      'price': price,
      'total_price': total_price,
      'order_id': order_id,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product_id: json["product_id"],
      title: json["title"],
      image: json["image"],
      sku: json["sku"],
      quantity: "1",
      price: json["fprice"],
      total_price: json["fprice"],
      order_id: "0",
    );
  }
}

class CartModel {
  Dbconnect db = Dbconnect();
  Future<Map<String, CartProduct>> list() async {
    String query = "select * from cart where order_id='0'";
    final List<dynamic> cartdata = await this.db.getDataByQuery(query);
    Map<String, CartProduct> cartlist = {};
    if (cartdata.isNotEmpty) {
      cartdata.forEach((element) {
        cartlist[element["product_id"]] = CartProduct.fromJson(element);
      });
    }
    return cartlist;
  }

  Future productInsert(CartProduct cartproduct) async {
    db.insertData("cart", cartproduct.toMap());
  }

  Future add(Map<String, dynamic> product) async {
    String product_id = product["product_id"];
    Map<String, CartProduct> cartlist = await this.list();
    print(cartlist);
    if (cartlist.containsKey(product_id)) {
    } else {
      CartProduct cartproduct = CartProduct.fromJson(product);
      await this.productInsert(cartproduct);
    }
  }
}
