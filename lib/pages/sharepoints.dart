import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'redeem.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:cool_alert/cool_alert.dart';
import '../config.dart';

class SharePoints extends StatefulWidget {
  final String mob_card_no;
  final String userpoints;
  SharePoints({
    required this.userpoints,
    required this.mob_card_no,
  });
  @override
  State<SharePoints> createState() => SharePointsPage();
}

class SharePointsPage extends State<SharePoints> {
  static const routeName = 'sharepoints';
  TextEditingController inputpoints = new TextEditingController();
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Map userprofile = {};

  bool userloggein = false;
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
        _searchUser();
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Map userData = {};
  bool checkuserData = false;
  String msg = "";
  bool loader = false;
  String statuscode = "100";
  Map serchuserprofile = {};
  _searchUser() async {
    setState(() {
      loader = true;
      checkuserData = false;
    });
    String mobile_no1 = widget.mob_card_no;
    String apiurl = apiendpoint + "/getUserByMobCod/$mobile_no1";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));

    if (response.statusCode == 200) {
      print("------------------");
      setState(() {
        loader = false;
      });
      Map tempuserdata = jsonDecode(response.body);
      print(tempuserdata);
      if (tempuserdata['status'] == "200") {
        print("-----------");
        setState(() {
          userData = tempuserdata;
          serchuserprofile = tempuserdata["userdata"];
          print(userData);
          statuscode = "200";
          checkuserData = true;
        });
      } else {
        setState(() {
          statuscode = "300";
        });
        msg = "Number does not exist ";
      }
    } else {
      setState(() {
        loader = false;
      });
    }
  }

  bool sharingstatus = true;
  _sharePoint() async {
    String inputtxt = inputpoints.text;
    setState(() {
      sharingstatus = false;
    });
    int numbertext =
        inputtxt.isNotEmpty ? int.parse(inputpoints.text.toString()) : 0;
    String numberstr = (numbertext / 2).toString();
    String username = userprofile["contact_no"].toString();
    String receivername = serchuserprofile["contact_no"].toString();
    Map jsonData = {
      "point_debit": numbertext.toString(),
      "points": numberstr,
      "description": "$numberstr Points has been shared by $username",
      "user_id": serchuserprofile["id"].toString(),
      "sender_id": userprofile["id"].toString(),
      "sender_description":
          "$numbertext Points has been shared to $receivername",
      "point_type": "Credit"
    };
    CoolAlert.show(
      context: context,
      type: CoolAlertType.loading,
      text: "Sharing Points",
    );
    print(jsonData);
    String apilogin = apiendpoint + "/sharePoints";
    print(apilogin);
    var response = await http.post(
      Uri.parse(apilogin),
      body: jsonData,
    );
    if (response.statusCode == 200) {
      Map registration = jsonDecode(response.body);
      setState(() {
        sharingstatus = true;
      });

      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "$numberstr Points has been shared.",
      );
    } else {
      setState(() {
        sharingstatus = true;
      });
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Failed to share points",
      );
    }
  }

  final _formKey = GlobalKey<FormState>();

  Widget memeberStatusLoading(statuscode) {
    switch (statuscode.toString()) {
      case "100":
        return SizedBox(height: 10);
        break;
      case "200":
        return uiobj.userCard(
            imageurl: serchuserprofile["profile_image"].toString(),
            name: serchuserprofile["name"].toString(),
            card_no: serchuserprofile["usercode"].toString(),
            contact_no: serchuserprofile["contact_no"].toString(),
            height: 180,
            widgetlist: Container(
              height: 10,
            ));

      default:
        return Card(
            child: ListTile(
          title: Text("No Member Found"),
        ));
        break;
    }
  }

  bool checkNumber() {
    String inputtxt = inputpoints.text;
    int numbertext =
        inputtxt.isNotEmpty ? int.parse(inputpoints.text.toString()) : 0;
    print(numbertext % 2);
    if (numbertext % 2 == 0) {
      String userpoint = widget.userpoints.toString();
      int numberuserpoint =
          userpoint.isNotEmpty ? int.parse(userpoint.toString()) : 0;
      print(numbertext > numberuserpoint);
      if (numbertext > numberuserpoint) {
        return true;
      }
      return false;
    } else {
      return true;
    }
  }

  //share points

  //end of share points

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
      // backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Share Point"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: loader
                      ? Card(
                          child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            child: CircularProgressIndicator(
                              color: Colors.grey.shade100,
                            ),
                          ),
                          title: LinearProgressIndicator(
                              minHeight: 25,
                              backgroundColor: Colors.white,
                              color: Colors.grey.shade100),
                          subtitle: LinearProgressIndicator(
                              minHeight: 15,
                              backgroundColor: Colors.white,
                              color: Colors.grey.shade100),
                        ))
                      : memeberStatusLoading(statuscode),
                ),
                SizedBox(
                  width: 50,
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  // width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Column(
                        children: [
                          Text(
                            widget.userpoints.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.blueAccent),
                          ),
                          Text(
                            "POINTS",
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      )),
                      Container(
                        width: 130,
                        margin: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: inputpoints,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 15),
                          decoration:
                              const InputDecoration(hintText: "Points Here"),
                          validator: (value) {
                            if (checkNumber()) {
                              return 'Please enter valid no.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        child: ElevatedButton.icon(
                            onPressed: checkuserData
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      _sharePoint();
                                    }
                                  }
                                : null,
                            icon: Icon(Icons.arrow_forward),
                            label: Text("Share Now")),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 30,
                ),
                Text('Term & Conditions',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(
                  width: 50,
                  height: 10,
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: '1) You can share only ',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'even no. (2, 4, 6, 8 ...)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' of points.'),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 5,
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    children: const <TextSpan>[
                      TextSpan(text: '2) Only'),
                      TextSpan(
                          text: ' 50%',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' points will be shared to anohter one.'),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 5,
                ),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: '2) You can only share less then '),
                      TextSpan(
                          text: widget.userpoints.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' points.'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
