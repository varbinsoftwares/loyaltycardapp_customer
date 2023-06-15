import 'package:flutter/material.dart';
import 'package:loyaltycard/ecom/model/addressModel.dart';

class CartUI {
  Widget h2(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0))),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 54, 200, 244)))
      ],
    );
  }

  Widget h1(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0))),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red))
      ],
    );
  }

  Widget bottomBar(Widget widget) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 20.0, // soften the shadow
                spreadRadius: -5.0,
              ),
            ]),
        height: 120,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 10),
        child: widget);
  }

  Widget bottomBarbutton(String title, callback,
      {IconData icon = Icons.shopping_cart_checkout_rounded}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      onPressed: callback,
      label: Text(
        title,
        style: TextStyle(fontSize: 15),
      ),
      icon: callback == null
          ? Container(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ))
          : Icon(icon),
    );
  }

  Widget roundContainer(Widget widget, {EdgeInsets? padding}) {
    return Container(
        width: double.infinity,
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
        margin: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        padding: padding,
        // color: Colors.white,
        child: widget);
  }

  Widget addressBlock(ContactAddress address) {
    return this.roundContainer(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(
                text: 'Name: ',
                style: TextStyle(fontWeight: FontWeight.bold),
                children: <InlineSpan>[
                  TextSpan(
                    text: address.name.toString(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ])),
            Text.rich(TextSpan(
                text: 'Contact No.: ',
                style: TextStyle(fontWeight: FontWeight.bold),
                children: <InlineSpan>[
                  TextSpan(
                    text: address.contact_no.toString(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ])),
            SizedBox(
              height: 10,
            ),
            Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(address.address1),
            SizedBox(
              height: 10,
            ),
            Text.rich(TextSpan(
                text: 'Pincode: ',
                style: TextStyle(fontWeight: FontWeight.bold),
                children: <InlineSpan>[
                  TextSpan(
                    text: address.zipcode.toString(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ])),
          ],
        ),
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 10,
        ));
  }

  InputDecoration inputDecoration(TextStyle textStyle, String text) {
    return InputDecoration(
      labelText: text,
      labelStyle: textStyle,
      // errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
      // border: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(5.0),
      // ),
    );
  }
}
