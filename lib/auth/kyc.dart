import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/uiwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyaltycard/config.dart' as config;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:intl/intl.dart';

class Kyc extends StatefulWidget {
  @override
  KycUpdation createState() => KycUpdation();
}

class KycUpdation extends State<Kyc> with SingleTickerProviderStateMixin {
  static const routeName = 'kyc';

  UIWidget uiobj = UIWidget();
  bool checklogin = true;
  final _formKey = GlobalKey<FormState>();
  Map userprofile = {};

  bool userloggein = false;

  Uint8List? _tempimagedata;
  bool uploadingstatusimage = false;
  String actfileuploded = "";
  ImageProvider tempimage = AssetImage("assets/card.png");
  final ImagePicker _picker = ImagePicker();
  Random random = new Random();

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  uploadProfileImage() async {
    actfileuploded = "";
    setState(() {
      uploadingstatusimage = true;
    });
    String randomNumber = generateRandomString(30);
    var request = http.MultipartRequest(
        'POST', Uri.parse(config.apiendpoint + "/fileupload"));
    request.files.add(http.MultipartFile.fromBytes(
        'file', _tempimagedata as List<int>,
        filename: randomNumber + ".jpg"));
    var res = await request.send();

    print("upload $res");
    if (res.statusCode == 200) {
      setState(() {
        uploadingstatusimage = false;
        actfileuploded = randomNumber + ".jpg";
        print(actfileuploded);
        userprofile["profile_image"] =
            config.mainsite + "assets/profile_image/" + actfileuploded;
      });
    } else {
      setState(() {
        uploadingstatusimage = false;
        actfileuploded = '';
      });
    }
  }

  String system_imge_path = "";
  loadImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1000, imageQuality: 80);
    if (image != null) {
      setState(() {
        system_imge_path = image.path;
        print(system_imge_path);
        image.readAsBytes().then((value) {
          _tempimagedata = value.buffer.asUint8List();
          try {
            uploadProfileImage();
          } on Exception catch (e) {
            e.toString();
          }
        });
      });
    }
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    //String kyc1 = (prefs.getString('kyc') ?? "").toString();

    // print(userprofiletemp);
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

  messageDialog(context, message, title, navigation) {

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
                    child: Text(
                      "Ok",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      if (navigation) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'profile', ModalRoute.withName('home'));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
                content: SingleChildScrollView(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                ),
              ));
        });
  }

//////////////////////////////////////////////////////////////////////////
  _requetKyc() async {
    setState(() {
      checklogin = false;
    });
    Map jsonData = {
      "user_id": userprofile['id'].toString(),
      "doc_type": dropdownValue,
      "doc_image": actfileuploded,
    };
    //print(jsonData);
    String apilogin = config.apiendpoint + "/kycRequest";
    //print(apilogin);
    var response = await http.post(
      Uri.parse(apilogin),
      body: jsonData,
    );
    if (response.statusCode == 200) {
      // print(response.body);
      Map registration = jsonDecode(response.body);

      switch (registration['status']) {
        case "401":
          {
            messageDialog(context, "Email or mobile no. already registered",
                'Registration Failed', false);
          }
          break;
        case "100":
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var kycdata = jsonEncode(registration['kycdata']);

            prefs.setString("kyc", kycdata).then((value) {
             
              messageDialog(context, "kyc updation request has been sent  ",
                  'Request Sent', true);
            });
          }
          break;
        default:
          {}
          break;
      }

      setState(() {
        checklogin = true;
      });
    } else {
      messageDialog(
          context, "Unable to connect sever", 'KYC Registration Failed', false);
      setState(() {
        checklogin = true;
      });
    }
  }

///////////////////////////////////////////////////////////////
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  String dropdownValue = "Aadhar";

  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("Aadhar"), value: "Aadhar"),
    DropdownMenuItem(child: Text("Voter ID"), value: "Voter ID"),
    // DropdownMenuItem(child: Text("Driving Licence"), value: "Driving Licence"),
  ];

  Widget _buildTextFields() {
    if (system_imge_path != "") {
      tempimage = FileImage(File(system_imge_path));
    }
    return Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                // height: 180.0,
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    new Column(children: <Widget>[
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                              width: 200.0,
                              height: 200.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                  image: tempimage,
                                  fit: BoxFit.cover,
                                ),
                              )),
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(top: 0.0, right: 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton.icon(
                              label: Text('Select Document'),
                              icon: Icon(Icons.web),
                              onPressed: () {
                                loadImage();
                              },
                            )
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              Divider(
                height: 10,
              ),
              new Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Select document type',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: DropdownButton(
                                    value: dropdownValue,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    items: menuItems,
                                    isExpanded: true,
                                    hint: Text("Select item"),
                                    disabledHint: Text("Disabled"),
                                    icon: Icon(Icons.arrow_drop_down_circle),
                                    iconDisabledColor: Colors.red,
                                    iconEnabledColor: Colors.black,
                                    elevation: 8,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownValue = newValue!;
                                        print(newValue);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )),
                      ]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 160,
                    child: uiobj.genButton(
                      context,
                      [
                        // const Color(0xFFfcb045),
                        // const Color(0xFF833ab4),
                        //  const Color(0xFFfd1d1d),
                        Color(0xff081a69),
                        Color(0xff0076a6)
                      ],
                      checklogin
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // SizedBox(width: 40,),
                                Container(
                                    child: Text(
                                  "Request KYC",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: "Quartzo",
                                      fontSize: 15,
                                      color: Colors.white),
                                )),
                                Opacity(opacity: 0.5, child: Icon(Icons.login))
                              ],
                            )
                          : Container(
                              height: 20,
                              width: 160,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      )),
                                  Text('Checking..',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white))
                                ],
                              ),
                            ),
                      50.0,
                      200.0,
                      () {
                        if (_formKey.currentState!.validate()) {
                          checklogin ? _requetKyc() : null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ]));
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return Scaffold(
        appBar: AppBar(
          title: Text("Update Your KYC"),
          // actions: [
          //   IconButton(onPressed: _handleLogout, icon: Icon(Icons.logout))
          // ],
        ),
        body: SingleChildScrollView(
          child: Container(
            // height: _screenHeight - 150,
            child: Container(child: _buildTextFields()),
          ),
        ));
  }
}
