import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'products.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'categorylist.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  //final String title;

  @override
  State<Category> createState() => CategoryPage();
}

class CategoryPage extends State<Category> with AutomaticKeepAliveClientMixin {
    @override
  bool get wantKeepAlive => true;
  static const routeName = 'categorypage';
  bool loadingorder = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCategoryData();
  }

  bool categoryloade2 = false;
  List categorylist2 = [];

  _getCategoryData() async {
    setState(() {
      categoryloade2 = false;
    });
    String apiurl = ecom_apiendpoint + "/getCategoryList";
    print(apiurl);
    final http.Response response = await http.get(Uri.parse(apiurl));
    if (response.statusCode == 200) {
      setState(() {
        categorylist2 = jsonDecode(response.body);

        setState(() {
          categoryloade2 = true;
        });
      });
    } else {
      setState(() {
        categoryloade2 = true;
      });
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

  String activecategory = "0";
  bool activecategorystatus = false;

  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(children:[
          Container(
              child: CarouselSlider(
            options: CarouselOptions(height: 150.0, aspectRatio: 100/50, viewportFraction:1,autoPlay: true),
            items: [1, 2].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: EdgeInsets.only(left:5, right:5),
                      decoration: BoxDecoration(
                      color: Colors.white,
                    
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                     
                      ]),
                      width: MediaQuery.of(context).size.width,
         
         
                      child: Image.asset("assets/slider$i.webp"));
                },
              );
            }).toList(),
          )),
           Container(
             height: 500,
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: categoryloade2
              ? Column(
                children: [
                  Flexible(
                    child: CategoryList(),


                  )
                 
                ],
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // children: List.generate(
                  //   categorylist2.length,
                  //   (index) {
                  //     int colorindex = index % 6;
                  //     List subcategory = categorylist2[index]["sub_category"];
                  //     var colorcode = colorlist[colorindex];
                  //     String categoryid = categorylist2[index]["category_id"];
                  //     return Container(
                  //          child: Text("data"),
                  //     );
                  //   },
                  // ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 150),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
        )]),
      ),
    );
  }
}
