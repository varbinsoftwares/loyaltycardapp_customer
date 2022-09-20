import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'products.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  //final String title;

  @override
  State<CategoryList> createState() => CategoryPageList();
}

class CategoryPageList extends State<CategoryList>
    with TickerProviderStateMixin {
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
      backgroundColor: Colors.grey.shade300,
      body: LayoutBuilder(builder: (context, constraints) {
        return GridView.builder(
          itemCount: categorylist2.length,
          itemBuilder: (context, index) {
            Map catobj = categorylist2[index];

            return InkWell(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListViewMainCat(
                          categoryobjmain: catobj,
                        ),
                      ),
                    );
                  });
                  print(activecategorystatus);
                },
                child: Container(
                    //color: Colors.blueGrey,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white,
                        // borderRadius:
                        //     BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.grey.shade400,
                          //   blurRadius: 20.0, // soften the shadow
                          //   spreadRadius: -5.0,
                          // ),
                        ]),
                    height: 100,
                    child: Column(
                      children: [
                        // Image.network((catobj["image"]), height: 70,),
                        CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(catobj["image"])),
                        SizedBox(
                          height: 5,
                        ),
                        Text(catobj['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )));
          },
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5,
            //  childAspectRatio: 5,
          ),
        );
      }),
    );
  }
}
