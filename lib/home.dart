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
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
      appBar: AppBar(
        elevation: 0,
        title: Image.asset(
          "assets/headerimage.png",
          height: 40,
        ),
        actions: [
          IconBadge(
            icon: Icon(Icons.shopping_cart_outlined),
            itemCount: 3,
            badgeColor: Colors.red,
            itemColor: Colors.white,
            hideZero: true,
            onTap: () {
              print('test');
            },
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.user),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(),
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
