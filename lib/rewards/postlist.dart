import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:loyaltycard/core/downloadShare.dart';

class PostList extends StatefulWidget {
  @override
  PostListState createState() => PostListState();
}

enum Filteroptions {
  most_viewed,
  condition_old,
  condition_new,
  price_low,
  price_high,
  none
}

class PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
  //UiElementsFront uiobjfront = new UiElementsFront();
  @override
  bool get wantKeepAlive => true;

  bool loadingproductlist = false;

  UIWidget uiobj = UIWidget();

  List postlist = [];
  static const _pageSize = 20;
  final PagingController _pagingController = PagingController(firstPageKey: 0);

  String category_nav = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Map userprofile = {};
  bool userloggein = false;
  bool isSharing = true;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    print("page key is");
    print(pageKey);
    try {
      final newItems = await _getProductList(pageKey);
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

  _getProductList(int startpage) async {
    String apiurl = apiendpoint + "/getPostData/20/$startpage";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      postlist = jsonDecode(response.body);

      return postlist;
    } else {
      return [];
    }
  }

  bool likeloaing = true;
  _likePost(int index, post_id) async {
    String user_id = userprofile["id"].toString();
    String apiurl = apiendpoint + "/getPostlike/$post_id/$user_id";
    setState(() {
      likeloaing = false;
    });
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));

    if (response.statusCode == 200) {
      Map postlikedata = jsonDecode(response.body);
      print(postlikedata);
      setState(() {
        likeloaing = true;
        postlist[index]["likes"] = postlikedata["likes"];
      });

      const snackBar = SnackBar(
        content: Text('You have liked post'),
      );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List colorlist = [
    Color(0xffacddde),
    Color(0xffcaf1de),
    Color(0xffe1f8dc),
    Color(0xfffef8dd),
    Color(0xffffe7c7),
    Color(0xfff7d8ba),
  ];

  Widget postBlock(BuildContext context, productinfo, postindex, callback) {
    String checkpricecut = productinfo["price"].toString();
    String cutpricecheck = checkpricecut == 'false' ? '' : checkpricecut;
    return Container(
        padding: EdgeInsets.all(5),
// height: 200,

        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 10.0,
            //   ),
            // ],
            // borderRadius: BorderRadius.all(Radius.circular(10)),
            // border: Border.all(
            //   width: 1, //
            //   color: Colors.white, //             <--- border width here
            // ),
            // color: Colors.white,
            ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    width: 2, //
                    color: Colors.white, //             <--- border width here
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    productinfo["has_image"]
                        ? uiobj.ntworkImageWiget(context, productinfo["images"])
                        // FadeInImage(
                        //     // width: 400,
                        //     placeholder: AssetImage('assets/placeholder.jpg'),
                        //     image: NetworkImage(productinfo["images"]),
                        //     fit: BoxFit.contain,
                        //   )
                        : SizedBox(
                            height: 1,
                          ),
                    Divider(),
                    Container(
                        padding: EdgeInsets.all(5),
                        // width: 150,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              productinfo["description"],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )),
                    Divider(),
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        // width: 150,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                    onPressed: likeloaing
                                        ? () => _likePost(
                                            postindex, productinfo["id"])
                                        : null,
                                    icon: Icon(Icons.thumb_up),
                                    label: Text(likeloaing
                                        ? "Like (" +
                                            productinfo["likes"].toString() +
                                            ")"
                                        : "Liking..")),
                                ElevatedButton.icon(
                                    onPressed: isSharing
                                        ? () => shareButton(productinfo)
                                        : null,
                                    icon: Icon(Icons.share),
                                    label:
                                        Text(isSharing ? "Share" : "Sharing")),
                              ],
                            )
                          ],
                        ))
                  ],
                ),
              )),
        ]));
  }

  Future<void> shareButton(productinfo) async {
    setState(() {
      isSharing = false;
    });
    ShareController shareobj = ShareController(
      imageurl: productinfo["images"].toString(),
      content: productinfo["description"].toString() +
          "\n\nहमारी LOYALTY PARTNER CARD ऐप अभी डाउनलोड करे\n",
      storelink:
          "https://play.google.com/store/apps/details?id=com.varbin.loyaltycard2&hl=en_IN&gl=US",
    );
    await shareobj.shareLink();
    setState(() {
      isSharing = true;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              int colorindex = index % 6;
              var colorcode = colorlist[colorindex];
              return postBlock(context, item, index, () {});
            },
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }
}
