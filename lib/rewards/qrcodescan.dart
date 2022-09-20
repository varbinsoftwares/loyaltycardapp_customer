import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/uiwidget.dart';
import 'package:loyaltycard/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/cupertino.dart';
import '../rewards/rewardsceen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyaltycard/pages/sharepoints.dart';

class QrcodeScan extends StatefulWidget {
  final String userpoints;
  QrcodeScan({
    required this.userpoints,
  });
  @override
  _QrcodeScanState createState() => _QrcodeScanState();
}

class _QrcodeScanState extends State<QrcodeScan> {
  String _platformVersion = 'Unknown';

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String qrcode = 'Unknown';
  bool flashon = false;

  @override
  void initState() {
    controller?.resumeCamera();

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void displayDialog(String title, String description) {
    final String category_id = "widget.category_id";
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title == 'Wrong Code'
                ? Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.check_sharp,
                    color: Colors.green,
                  ),
            SizedBox(
              width: 10,
            ),
            new Text(title),
          ],
        ),
        content: new Text(description),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Close"),
            onPressed: () {
              if (title == 'Wrong Code') {
                Navigator.of(context).pop();
                controller?.resumeCamera();
              } else {}
            },
          )
        ],
      ),
    );
  }

  openPassDetails(passid) async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SharePoints(
                  userpoints: widget.userpoints.toString(),
                  mob_card_no: passid.toString(),
                )),
        ModalRoute.withName('home'));
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SharePoints(
    //       userpoints: widget.userpoints.toString(),
    //       mob_card_no: passid.toString(),
    //     ),
    //   ),
    // );
    controller?.resumeCamera();
  }

  //manual feed data
  final _formKeypincode = GlobalKey<FormState>();
  TextEditingController _textpincode = TextEditingController();
  _applymanualcode(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Mobile No.'),
              content: Form(
                key: _formKeypincode,
                child: TextFormField(
                  controller: _textpincode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: "Enter Mobile Number Or Card No."),
                  validator: (value) {
                    if (value?.length != 10) {
                      return 'Please 10 digit mobile No.';
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.search),
                  label: new Text('Search'),
                  onPressed: () {
                    if (_formKeypincode.currentState!.validate()) {
                      Navigator.of(context).pop();
                      openPassDetails(_textpincode.text);
                    }
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.close),
                  label: new Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }
//end of pincode functionF

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    print(controller);
    controller.resumeCamera();
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((event) {
      controller.stopCamera().then((e) {
        openPassDetails(event.code);
      });

      print("${event.code}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: Text("Search User"),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image.asset(
            //   "assets/headerimage.png",
            //   height: 50,
            // ),
            // Divider(
            //   height: 20,
            // ),
            Text('Scan QR Code'),
            Divider(
              height: 20,
            ),
            Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 0, 0, 0), spreadRadius: 3),
                  ],
                ),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: scanArea),
                )),

            ElevatedButton.icon(
              icon: flashon ? Icon(Icons.flash_off) : Icon(Icons.flash_on),
              label: Text("Flash"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Colors.blueGrey))),
              ),
              onPressed: () {
                controller?.toggleFlash();
                setState(() {
                  flashon = !flashon;
                });
              },
            ),
            Divider(
              height: 20,
            ),
            Text('Click here to search mobile no.'),
            ElevatedButton.icon(
                onPressed: () {
                  _applymanualcode(context);
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                label: Text(
                  "Search By Mobile No.",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
