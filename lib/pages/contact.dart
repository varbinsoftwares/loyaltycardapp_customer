import 'package:flutter/material.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  //final String title;

  @override
  State<Contact> createState() => ContactPage();
}

class ContactPage extends State<Contact> with TickerProviderStateMixin {
  static const routeName = 'pofile';
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("QR"),
      // ),
      body: Center(child: const Text("Contact page")),
    );
  }
}
