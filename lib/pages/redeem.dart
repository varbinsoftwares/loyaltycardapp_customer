import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:cool_alert/cool_alert.dart';
import 'dart:convert';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyaltycard/pages/redeemcard.dart';

class Redeem extends StatefulWidget {
  const Redeem({Key? key}) : super(key: key);

  //final String title;

  @override
  State<Redeem> createState() => RedeemPage();
}

class RedeemPage extends State<Redeem> with TickerProviderStateMixin {
  static const routeName = 'redeem';
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
    //print(userprofiletemp);
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        _pagingController.addPageRequestListener((pageKey) {
          _fetchPage(pageKey);
        });
        _fetchPage(0);
        _getRedeemListInit(0);
        userloggein = true;
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Map mypoints = {
    "limit": "0",
    "paid_amount":"0",
    "total_points": "0",
    "extra_points": "0",
    "points": []
  };

  Future<void> _fetchPage(int pageKey) async {
    print("page key is");
    print(pageKey);
    try {
      Map listdata = await _getRedeemList(pageKey);
      final newItems = listdata["points"];
      print(newItems.length);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  int secondsinterval = 2000;
  Timer? _timer;
  int increament = 0;

  bool loadingproductlist = false;
  List productslist = [];
  static const _pageSize = 20;
  final PagingController _pagingController = PagingController(
    firstPageKey: 0,
  );

  //request for redeem

  _getRedeemList(int startpage) async {
    String user_id = userprofile["id"].toString();
    String apiurl = apiendpoint + "/getUserRewardCard/$user_id/$startpage";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"limit": "0", "total_points": "0", "points": []};
    }
  }

  _getRedeemListInit(int startpage) async {
    String user_id = userprofile["id"].toString();
    String apiurl = apiendpoint + "/getUserRewardCard/$user_id/$startpage";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      Map initcarddata = jsonDecode(response.body);
      print(initcarddata);
      _pagingController.refresh();
      setState(() {
        mypoints = initcarddata;
      });
    } else {}
  }

  requestForRedeem(rewardpoint) async {
    print(rewardpoint);
    CoolAlert.show(
      context: context,
      type: CoolAlertType.loading,
    );
    Map jsonData = {
      "user_id": userprofile["id"].toString(),
      "rewards_point": rewardpoint["points"].toString()
    };
    String apiurl = apiendpoint + "/requestRedeem";
    print(apiurl);
    var response = await http.post(
      Uri.parse(apiurl),
      body: jsonData,
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
      CoolAlert.show(
        context: context,
        backgroundColor: Colors.blue,
        type: CoolAlertType.success,
        text: "Your request has been sent.",
      );
      _pagingController.refresh();
    }
  }
  //end of request for redeem

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    int extrapints = int.parse(mypoints["extra_points"].toString());
    int templimit = int.parse(mypoints["limit"].toString());
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _getRedeemListInit(0),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3366FF),
                        const Color(0xFF0076a6),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 20.0, // soften the shadow
                      spreadRadius: -5.0,
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            "My Rewards",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CircularPercentIndicator(
                            backgroundColor: Colors.white12,
                            progressColor: Colors.lime,
                            animation: true,
                            animationDuration: secondsinterval,
                            radius: 90.0,
                            lineWidth: 10.0,
                            percent: (extrapints * 100 / templimit) / 100,
                            center: new Text(
                                mypoints["extra_points"].toString() +
                                    "/" +
                                    mypoints["limit"].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "My Earning",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Text(
                                "INR",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                mypoints["paid_amount"].toString(),
                                style: TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                              Text(
                                ".00",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Opacity(
                                opacity: 1.0,
                                child: Image.asset(
                                  "assets/trophy.png",
                                  height: 80,
                                ))
                          ])
                    ],
                  )
                ],
              ),
            ),
            SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              height: _screenHeight - 310,
              child: PagedGridView(
                pagingController: _pagingController,
                showNewPageProgressIndicatorAsGridChild: false,
                showNewPageErrorIndicatorAsGridChild: false,
                showNoMoreItemsIndicatorAsGridChild: false,
                
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 100 / 78,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 2,
                ),
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (context){
                    return Center(child:Text("No rewards history found"));
                  },
                    itemBuilder: (context, item, index) {
                  return uiobj.redeemcardChoose(context, item, oncardtap: () {
                    CoolAlert.show(
                        context: context,
                        backgroundColor: Colors.orange,
                        type: CoolAlertType.confirm,
                        text: 'Do you want to send request now',
                        confirmBtnText: 'Yes',
                        cancelBtnText: 'No',
                        confirmBtnColor: Colors.green,
                        onCancelBtnTap: () => Navigator.pop(context),
                        onConfirmBtnTap: () {
                          Navigator.pop(context);
                          requestForRedeem(item);
                        });
                  });
                }),
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
