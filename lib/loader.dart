import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Loader extends StatefulWidget {
  const Loader({Key? key}) : super(key: key);

  //final String title;

  @override
  State<Loader> createState() => LoaderPageState();
}

class LoaderPageState extends State<Loader> with TickerProviderStateMixin {
  static const routeName = 'loader';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Map userprofile = {};
  bool userloggein = false;
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "").toString();
    print(userprofiletemp);
    setState(() {
      if (userprofiletemp.isNotEmpty && userprofiletemp!="null") {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
        // Navigator.pushNamedAndRemoveUntil(
        //     context, 'home', ModalRoute.withName('home'));
        Navigator.pushNamedAndRemoveUntil(
            context, 'home', ModalRoute.withName('home'));
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.all(7),
      child: Column(children: []),
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
