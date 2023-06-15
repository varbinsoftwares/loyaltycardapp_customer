import 'package:loyaltycard/core/db_controller.dart';

class CartProduct {
  final String product_id;
  final String image;
  final String title;
  final String sku;
  int quantity;
  final double price;
  final double total_price;
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
      'product_id': product_id.toString(),
      'image': image,
      'title': title,
      'sku': sku,
      'quantity': quantity.toString(),
      'price': price.toString(),
      'total_price': total_price.toString(),
      'order_id': order_id.toString(),
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      product_id: json["product_id"],
      title: json["title"],
      image: json["image"],
      sku: json["sku"],
      quantity: int.parse("1"),
      price: double.parse(json["fprice"]),
      total_price: double.parse(json["fprice"]),
      order_id: "0",
    );
  }

  factory CartProduct.fromMap(Map<String, dynamic> json) {
    return CartProduct(
      product_id: json["product_id"],
      title: json["title"],
      image: json["image"],
      sku: json["sku"],
      quantity: int.parse(json["quantity"]),
      price: double.parse(json["price"]),
      total_price: double.parse(json["total_price"]),
      order_id: "0",
    );
  }

  // set and get shipping
  int get getQuantity {
    return quantity;
  }

  set setQuantity(int qnty) {
    quantity = qnty;
  }
}

class CartDetails {
  final Map cartproducts;
  final int totalQuantity;
  final String totalAmount;
  String shipping;
  String couponDiscount;
  String couponCode;
  String grandTotal;

  CartDetails({
    required this.cartproducts,
    required this.totalQuantity,
    required this.totalAmount,
    required this.shipping,
    required this.couponDiscount,
    required this.couponCode,
    required this.grandTotal,
  });

  // set and get shipping
  String get getShipping {
    return shipping;
  }

  set setShipping(String amount) {
    double shippingAmt = double.parse(amount);
    shipping = shippingAmt.toStringAsFixed(2);
    double totalamt = double.parse(totalAmount);
    double couponDiscountAmt = double.parse(couponDiscount);
    grandTotal =
        ((totalamt - couponDiscountAmt) + shippingAmt).toStringAsFixed(2);
  }

  //set grand total
  set setGrandTotal(String amount) {
    grandTotal = double.parse(amount).toStringAsFixed(2);
  }

  //set and get coupon discount
  String get getCouponCode {
    return couponCode;
  }

  set setCouponCode(String code) {
    couponCode = code;
  }

  //set and get couponcode
  String get getCouponDiscount {
    return couponDiscount;
  }

  set setCouponDiscount(String amount) {
    double couponAmt = double.parse(amount);
    double totalamt = double.parse(totalAmount);
    double shippingAmt = double.parse(shipping);
    grandTotal = ((totalamt - couponAmt) + shippingAmt).toStringAsFixed(2);
    couponDiscount = double.parse(amount).toStringAsFixed(2);
  }

  Map<String, Object> toMap() {
    return {
      'cartproducts': cartproducts,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'shipping': shipping,
      'couponDiscount': couponDiscount,
      'couponCode': couponCode,
      'grandTotal': grandTotal,
    };
  }

  factory CartDetails.fromMap(Map<String, dynamic> json) {
    return CartDetails(
      cartproducts: json["cartproducts"],
      totalQuantity: json["totalQuantity"],
      totalAmount: json["totalAmount"].toStringAsFixed(2),
      shipping: json["shipping"].toStringAsFixed(2),
      couponDiscount: json["couponDiscount"].toStringAsFixed(2),
      couponCode: json["couponCode"],
      grandTotal: json["grandTotal"].toStringAsFixed(2),
    );
  }
}

class Coupon {
  final String has_coupon;
  final String coupon_code;
  final String coupon_discount;
  final String coupon_discount_type;
  final String coupon_message;

  Coupon({
    required this.has_coupon,
    required this.coupon_code,
    required this.coupon_discount,
    required this.coupon_discount_type,
    required this.coupon_message,
  });

  Map<String, Object?> toMap() {
    return {
      'has_coupon': has_coupon,
      'coupon_code': coupon_code,
      'coupon_discount': coupon_discount,
      'coupon_discount_type': coupon_discount_type,
      'coupon_message': coupon_message,
    };
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      has_coupon: json["has_coupon"],
      coupon_discount: json["coupon_discount"],
      coupon_code: json["coupon_code"],
      coupon_discount_type: json["coupon_discount_type"],
      coupon_message: json["coupon_message"],
    );
  }

  factory Coupon.fromMap(Map<String, dynamic> json) {
    return Coupon(
      has_coupon: json["has_coupon"],
      coupon_discount: json["coupon_discount"],
      coupon_code: json["coupon_code"],
      coupon_discount_type: json["coupon_discount_type"],
      coupon_message: json["coupon_message"],
    );
  }
}

class CartModel {
  Dbconnect db = Dbconnect();

  Future<CartDetails> details() async {
    String query = "select * from cart where order_id='0'";
    final List<dynamic> cartdata = await this.db.getDataByQuery(query);
    Map<String, CartProduct> cartlist = {};
    int quantity = 0;
    double subtotal = 0;
    double shipping = 0;
    double couponDiscount = 0;
    double grandTotal = 0;
    String couponCode = "";
    if (cartdata.isNotEmpty) {
      cartdata.forEach((element) {
        CartProduct cartobj = CartProduct.fromMap(element);
        quantity += cartobj.quantity;
        subtotal += cartobj.total_price;
        cartlist[element["product_id"].toString()] = cartobj;
        // print(cartobj.toMap());
      });
    }
    grandTotal = (subtotal - couponDiscount) + shipping;
    CartDetails cartdetails = CartDetails(
      cartproducts: cartlist,
      totalQuantity: quantity,
      totalAmount: subtotal.toStringAsFixed(2),
      shipping: shipping.toStringAsFixed(2),
      couponDiscount: couponDiscount.toStringAsFixed(2),
      couponCode: couponCode,
      grandTotal: grandTotal.toStringAsFixed(2),
    );
    return cartdetails;
  }

  Future productInsert(CartProduct cartproduct) async {
    await db.insertData("cart", cartproduct);
  }

  Future productDelete(String product_id) async {
    await db.deleteTable(
      "cart",
      colname: "product_id",
      colval: product_id,
    );
  }

  Future deleteAllCart() async {
    await db.deleteTableData("cart");
  }

  Future updateCart(String product_id, {bool is_increament = true}) async {
    CartDetails cartdetails = await this.details();
    CartProduct cartobj = cartdetails.cartproducts[product_id];
    int updatequantity = cartobj.quantity + (is_increament ? (1) : (-1));
    double updatetotal = cartobj.price * updatequantity;
    print(updatequantity);
    if (updatequantity >= 1) {
      Map updateList = {
        "quantity": updatequantity.toString(),
        "total_price": updatetotal.toStringAsFixed(2)
      };
      await db
          .updateTableCondition("cart", updateList, {"product_id": product_id});
    }
  }

  Future add(Map<String, dynamic> product) async {
    String product_id = product["product_id"];

    CartDetails cartdetails = await this.details();
    // print(cartdetails.toMap());
    if (cartdetails.cartproducts.containsKey(product_id)) {
      await updateCart(product_id);
    } else {
      CartProduct cartproduct = CartProduct.fromJson(product);
      await this.productInsert(cartproduct);
    }
  }
}
