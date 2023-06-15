import 'package:flutter/material.dart';
import 'package:loyaltycard/ecom/model/cartModel.dart';
import 'package:loyaltycard/ecom/model/orderModel.dart';
import "ui/orderUI.dart";
import 'package:icon_badge/icon_badge.dart';
import "ApiControllers.dart";

class OrderDetails extends StatefulWidget {
  final String order_key;
  OrderDetails({required this.order_key});
  @override
  State<OrderDetails> createState() => OrderDetailsPage();
}

class OrderDetailsPage extends State<OrderDetails>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  bool hasProducts = true;
  ApiController apiobj = ApiController();
  OrderUI uiobj = OrderUI();

  resetList() async {
    setState(() {});
  }

  Future<Order> orderDetails() async {
    String orderkey = widget.order_key;
    Map<String, dynamic> orderdetailres =
        await apiobj.getDataFromServerMap("/userOrderSingle/$orderkey");
    Order orderdetails = Order.fromJson(orderdetailres);
    return orderdetails;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        actions: [],
      ),
      // backgroundColor: Colors.grey.shade500,
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return FutureBuilder<Order>(
            future:
                orderDetails(), // a previously-obtained Future<String> or null
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                Order? orderobj = snapshot.data;
                return SingleChildScrollView(
                  child: Column(
                    children: [uiobj.orderDetailsBlock(orderobj!)],
                  ),
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
