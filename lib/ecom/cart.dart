import 'package:flutter/material.dart';
import 'package:loyaltycard/ecom/model/cartModel.dart';
import "ui/cartui.dart";
import 'package:icon_badge/icon_badge.dart';
import "shippingDiscount.dart";

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);
  @override
  State<Cart> createState() => CartPage();
}

class CartPage extends State<Cart> with TickerProviderStateMixin {
  static const routeName = 'cart';
  bool loadingorder = true;
  CartModel cartobj = CartModel();
  CartUI uiobj = CartUI();
  CartDetails cartdetails = CartDetails.fromMap({
    'cartproducts': {},
    'totalQuantity': 0,
    'totalAmount': 0,
    'shipping': 0,
    'couponDiscount': 0,
    'couponCode': "",
    'grandTotal': 0,
  });

  @override
  void initState() {
    initCart();
    super.initState();
  }

  bool hasProducts = true;

  initCart() async {
    CartDetails cartdetails2 = await cartobj.details();
    setState(() {
      cartdetails = cartdetails2;
    });
    checkCart();
  }

  checkCart() {
    if (cartdetails.cartproducts.length == 0) {
      setState(() {
        hasProducts = false;
      });
      print(hasProducts);
    }
  }

  resetList() async {
    CartDetails cartdetails3 = await cartobj.details();
    setState(() {
      cartdetails = cartdetails3;
    });
    checkCart();
  }

  Future<List<CartProduct>> cartDetails() async {
    CartDetails cartdetails2 = await cartobj.details();

    cartdetails = cartdetails2;

    List<CartProduct> cartlist = [];
    cartdetails2.cartproducts.forEach((key, value) {
      cartlist.add(value);
    });

    return cartlist;
  }

  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Cart"),
        actions: [
          IconBadge(
            icon: Icon(Icons.shopping_cart_outlined),
            itemCount: cartdetails.totalQuantity,
            badgeColor: Colors.red,
            itemColor: Colors.white,
            hideZero: true,
            onTap: resetList,
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade500,
      bottomNavigationBar: uiobj.bottomBar(Column(
        children: hasProducts
            ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    uiobj.h1("Sub Total", cartdetails.totalAmount),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    uiobj.bottomBarbutton("Shop More", () {
                      Navigator.of(context).pop();
                    }, icon: Icons.arrow_back_sharp),
                    SizedBox(
                      width: 20,
                    ),
                    uiobj.bottomBarbutton("Proceed to Order", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShippingDiscount(),
                        ),
                      );
                    }, icon: Icons.local_shipping)
                  ],
                )
              ]
            : [
                Padding(
                  child: Text("No product in cart"),
                  padding: EdgeInsets.only(top: 20),
                ),
                uiobj.bottomBarbutton("Shop More", () {
                  Navigator.of(context).pop();
                }, icon: Icons.arrow_back_sharp)
              ],
      )),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return FutureBuilder<List<CartProduct>>(
            future:
                cartDetails(), // a previously-obtained Future<String> or null
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    CartProduct cartprd = snapshot.data![index];
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 20.0, // soften the shadow
                              spreadRadius: -5.0,
                            ),
                          ]),
                      margin: EdgeInsets.only(
                          top: 5, left: 10, right: 10, bottom: 5),

                      // color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: FadeInImage(
                              height: 70,
                              width: 70,
                              placeholder: AssetImage('assets/icon.png'),
                              image: NetworkImage(cartprd.image),
                              fit: BoxFit.contain,
                            ),
                            title: Text(
                              cartprd.title,
                              softWrap: false,
                            ),
                            subtitle: Text(cartprd.price.toStringAsFixed(2) +
                                " X " +
                                cartprd.quantity.toString()),
                            trailing: Text(
                              cartprd.total_price.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0)),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await cartobj
                                              .updateCart(cartprd.product_id);
                                          resetList();
                                        },
                                        icon: Icon(Icons.add)),
                                    Text(cartprd.quantity.toString()),
                                    IconButton(
                                        onPressed: () async {
                                          await cartobj.updateCart(
                                              cartprd.product_id,
                                              is_increament: false);
                                          resetList();
                                        },
                                        icon: Icon(Icons.remove))
                                  ],
                                ),
                                trailing: IconButton(
                                    onPressed: () async {
                                      await cartobj
                                          .productDelete(cartprd.product_id);
                                      resetList();
                                    },
                                    icon: Icon(Icons.delete)),
                              )),
                        ],
                      ),
                    );
                  },
                );
              }

              /// handles others as you did on question
              else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
