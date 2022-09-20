import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'productdetail.dart';

class ProductListViewMainCat extends StatefulWidget {
  final Map categoryobjmain;
  //final String gettype;

  ProductListViewMainCat({required this.categoryobjmain});
  @override
  ProductListViewMainCatState createState() => ProductListViewMainCatState();
}

enum Filteroptions {
  most_viewed,
  condition_old,
  condition_new,
  price_low,
  price_high,
  none
}

class ProductListViewMainCatState extends State<ProductListViewMainCat> {
  //UiElementsFront uiobjfront = new UiElementsFront();

  Map checkcategorytype = {
    "maincategory": {
      "title": "title",
      "id": "category_id",
      "endpoint": "category_wise_product"
    },
    "subcategory": {
      "title": "sub_category_name",
      "id": "sub_category_id",
      "endpoint": "subcategory_wise_product"
    }
  };

  bool loadingproductlist = false;
  List productslist = [];
  static const _pageSize = 20;
  final PagingController _pagingController = PagingController(firstPageKey: 0);

  String category_nav = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
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
    String filteroption = filterselect.toString().split('.').last;
    final String category_id = widget.categoryobjmain["category_id"];

    String apiurl =
        ecom_apiendpoint + "/getProductsList/$category_id/20/$startpage";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      productslist = jsonDecode(response.body);
      setState(() {
        category_nav = productslist[0]["category_nav"];
      });
      return productslist;
    } else {
      return [];
    }
  }

  RangeValues _currentRangeValues = const RangeValues(0, 10000);
  String pricerange = "0";
  Filteroptions filterselect = Filteroptions.none;
  filtermodal(context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Product Filter",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                child: Text("Apply"),
                onPressed: () {
                  _pagingController.refresh();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                    child: Column(
                  children: <Widget>[
                    RangeSlider(
                      values: _currentRangeValues,
                      min: 0,
                      max: 10000,
                      divisions: 1000,
                      labels: RangeLabels(
                        _currentRangeValues.start.round().toString(),
                        _currentRangeValues.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                          pricerange =
                              _currentRangeValues.start.round().toString() +
                                  "-" +
                                  _currentRangeValues.end.round().toString();
                        });
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          "Price From: " +
                              _currentRangeValues.start.round().toString(),
                        ),
                        Text(
                          " to: " + _currentRangeValues.end.round().toString(),
                        )
                      ],
                    ),
                    Divider(),
                    ListTile(
                      title: const Text('Price Low to High'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.price_low,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    ListTile(
                      title: const Text('Price Hight to Low'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.price_high,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    ListTile(
                      title: const Text('Oldest'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.condition_old,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    ListTile(
                      title: const Text('Newest'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.condition_new,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    ListTile(
                      title: const Text('Most Viewed'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.most_viewed,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    ListTile(
                      title: const Text('None'),
                      leading: Radio<Filteroptions>(
                        value: Filteroptions.none,
                        groupValue: filterselect,
                        onChanged: (Filteroptions? value) {},
                      ),
                    ),
                    Divider(),
                  ],
                )),
              );
            }),
          );
        });
  }

  Widget productViewBlockV2(BuildContext context, productinfo, callback) {
    String checkpricecut = productinfo["price"].toString();
    String cutpricecheck = checkpricecut == 'false' ? '' : checkpricecut;
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      width: 160,
      decoration: BoxDecoration(
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black12,
          //   blurRadius: 10.0,
          // ),
        ],
        // borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          width: 1, //
          color: Colors.white, //             <--- border width here
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductDetails(productobj: productinfo)),
                );
              },
              child: Hero(
                tag: "product" + productinfo["id"],
                child: FadeInImage(
                  height: 170,
                  placeholder: AssetImage('assets/placeholder.jpg'),
                  image: NetworkImage(productinfo["image"]),
                  fit: BoxFit.cover,
                ),
              )),
          SizedBox(
            height: 5,
          ),
          Container(
              height: 40,
              child: Center(
                child: Text(
                  productinfo["title"],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              )),
          SizedBox(
            height: 5,
          ),
          Container(
              // height: 20,
              child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                productinfo["price"],
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            ]),
          )),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final Map categoryobj = widget.categoryobjmain;
    return Scaffold(
      appBar: AppBar(
        title: Text(category_nav, style: TextStyle(fontSize: 12)),
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedGridView(
          pagingController: _pagingController,
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 100 / 140,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 2,
          ),
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) =>
                productViewBlockV2(context, item, () {}),
          ),
        ),
      ),
    );
  }
}
