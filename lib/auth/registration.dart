import 'package:flutter/material.dart';
import '../core/uiwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyaltycard/config.dart' as config;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:email_validator/email_validator.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin {
  static const routeName = 'registration';
  UIWidget uiobj = UIWidget();
  @override
  void initState() {
    super.initState();
  }

  final ImagePicker _picker = ImagePicker();
  Random random = new Random();
  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Uint8List? _tempimagedata;
  bool uploadingstatusimage = false;
  String actfileuploded = "";
  ImageProvider tempimage = AssetImage("assets/tick.png");

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
      print(res.reasonPhrase);
      setState(() {
        uploadingstatusimage = false;
        actfileuploded = randomNumber + ".jpg";
        print(actfileuploded);
      });
    } else {
      setState(() {
        uploadingstatusimage = false;
        actfileuploded = '';
      });
    }
  }

  String system_imge_path = "";
  loadImage({ImageSource imagesource = ImageSource.gallery}) async {
    Navigator.of(context).pop();
    final XFile? image = await _picker.pickImage(
        source: imagesource, maxHeight: 1000, imageQuality: 80);
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

  void _chooseCaptureType() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: 100.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 25.0,
                          child: IconButton(
                            onPressed: () =>
                                loadImage(imagesource: ImageSource.camera),
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text("Open Camera")
                      ]),
                      Column(children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 25.0,
                          child: IconButton(
                            onPressed: () =>
                                loadImage(imagesource: ImageSource.gallery),
                            icon: Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text("Open Gallery")
                      ]),
                    ])),
          );
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
                            context, 'home', ModalRoute.withName('home'));
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

  _registration() async {
    setState(() {
      checklogin = false;
    });
    Map jsonData = {
      "name": fullname.text,
      "contact_no": mobile_no.text,
      "email": email.text,
      "wp_no": '',
      "paytm_no": '',
      "address": '',
      "pincode": '',
      "state": '',
      "district": '',
      "city": '',
      "dob": '',
      "doa": '',
      "dealer_firm_name": '',
      "dealer_mob": '',
      "distributor_name": '',
      "profile_image": actfileuploded,
      "password": password.text,
      "rcode": rcode.text,
    };
    print(jsonData);
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
            var profiledata = jsonEncode(registration['userdata']);
            print(profiledata);
            prefs.setString("profile", profiledata).then((value) {
              print(value);
              messageDialog(
                  context,
                  "Thanks for registration, Welcome to Alliance Loyalty Program",
                  'Registration Success',
                  true);
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
          context, "Unable to connect sever", 'Registration Failed', false);
      setState(() {
        checklogin = true;
      });
    }
  }

  bool checklogin = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile_no = new TextEditingController();

  TextEditingController password = TextEditingController();
  TextEditingController repassword = new TextEditingController();

  TextEditingController rcode = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  bool _status = true;
  bool _isEnable = false;
  final FocusNode myFocusNode = FocusNode();
  bool isChecked = false;

  bool _isDisabled = true;

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

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
              height: 180.0,
              color: Colors.white,
              child: new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: new Stack(fit: StackFit.loose, children: <Widget>[
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                              width: 140.0,
                              height: 140.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  image: tempimage,
                                  fit: BoxFit.cover,
                                ),
                              )),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 90.0, right: 100.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 25.0,
                                child: IconButton(
                                  onPressed: () => _chooseCaptureType(),
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          )),
                    ]),
                  )
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Name',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                controller: fullname,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Valid Name';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter Your Name",
                                ),
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Email ID',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: email,
                                validator: (val) =>
                                    !EmailValidator.validate(val!, true)
                                        ? 'Not a valid email.'
                                        : null,
                                decoration: const InputDecoration(
                                    hintText: "Enter Email ID"),
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Mobile',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                controller: mobile_no,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                    hintText: "Enter Mobile Number"),
                                validator: (value) {
                                  if (value?.length != 10) {
                                    return 'Please 10 digit mobile No.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Password',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                controller: password,
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: const InputDecoration(
                                    hintText: "Enter Password"),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Valid Name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                  obscureText: true,
                                  controller: repassword,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                      hintText: "Retype Password"),
                                  validator: (val) {
                                    if (val!.isEmpty) return 'Empty';
                                    if (val != password.text)
                                      return 'Password does not match';
                                    return null;
                                  }),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 0.0, right: 55.0, top: 10.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                      print(isChecked);
                                      //    _isReadonly = value;
                                      _isDisabled = value;
                                    });
                                  },
                                ),
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: Container(
                                child: new Text(
                                  'Do you have any referral code ?',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              flex: 3,
                            ),
                          ],
                        )),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 5.0, top: 2.0),
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: new TextFormField(
                                //   readOnly: _isReadonly,
                                enabled: _isDisabled,

                                controller: rcode,
                                decoration: const InputDecoration(
                                    hintText: "Enter referral code"),
                              ),
                            ),
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                        [Color(0xff081a69), Color(0xff0076a6)],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 40,),
                            Container(
                              child: checklogin
                                  ? Text(
                                      "Register Now",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Quartzo",
                                          color: Colors.white),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Checking..',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Quartzo",
                                                color: Colors.white))
                                      ],
                                    ),
                            ),
                            Opacity(opacity: 0.5, child: Icon(Icons.lock))
                          ],
                        ),
                        50.0,
                        200.0,
                        checklogin
                            ? () {
                                print("working");
                                if (_formKey.currentState!.validate()) {
                                  _registration();
                                }
                              }
                            : null)),
              ],
            ),
          ]),
    );
  }

  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height * 1.0;
    final double _screenHeightButton = _screenHeight * 8 / 100;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Hero(
              tag: "loginimage",
              child: Container(
                padding: EdgeInsets.only(right: 10),
                width: 100,
                child: Image.asset("assets/logo4.webp", height: 40),
              )),
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Container(
            //  height: 500,
            width: double.infinity,
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
            padding: EdgeInsets.only(bottom: 20, top: 20),
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
            // height: _screenHeight - 150,
            child: Column(children: [
              Text("Plumber Registration", style: TextStyle(fontSize: 20),),
              Divider(),
              Container(child: _buildTextFields())
            ]),
          ),
        ));
  }
}
