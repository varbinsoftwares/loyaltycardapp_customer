import 'package:flutter/material.dart';
import 'package:loyaltycard/ecom/orderReports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../auth/profile.dart';

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
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage(
                          height: 60,
                          width: 60,
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
                      title: Text(
                        userprofile["name"].toString().toUpperCase(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      subtitle: Text(
                        userprofile["contact_no"].toString().toUpperCase(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        label: Text("Update"),
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
                    ),
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
