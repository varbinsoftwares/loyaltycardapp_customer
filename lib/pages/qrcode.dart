import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QRScreen extends StatefulWidget {
  const QRScreen();

  //final String title;

  @override
  State<QRScreen> createState() => QRScreenPage();
}

class QRScreenPage extends State<QRScreen> {
  Map userprofile = {};
  bool userloggein = false;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        //print(userprofile);
        userloggein = true;
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width * 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Text("Card No.: " + userprofile["usercode"].toString()),
      ),
      body: SingleChildScrollView(
        child: userloggein
            ? Container(
                width: _screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      // tag: "contactlist" + userprofile["id"].toString(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage(
                          height: 100,
                          width: 100,
                          // here `bytes` is a Uint8List containing the bytes for the in-memory image
                          placeholder: AssetImage(
                            "assets/tick.png",
                          ),
                          image: NetworkImage(
                            userprofile["profile_image"].toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      userprofile["name"].toString().toUpperCase(),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    Text(
                      userprofile["contact_no"].toString().toUpperCase(),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    QrImage(
                      data: userprofile["usercode"].toString(),
                      version: QrVersions.auto,
                      size: _screenWidth - 100,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Your Card No.",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userprofile["usercode"].toString(),
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
