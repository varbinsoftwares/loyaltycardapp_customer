import 'package:flutter/material.dart';
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
import 'kyc.dart';
import 'package:cool_alert/cool_alert.dart';

class UserProfile extends StatefulWidget {
  @override
  UserProfileUpdation createState() => UserProfileUpdation();
}

class UserProfileUpdation extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  static const routeName = 'profile';
  UIWidget uiobj = UIWidget();
  bool checklogin = true;
  final _formKey = GlobalKey<FormState>();
  Map userprofile = {};
  bool userloggein = false;
  String kyc_status = ' ';
  final ImagePicker _picker = ImagePicker();
  Random random = new Random();
  bool _isDisabled = false;

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

    if (res.statusCode == 200) {
      setState(() {
        uploadingstatusimage = false;
        actfileuploded = randomNumber + ".jpg";
        userprofile["profile_image"] =
            config.mainsite + "/assets/profile_image/" + actfileuploded;
        _registration();
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

  Map kyc_status1 = {};
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    String kyc1 = (prefs.getString('kyc') ?? "").toString();
    // print(userprofiletemp);
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        print('==================');
        print(kyc1);

        if (kyc1.isNotEmpty) {
          kyc_status1 = jsonDecode(kyc1);
          print(kyc_status1);
          kyc_status = kyc_status1['status'];
        }
        /////////////
        fullname.text = userprofile['name'];
        mobile_no.text = userprofile['contact_no'];
        email.text = userprofile['email'];

        userloggein = true;
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  TextEditingController fullname = TextEditingController();
  TextEditingController mobile_no = new TextEditingController();
  TextEditingController email = TextEditingController();

  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
                    child: Text("Ok"),
                    onPressed: () {
                      if (navigation) {
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context, 'home', ModalRoute.withName('home'));
                        Navigator.of(context).pop();
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
      "profile_image": "",
      "id": userprofile['id'].toString()
    };
    if (actfileuploded.isNotEmpty) {
      jsonData["profile_image"] = actfileuploded;
    }
    print(jsonData);
    String apilogin = config.apiendpoint + "/updateProfile";
    var response = await http.post(
      Uri.parse(apilogin),
      body: jsonData,
    );

    if (response.statusCode == 200) {
      Map registration = jsonDecode(response.body);
      print(registration);

      switch (registration['status']) {
        case "401":
          {
            messageDialog(context, "Email or mobile no. already registered",
                'Registration Failed', false);
          }
          break;
        case "200":
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var profiledata = jsonEncode(registration['userdata']);
            prefs.setString("profile", profiledata).then((value) {
              messageDialog(
                  context, "Profile has updated", 'Update Success', true);
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

  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        text: 'Are you sure you want to log out?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () {
          prefs.remove("kyc");
          prefs.remove("profile").then((value) {
            Navigator.pushNamedAndRemoveUntil(
                context, 'login', ModalRoute.withName('/login'));
          });
        });
  }

  removeKyc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("kyc");
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  checkStatus() async {
    String apilogin =
        config.apiendpoint + "/kycStatus/" + userprofile['id'].toString();
    var response = await http.get(
      Uri.parse(apilogin),
    );

    if (response.statusCode == 200) {
      // print(response.body);
      Map registration = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var kycdata = jsonEncode(registration['kycdata']);
      setState(() {
        kyc_status = registration['kycdata']['status'];
      });

      prefs.setString("kyc", kycdata).then((value) {
        print(value);
      });
    }
  }

  Widget _getUpdateStatus() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14.0,
        child: new Icon(
          Icons.refresh,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        checkStatus();
      },
    );
  }

  Widget _checkyc(kyc_status) {
    switch (kyc_status) {
      case "In Review":
        {
          return _kycStatusView('In Review');
        }
        break;
      case "Approved":
        {
          return _kycStatusView('Approved');
        }
        break;
      case "Reject":
        {
          return _elevated();
        }
        break;

      default:
        {
          return _elevated();
        }
        break;
    }
  }

  Widget _elevated() {
    return Center(
      child: new Container(
        width: 200,
        child: ElevatedButton(
          // style: ButtonStyle(
          //   backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
          // ),
          onPressed: () {
            Navigator.pushNamed(context, "kyc");
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
              Text(
                'Update KYC',
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _kycStatusView(title) {
    print(title);
    return new Container(
      color: Color(0xffFFFFFF),
      child: Padding(
        padding: EdgeInsets.only(bottom: 25.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'KYC Status - ' + title,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        title.toString() == 'Approved'
                            ? SizedBox()
                            : _getUpdateStatus()
                      ],
                    )
                  ],
                )),
          ],
        ),
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
                    padding: EdgeInsets.only(top: 20.0),
                    child: new Stack(fit: StackFit.loose, children: <Widget>[
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          userloggein
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: FadeInImage(
                                    height: 140,
                                    width: 140,
                                    // here `bytes` is a Uint8List containing the bytes for the in-memory image
                                    placeholder: AssetImage(
                                      "assets/tick.png",
                                    ),
                                    image: NetworkImage(
                                        userprofile["profile_image"]
                                            .toString()),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 140.0,
                                  height: 140.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new ExactAssetImage(
                                          'assets/tick.png'),
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
            // new Container(
            //   width: double.infinity,
            //   child: Text(
            //     'Referal Code: ' + userprofile['rcode'].toString(),
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            //   ),
            // ),
            Divider(height: 10),

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
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Parsonal Information',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _status ? _getEditIcon() : new Container(),
                              ],
                            )
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
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
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextField(
                                controller: fullname,
                                decoration: const InputDecoration(
                                  hintText: "Enter Your Name",
                                ),
                                enabled: !_status,
                                autofocus: !_status,
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
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
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                controller: email,
                                validator: (val) =>
                                    !EmailValidator.validate(val!, true)
                                        ? 'Not a valid email.'
                                        : null,
                                decoration: const InputDecoration(
                                    hintText: "Enter Email ID"),
                                enabled: !_status,
                                autofocus: !_status,
                              ),
                              // child: new TextField(
                              //   decoration: const InputDecoration(
                              //       hintText: "Enter Email ID"),
                              //   enabled: !_status,
                              // ),
                            ),
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
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
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                 keyboardType: TextInputType.phone,
                                controller: mobile_no,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Valid Mobile No.';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: "Enter Mobile Number"),
                                enabled: !_status,
                                autofocus: !_status,
                              ),
                            ),
                          ],
                        )),
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
                    width: 165,
                    child: !_status ? uiobj.genButton(
                        context,
                        [Color(0xff081a69), Color(0xff0076a6)],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 40,),
                            Container(
                              child: checklogin
                                  ? Text(
                                      "Upate Profile",
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
                                        Text('Saving..',
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
                            : null):SizedBox(height: 2,)),
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
          title: Text("My Profile"),
          actions: [
            IconButton(onPressed: _handleLogout, icon: Icon(Icons.logout)),
            // IconButton(onPressed: removeKyc, icon: Icon(Icons.close))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            // height: _screenHeight - 150,
            child: Container(child: _buildTextFields()),
          ),
        ));
  }
}
