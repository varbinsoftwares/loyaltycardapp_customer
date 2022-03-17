import 'package:flutter/material.dart';
import '../core/uiwidget.dart';
import 'package:loyaltycard/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Map userprofile = {};
  bool userloggein = false;
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "").toString();
    print(userprofiletemp);
    setState(() {
     if (userprofiletemp.isNotEmpty && userprofiletemp!="null")  {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
        Navigator.pushNamedAndRemoveUntil(
            context, 'home', ModalRoute.withName('/home'));
      } else {
        userloggein = false;
      }
    });
  }

  messageDialog(context, message, title, navigation) {
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
                      if (navigation) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'home', ModalRoute.withName('/home'));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
                content: SingleChildScrollView(
                  child: Text(message),
                ),
              ));
        });
  }

  login() async {
    setState(() {
      checklogin = false;
    });
    Map jsonData = {"contact_no": contact_no.text, "name": name.text};
    String apilogin = config.apiendpoint + "/registration";
    print(apilogin);
    var response = await http.post(
      Uri.parse(apilogin),
      body: jsonData,
    );
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      Map registration = jsonDecode(response.body);
      print(registration);

      switch (registration['status'].toString()) {
        case "401":
          {
            messageDialog(
                context, "Unable to login", 'Login Failed', false);
          }
          break;
        case "200":
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var profiledata = jsonEncode(registration['userdata']);
            print(profiledata);
            prefs.setString("profile", profiledata).then((value) {
              print(value);
              messageDialog(
                  context, "Welcome to Ayushi Electronics, You have logged in successfully", 'Login Success', true);
            });
          }
          break;
        default:
          {}
          break;
      }

      // if (registration["status"] == "200") {
      //   print("all done");
      //   messageDialog(context, registration["msg"].toString(),
      //       'Registration Success', true);
      // } else {
      //   messageDialog(context, registration["msg"].toString(),
      //       'Registration Failed', false);
      // }
      setState(() {
        checklogin = true;
      });
    } else {
      messageDialog(
          context, "Unable to connect Would Be", 'Login Failed', false);
      setState(() {
        checklogin = true;
      });
    }
  }

  bool checklogin = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController contact_no = new TextEditingController();
  TextEditingController name = TextEditingController();
  Widget _buildTextFields() {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "loginimage",
              child: Image.asset("assets/headerimage.png", height: 100),
            ),
            Divider(
              height: 30,
            ),
             Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                // border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.3), width: 2),
                color: Color(0xFFf5f5f7),
              ),
              child: TextFormField(
                // keyboardType: TextInputType.name,
                controller: name,
                // obscureText: true,
                style: TextStyle(fontSize: 15, color: Colors.black),
                decoration:
                    new InputDecoration(hintText: "Your Name*", border: null),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Valid Name';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                // border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.3), width: 2),
                color: Color(0xFFf5f5f7),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: contact_no,
                style: TextStyle(fontSize: 15, color: Colors.black),
                decoration:
                    new InputDecoration(hintText: "Mobile No.*", border: null
                        // labelText: "Your Mobile No.",
                        ),
                validator: (value) {
                  if (value.toString().length != 10) {
                    return 'Please Enter 10 Digit Mobile No.';
                  }
                  return null;
                },
              ),
            ),
            Divider(
              height: 10,
            ),
           
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 140,
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
                                "Login Now",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        checklogin ? login() : null;
                      }
                    },
                  ),
                ),
              ],
            ),
            Divider(
              height: 10,
            ),
         ]),
    );
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(""),
        //   backgroundColor: Color(0xff0076a6),
        //   elevation: 0,
        // ),
        backgroundColor: Colors.blue.shade50,
        extendBodyBehindAppBar: true,
        body: Container(
          height: _screenHeight,
          width: double.infinity,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(colors: [
          //     const Color(0xFF833ab4),
          //     const Color(0xFFfd1d1d),
          //   ]),

          // ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 450,
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade500,
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: -10.0,
                      ),
                    ]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                            left: 40,
                            right: 40,
                          ),
                          width: double.infinity,
                          child: _buildTextFields()),
                    ]),
              ),
            ],
          ),
        ));
  }
}
