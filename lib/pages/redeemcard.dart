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

class RedeemCard extends StatefulWidget {
  const RedeemCard({Key? key}) : super(key: key);

  //final String title;

  @override
  State<RedeemCard> createState() => RedeemCardPage();
}

class RedeemCardPage extends State<RedeemCard> with TickerProviderStateMixin {
  static const routeName = 'RedeemCard';
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
  final PagingController _pagingController = PagingController(firstPageKey: 0);

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
    int extrapints = int.parse(mypoints["extra_points"].toString());
    int templimit = int.parse(mypoints["limit"].toString());
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _getRedeemListInit(0),
      ),
      child: PagedGridView(
        pagingController: _pagingController,
        showNewPageProgressIndicatorAsGridChild: false,
        showNewPageErrorIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 100 / 75,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 2,
        ),
        builderDelegate:
            PagedChildBuilderDelegate(itemBuilder: (context, item, index) {
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
    ));
  }
}
