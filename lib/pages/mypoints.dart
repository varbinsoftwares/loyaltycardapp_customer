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

class MyPoints extends StatefulWidget {
  const MyPoints({Key? key}) : super(key: key);

  //final String title;

  @override
  State<MyPoints> createState() => MyPointsPage();
}

class MyPointsPage extends State<MyPoints> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const routeName = 'points';

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
    //print(userprofiletemp);
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

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _getPointList(userprofile['id']),
          ),
          child: SingleChildScrollView(
              child: Column(
            children: [
              userloggein
                  ? Container(
                      // height: 200,
                      margin: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 10),
                      // padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            // BoxShadow(
                            //   color: Colors.grey.shade400,
                            //   blurRadius: 20.0, // soften the shadow
                            //   spreadRadius: -5.0,
                            // ),
                          ]),
                      child: InkWell(
                        //onTap: onpofiletap,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0)),
                                  image: DecorationImage(
                                    image:
                                        AssetImage("assets/abs-background.jpg"),
                                    // image: NetworkImage(
                                    //     "https://picsum.photos/200/300/?blur=" +
                                    //         userprofile["id"].toString()),
                                    fit: BoxFit.cover,
                                  )),
                              height: 80,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  // tag: "contactlist" + userprofile["id"].toString(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    // child: Image.asset(
                                    //   "assets/tick.png",
                                    //   height: 100,
                                    //   width: 100,
                                    // ),
                                    child: FadeInImage(
                                      height: 100,
                                      width: 100,
                                      // here `bytes` is a Uint8List containing the bytes for the in-memory image
                                      placeholder: AssetImage(
                                        "assets/tick.png",
                                      ),
                                      image: NetworkImage(
                                          userprofile["profile_image"]
                                              .toString()),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        left: 15, right: 15, bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.pinkAccent,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.green.shade500,
                                                          Colors.lightGreen,
                                                        ],
                                                        begin:
                                                            const FractionalOffset(
                                                                0.0, 0.8),
                                                        end:
                                                            const FractionalOffset(
                                                                0.0, 0.1),
                                                        stops: [0.0, 1.0],
                                                        tileMode:
                                                            TileMode.clamp),
                                                    boxShadow: []),
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: Text(
                                                      pointdata['totalremain']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20)),
                                                )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Total Points",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              userprofile['name']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Divider(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.blue.shade300,
                                                  radius: 10,
                                                  child: Icon(
                                                    Icons.call,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  userprofile['contact_no'],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color:
                                                          Colors.grey.shade800),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Point Used",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  pointdata["debitsum"]
                                                          .toString() +
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.yellow[900]),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              Container(
                child: show_point_sharebutton
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrcodeScan(
                                  userpoints:
                                      pointdata["totalremain"].toString()),
                            ),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SharePoints(
                          //       totalpoints: pointdata['totalremain'].toString(),
                          //     ),
                          //   ),
                          // );
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
