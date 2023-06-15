import 'package:flutter/material.dart';
import 'ApiControllers.dart';
import 'ui/orderUI.dart';
import 'model/orderModel.dart';
import 'orderDetails.dart';

class OrderReports extends StatefulWidget {
  final String user_id;
  OrderReports({required this.user_id});

  @override
  State<OrderReports> createState() => _OrderReportsState();
}

class _OrderReportsState extends State<OrderReports>
    with AutomaticKeepAliveClientMixin<OrderReports> {
  String loadingString = "";
  int steps = 0;
  bool enablebutton = false;
  bool loadingdata = true;
  ApiController apiobj = ApiController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  resetList() {
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> getOrderData() async {
    String user_id = widget.user_id.toString();
    return await apiobj.getDataFromServerList("/userOrders/$user_id");
  }

  OrderUI uiobj = OrderUI();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders Reports"),
        actions: [ElevatedButton(onPressed: resetList, child: Text("Refresh"))],
      ),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future:
                getOrderData(), // a previously-obtained Future<String> or null
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> temporder = snapshot.data![index];
                    OrderBlock orderblock = OrderBlock.fromJson(temporder);
                    Order orderdata = Order.fromJson(temporder);
                    return uiobj.orderBlock(orderblock, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetails(order_key: orderdata.order_key),
                        ),
                      );
                      print(orderdata.cart);
                    });
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
