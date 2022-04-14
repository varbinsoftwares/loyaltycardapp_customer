import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UIWidget {
  styleText1(
    txtstring, {
    fontSize: 12.0,
    fontWeight:FontWeight.normal,
  }) {
    return Text(
      txtstring.toString(),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  headingText(
    txtstring, {
    fontSize: 12.0,
  }) {
    return Text(
      txtstring.toString(),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  ntworkImageWiget(conttext, imageurl, {minHeight = 300}) {
    print(imageurl);
    return CachedNetworkImage(
      // height: 400,
      imageUrl: imageurl,
      // imageBuilder: (context, imageProvider) => Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //         image: imageProvider,
      //         fit: BoxFit.contain,
      //         colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
      //   ),
      // ),
      placeholder: (context, url) => LinearProgressIndicator(
        minHeight: minHeight * 1.0,
        backgroundColor: Colors.white,
        color: Colors.grey.shade100,
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  messageDialog(context, message, title) {
    print(message);

    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ElevatedButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
                content: SingleChildScrollView(
                  child: Text(message),
                ),
              ));
        });
  }

  Widget mainButton(BuildContext context, gradiantlist, buttontxt, image,
      buttonheight, callback) {
    return InkWell(
        onTap: callback,
        child: Container(
            height: buttonheight,
            // width: 300,
            margin: EdgeInsets.only(
              top: 7,
              bottom: 7,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradiantlist),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: 25,
                right: 5,
              ),
              child: Row(
                children: [
                  // SizedBox(width: 40,),
                  Expanded(
                    flex: 7,
                    child: Text(
                      buttontxt,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 23,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Image.asset(
                        image,
                        height: 40,
                      ))
                ],
              ),
            )));
  }

  Widget mainButtonOld(BuildContext context, gradiantlist, buttontxt, image,
      buttonheight, callback) {
    return Container(
        height: buttonheight,
        // width: 300,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradiantlist),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.transparent,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          child: Row(
            children: [
              // SizedBox(width: 40,),
              Expanded(
                flex: 7,
                child: Text(
                  buttontxt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 25, fontFamily: "Quartzo", color: Colors.black),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Image.asset(
                    image,
                    height: 50,
                  ))
            ],
          ),
        ));
  }

  Widget genButton(BuildContext context, gradiantlist, rowchild, buttonheight,
      buttonwidth, callback) {
    return Container(
        height: buttonheight,
        width: buttonwidth,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradiantlist),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.transparent,
            shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: rowchild,
        ));
  }

  Widget loginCheckBlock(BuildContext context) {
    return Container(
        height: 300,
        margin: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Please login or register to ask an query.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontFamily: "Quartzo", color: Colors.black)),
            this.genButton(
                context,
                [Color(0xFF7fd6d0), Color(0xFF3d9690)],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(width: 40,),
                    Container(
                        child: Text(
                      "Login Now",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    )),
                    Opacity(opacity: 0.5, child: Icon(Icons.login))
                  ],
                ),
                50.0,
                200.0, () {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'login', ModalRoute.withName('/'));
              //  Navigator.pushNamed(context, "login");
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                  flex: 4,
                ),
                Expanded(
                  child: Container(
                    // width: 50,
                    child: Text(
                      "Or",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    ),
                  ),
                  flex: 2,
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                  flex: 4,
                ),
              ],
            ),
            this.genButton(
                context,
                [Color(0xFFffce81), Color(0xFFe57433)],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(width: 40,),
                    Container(
                        child: Text(
                      "Registration",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Quartzo",
                          color: Colors.black),
                    )),
                    Opacity(opacity: 0.5, child: Icon(Icons.lock))
                  ],
                ),
                50.0,
                200.0, () {
              // Navigator.pushNamed(context, "registration");
              Navigator.pushNamedAndRemoveUntil(
                  context, 'registration', ModalRoute.withName('/'));
            }),
          ],
        ));
  }

  Widget messageBox(context, message, icontype, {points: 0}) {
    Map icontypedict = {
      "error": {
        "color": Colors.red,
        "icon": Icons.close_rounded,
      },
      "success": {
        "color": Colors.green,
        "icon": Icons.check,
      }
    };
    return Container(
        height: 250,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 20.0, // soften the shadow
                spreadRadius: -5.0,
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: icontypedict[icontype]["color"],
              radius: 30,
              child: Icon(
                icontypedict[icontype]["icon"],
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Divider(
              height: 30,
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  // primary: Colors.green,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                label: Text("Ok"))
          ],
        ));
  }

  Widget redeemcardChoose(context, cardobj, {oncardtap: null}) {
    String statuscard = cardobj["status"];
    switch (statuscard) {
      case "Paid":
        return this.redeemCardBlockPaid(
          context,
          cardobj,
        );
        break;
      case "Waiting":
        return this.redeemCardBlockWaiting(
          context,
          cardobj,
        );
        break;
      default:
        return this
            .redeemCardBlockRedeem(context, cardobj, oncardtap: oncardtap);
    }
  }

  Widget redeemCardBlockWaiting(context, cardobj, {oncardtap: null}) {
    return InkWell(
        onTap: oncardtap,
        child: Container(
          height: 100,
          width: 100,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.pink.shade600,
                  ],
                  begin: const FractionalOffset(0.0, 0.8),
                  end: const FractionalOffset(0.0, 0.1),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 20.0, // soften the shadow
                  spreadRadius: -5.0,
                ),
              ]),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Redeem Rquested",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.pink.shade800,
                      // borderRadius: BorderRadius.circular(50.0),
                      child: Text("20",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ))),
                  SizedBox(
                    height: 5,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Waiting for response\n",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: "20-Dec-2021",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Opacity(
                  opacity: 1,
                  child: Icon(
                    Icons.timer,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget redeemCardBlockPaid(context, cardobj, {oncardtap: null}) {
    return InkWell(
        onTap: oncardtap,
        child: Container(
          height: 100,
          width: 100,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              gradient: LinearGradient(
                  colors: [
                    Colors.green.shade500,
                    Colors.lightGreen,
                  ],
                  begin: const FractionalOffset(0.0, 0.8),
                  end: const FractionalOffset(0.0, 0.1),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cashback Earned",
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Chip(
                backgroundColor: Colors.green.shade700,
                avatar: CircleAvatar(
                  child: Icon(
                    Icons.check,
                    size: 15,
                  ),
                ),
                label: Text(cardobj["amount"],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Paid by PayTM on\n",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: "20-Dec-2021",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget redeemCardBlockRedeem(context, cardobj, {oncardtap: null}) {
    return InkWell(
        onTap: oncardtap,
        child: Container(
          height: 100,
          width: 100,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.blue,
                  ],
                  begin: const FractionalOffset(0.0, 0.8),
                  end: const FractionalOffset(0.0, 0.1),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Points Earned",
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.indigo.shade500,
                  // borderRadius: BorderRadius.circular(50.0),
                  child: Text("20",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ))),
              SizedBox(
                height: 5,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Tap here to redeem ",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: "Redeem Now",
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  //Method for showing the date picker
  pickDateDialog(context) {
    DateTime currentdata = DateTime.now();
    showDatePicker(
            context: context,
            initialDate: DateTime(currentdata.year - 18),
            //which date will display when user open the picker
            firstDate: DateTime(currentdata.year - 60),
            //what will be the previous supported year in picker
            lastDate: DateTime
                .now()) //what will be the up to supported date in picker
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        pickedDate = currentdata;
      }

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(pickedDate);
      return formatted;
    });
  }
}
