import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../auth/profile.dart';
import 'package:bottom_bar/bottom_bar.dart';
import '../pages/mypoints.dart';
import 'ecom/category.dart';
import '../pages/contact.dart';
import '../pages/redeem.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loyaltycard/config.dart' as config;
import 'package:loyaltycard/rewards/postlist.dart';
import 'package:loyaltycard/pages/qrcode.dart';
import 'package:icon_badge/icon_badge.dart';
import "package:loyaltycard/ecom/model/cartModel.dart";
import "package:loyaltycard/ecom/cart.dart";
import "package:loyaltycard/ecom/orderReports.dart";

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  //final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  static const routeName = 'home';
  int _currentPage = 0;
  final _pageController = PageController();
  UIWidget uiobj = UIWidget();
  CartModel cardobj = CartModel();
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
    super.initState();
    initCart();
    Timer.periodic(new Duration(seconds: 10), (timer) {
      initCart();
    });
    _loadUserInfo();
  }

  initCart() async {
    CartDetails cartdetails2 = await cardobj.details();
    setState(() {
      cartdetails = cartdetails2;
    });
  }

  cartChanges(value) {
    print(value);
  }

  Map userprofile = {};
  bool userloggein = false;
  String kyc_status = "";
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    String kyc1 = (prefs.getString('kyc') ?? "").toString();
    if (kyc1.isNotEmpty) {
      Map kyc_status1 = jsonDecode(kyc1);
      setState(() {
        kyc_status = kyc_status1['status'];
      });
    }
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
        checkKycStatus();
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  checkKycStatus() async {
    String apilogin =
        config.apiendpoint + "/kycStatus/" + userprofile['id'].toString();
    var response = await http.get(
      Uri.parse(apilogin),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map registration = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var kycdata = jsonEncode(registration['kycdata']);
      setState(() {
        String statuscheck = registration['status'].toString();
        if (statuscheck == "100") {
          kyc_status = registration['kycdata']["status"].toString();
          prefs.setString("kyc", kycdata).then((value) {
            print(value);
          });
        }
      });
    }
  }

  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("profile").then((value) => _loadUserInfo());
    setState(() {
      userprofile = {};
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time];
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,

          children: [
            Container(
              height: 200,
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/headerimage.png'),
            ),

            // Image.asset("assets/sketch.png"),
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
              leading: Icon(Icons.shopping_cart_outlined),
              title:
                  const Text('Shopping Cart', style: TextStyle(fontSize: 18)),
              onTap: () {
                // Update the state of the app.
                // ...systemLog
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
              leading: Icon(Icons.list),
              title:
                  const Text('Order Reports', style: TextStyle(fontSize: 18)),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderReports(
                      user_id: userprofile["id"],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
              title: const Text('My Points', style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.wallet_giftcard),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPoints(navigation: true),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
              title: const Text('My Card', style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.credit_card),
              onTap: () {
                // Update the state of the app.
                // ...customerReports
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScreen(),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
              title: const Text('User Profile', style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.person),
              onTap: () {
                // Update the state of the app.
                // ...systemLog
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        title: Image.asset(
          "assets/headerimage.png",
          height: 40,
        ),
        actions: [
          IconBadge(
            icon: Icon(Icons.shopping_cart_outlined),
            itemCount: cartdetails.totalQuantity,
            badgeColor: Colors.red,
            itemColor: Colors.white,
            hideZero: true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cart(),
                ),
              );
              initCart();
            },
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.user),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScreen(),
                ),
              );
              // _handleLogout();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade300,
      body: Container(
        child: PageView(
          controller: _pageController,
          children: [
            Category(),
            PostList(),
            //   Redeem(),
            MyPoints()
          ],
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
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
        child: BottomBar(
          selectedIndex: _currentPage,
          onTap: (int index) {
            _pageController.jumpToPage(index);
            setState(() => _currentPage = index);
          },
          items: <BottomBarItem>[
            BottomBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.red.shade500,
                child: FaIcon(
                  FontAwesomeIcons.shoppingBag,
                  color: Colors.white,
                  size: 15,
                ),
              ),

              title: Text('Shopping'),
              activeColor: Colors.red,
              //darkActiveColor: Colors.red.shade400, // Optional
            ),
            BottomBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.blue.shade500,
                child: FaIcon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              title: Text('Offers'),
              activeColor: Color(0xff0076a6),
            ),
            BottomBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.green.shade500,
                child: FaIcon(
                  FontAwesomeIcons.trophy,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              title: Text('Rewards'),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
