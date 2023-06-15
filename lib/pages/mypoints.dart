import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'redeem.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sharepoints.dart';
import 'package:loyaltycard/rewards/qrcodescan.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:loyaltycard/pages/qrcode.dart';

class MyPoints extends StatefulWidget {
  final bool navigation;
  MyPoints({this.navigation = false});
  //final String title;

  @override
  State<MyPoints> createState() => MyPointsPage();
}

class MyPointsPage extends State<MyPoints> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const routeName = 'points';

  UIWidget uiobj = UIWidget();

  Map userprofile = {};
  bool userloggein = false;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  List pointlist = [];

  Map pointdata = {'totalremain': 0, "debitsum": 0};

  bool show_point_sharebutton = false;

  _getPointList(userid) async {
    print("------------------");
    String apiurl = apiendpoint + "/getUserPoints/" + userid.toString();
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      setState(() {
        pointdata = jsonDecode(response.body);
        int totalpoint = int.parse(pointdata["totalremain"].toString());
        if (totalpoint >= 2) {
          show_point_sharebutton = true;
        }
        print(pointdata);
        pointlist = pointdata['pointlist'];
        // print(pointlist);
      });
    } else {}
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    print(userprofiletemp);
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        //print(userprofile);
        userloggein = true;
        _getPointList(userprofile['id']);
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Widget circleIconButton(
    IconData icon,
    Color inputcolor, {
    onclick: null,
  }) {
    return ElevatedButton(
      child: Icon(
        icon,
        size: 18,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(45, 45),
        padding: EdgeInsets.all(0),
        primary: inputcolor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
      ),
      onPressed: onclick,
    );
  }

  Widget circleIconButtonSmall(
    IconData icon,
    Color inputcolor, {
    onclick: null,
  }) {
    return ElevatedButton(
      child: Icon(
        icon,
        size: 18,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(30, 30),
        padding: EdgeInsets.all(0),
        primary: inputcolor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
      ),
      onPressed: () => onclick,
    );
  }

  void qrPopupShow(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScreen(),
      ),
    );
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: widget.navigation
            ? AppBar(
                title: Text("My Points"),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _getPointList(userprofile['id']),
          ),
          child: SingleChildScrollView(
              child: Column(
            children: [
              userloggein
                  ? uiobj.userCardProfile(userprofile, pointdata,
                      onpressed: () =>
                          qrPopupShow(userprofile["usercode"].toString()))
                  : Container(),
              Container(
                child: show_point_sharebutton
                    ? ElevatedButton.icon(
                        onPressed: () {
                          // _loadUserInfo();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrcodeScan(
                                  userpoints:
                                      pointdata["totalremain"].toString()),
                            ),
                          );
                        },
                        icon: Icon(Icons.share),
                        label: Text("Share Points"))
                    : SizedBox(
                        height: 1,
                      ),
              ),
              Container(
                height: _screenHeight - 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      pointlist.length,
                      (i) {
                        Map pointObj = pointlist[i];
                        bool iscredit = pointObj.containsKey("point_type")
                            ? (pointObj['point_type'] == "Credit")
                            : true;
                        return Container(
                          // height: 140,
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 20.0, // soften the shadow
                                  spreadRadius: -5.0,
                                ),
                              ]),
                          child: ListTile(
                            onTap: () {
                              // presencestatus ? callToUser(userobj["id"]) : "";
                            },
                            minVerticalPadding: 20,
                            leading: InkWell(
                              //  onTap: onimagetap,
                              child: Container(
                                // tag: "contactloglist" + userprofile["id"].toString(),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 21,
                                      backgroundColor: iscredit
                                          ? Colors.indigo
                                          : Colors.orange,
                                      // borderRadius: BorderRadius.circular(50.0),
                                      child: Text(pointObj['points'],
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    Text(
                                      "Point",
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pointObj['description'].toString(),
                                  style: TextStyle(fontSize: 12),
                                ),
                                Divider(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      pointObj['datetime'].toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            trailing: Chip(
                              avatar: CircleAvatar(
                                backgroundColor:
                                    iscredit ? Colors.green : Colors.red,
                                child: Text((iscredit ? "CR" : "DR"),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                              ),

                              // padding: EdgeInsets.only(top:5, bottom: 5),
                              // backgroundColor: Colors.red,
                              label: Text(
                                pointObj['point_type'].toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          )),
        ));
  }
}
