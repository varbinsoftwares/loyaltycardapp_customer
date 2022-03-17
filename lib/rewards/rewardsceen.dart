import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:loyaltycard/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:cool_alert/cool_alert.dart';

class RewardPage extends StatefulWidget {
  static const routeName = 'rewardscreen';
  final String serial_no;
  final String user_id;
  RewardPage({
    required this.serial_no,
    required this.user_id,
  });
  //final String title;

  @override
  State<RewardPage> createState() => RewardPagecreen();
}

class RewardPagecreen extends State<RewardPage> with TickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
    getProduct();
  }

  bool has_product = false;
  bool loader = false;
  Map product_info = {};
  String message = '';
  void getProduct() async {
    var url = config.apiendpoint +
        "/getProductBySerialNo/" +
        widget.serial_no +
        "/" +
        widget.user_id;
    print(url);
    var response = await http.get(Uri.parse(url));
    setState(() {
      loader = true;
    });

    if (response.statusCode == 200) {
      Map productDetail = jsonDecode(response.body);
      print(productDetail);
      setState(() {
        message = productDetail['message'];
      });
      if (productDetail['status'] == '200') {
          CoolAlert.show(
        context: context,
        widget: Container(
          margin:EdgeInsets.only(top:20),
            child: Image.asset(
          "assets/trophy.png",
          height: 80,
        )),
        backgroundColor: Colors.blue,
        type: CoolAlertType.success,
        text: "Your transaction was successful!",
      );
        setState(() {
          product_info = productDetail['product_info'];
          has_product = true;
        });
      } else {
        setState(() {
          has_product = false;
        });
      }
    } else {
      setState(() {
        has_product = false;
      });
    }
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
        appBar: AppBar(
          title: Text("Rewards  " + widget.serial_no.toString()),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    loader = true;
                    has_product = true;
                  });
                },
                icon: Icon(Icons.refresh))
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(7),
          child: loader
              ? has_product
                  ? Container(
                      height: _screenHeight - 170,
                      child: Column(
                        children: [
                         
                          uiobj.messageBox(context, message, "success"),
                        ],
                      ))
                  : Container(
                      height: _screenHeight - 170,
                      child: Column(
                        children: [
                          uiobj.messageBox(context, message, "error"),
                        ],
                      ))
              : Container(
                  height: _screenHeight - 170,
                  child: Center(
                    child: CircularProgressIndicator(),
                  )),
        ));
  }

}
