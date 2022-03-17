import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'redeem.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  final _formKey = GlobalKey<FormState>();

  Widget memeberStatusLoading(statuscode) {
    switch (statuscode.toString()) {
      case "100":
        return SizedBox(height: 10);
        break;
      case "200":
        return Card(
            child: ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: FadeInImage(
              height: 60,
              width: 60,
              // here `bytes` is a Uint8List containing the bytes for the in-memory image
              placeholder: AssetImage(
                "assets/tick.png",
              ),
              image: NetworkImage(serchuserprofile["profile_image"].toString()),
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            serchuserprofile["name"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            serchuserprofile["contact_no"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                serchuserprofile["usercode"].toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueAccent),
              ),
              Text(
                "USERCODE",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
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
                              return 'Please enter even no.';
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
                                      _searchUser();
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
