import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loyaltycard/core/uiwidget.dart';

class ProductDetails extends StatefulWidget {
  final Map productobj;
  ProductDetails({required this.productobj});
  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails> {
  UIWidget uiobj = UIWidget();
  Map productoptionsselect = {};
  List coloroptions = [];
  List optionslist = [];
  int cartdatacount = 0;

  @override
  void initState() {
    super.initState();

    Map productobj = widget.productobj;
  }

  Map userprofile = {};
  bool checkuserdetails = false;

  Widget build(BuildContext context) {
    final Map productobj = widget.productobj;

    return Scaffold(
      backgroundColor: Colors.white,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          productobj['category_nav'],
          // style: TextStyle(fontSize: 15),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: Hero(
                tag: "product" + productobj["id"],
                child: CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 1,
                      height: MediaQuery.of(context).size.height - 420,
                      autoPlay: true,
                    ),
                    items: [
                      FadeInImage(
                        placeholder: AssetImage('assets/icon.png'),
                        image: NetworkImage(productobj["image"]),
                        fit: BoxFit.contain,
                      ),
                    ]),
              )),
              Container(
                color: Colors.white10,
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 20, right: 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 
                    uiobj.headingText(productobj['title'],fontSize: 15.0),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Modal No.: " + productobj['sku'],
                          style: TextStyle(fontSize: 15),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite_outline,
                              color: Colors.redAccent,
                            ))
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Price:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              productobj['price'],
                              style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              productobj['price'],
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
         
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                child: SingleChildScrollView(
                    //  padding: EdgeInsets.all(10),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    uiobj.headingText("Description"),
                    Text(
                      productobj['description'],
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 20,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    )
                  ],
                )),
              ),
            ]),
      ),
    );
  }
}
