import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loyaltycard/core/uiwidget.dart';
import 'package:loyaltycard/ecom/model/cartModel.dart';
import "model/addressModel.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'ApiControllers.dart';
import "ui/cartui.dart";

class Address extends StatefulWidget {
  @override
  AddressState createState() => AddressState();
}

class AddressState extends State<Address> {
  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  ContactAddress? _contact;

  ApiController apiobj = ApiController();

  Map userprofile = {};
  bool userloggein = false;
  String kyc_status = "";
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");
    String kyc1 = (prefs.getString('kyc') ?? "").toString();
    if (kyc1.isNotEmpty) {
      Map kyc_status1 = jsonDecode(kyc1);
      setState(() {
        kyc_status = kyc_status1['status'];
      });
    }
    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        _nameController.text = userprofile["name"];
        _mobilePhoneController.text = userprofile["contact_no"];
        _emailController.text = userprofile["email"];
        userloggein = true;
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // use controllers to bind fields to value passed in
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobilePhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobilePhoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _zipcodeController.dispose();

    super.dispose();
  }

  String _appBarTitle = 'Add Contact';

  CartUI uiobj = CartUI();

  bool addingstatus = true;
  String addingstatusstring = "Add Address";

  Future addNewAddress() async {
    setState(() {
      addingstatus = false;
      addingstatusstring = "Submitting...";
    });
    Map<String, dynamic>? addressMap = {
      "name": _nameController.text,
      "contact_no": _mobilePhoneController.text,
      "address1": _addressController.text,
      "email": _emailController.text,
      "zipcode": _zipcodeController.text,
      "user_id": userprofile["id"].toString()
    };
    await apiobj.postCall(addressMap, "/shippingAddress");
    Navigator.of(context).pop(addressMap);
    setState(() {
      addingstatus = true;
      addingstatusstring = "Add Address";
    });
  }

  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle();
    return Scaffold(
      backgroundColor: Colors.white,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Shipping Address",
          // style: TextStyle(fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 6.0, right: 6.0),
                    child: TextFormField(
                      controller: _nameController,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      enabled: (_appBarTitle ==
                          'Add Contact'), // name is the key. can't change it. must delete and re-create.
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Enter valid name';
                        } else if (value.length < 3) {
                          return 'Enter valid name';
                        }
                        return null;
                      },
                      style: textStyle,
                      decoration: uiobj.inputDecoration(textStyle, "Name"),
                    ),
                  ),
                  // Home and Mobile Phones
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 6.0, right: 6.0),
                    child: TextFormField(
                      controller: _mobilePhoneController,
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value!.length != 10) {
                          return 'Please enter valid 10 digit mobile no.';
                        }
                        return null;
                      },
                      style: textStyle,
                      decoration:
                          uiobj.inputDecoration(textStyle, "Mobile No."),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 6.0, right: 6.0),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                      style: textStyle,
                      decoration: uiobj.inputDecoration(textStyle, "Email"),
                    ),
                  ),
                  // Address
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, left: 6.0, right: 6.0),
                    child: TextFormField(
                      controller: _addressController,
                      autocorrect: false,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      validator: (String? value) {
                        if (value!.length < 20) {
                          return 'Enter valid address';
                        }
                        return null;
                      },
                      style: textStyle,
                      decoration: uiobj.inputDecoration(textStyle, "Address"),
                    ),
                  ),
                  // Notes
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 6.0, right: 6.0),
                    child: TextFormField(
                      controller: _zipcodeController,
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value!.length != 6) {
                          return 'Please enter valid 6 digit pincode';
                        }
                        return null;
                      },
                      style: textStyle,
                      decoration: uiobj.inputDecoration(textStyle, "Pincode"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: ElevatedButton(
                      child: Text(
                        addingstatusstring.toString(),
                        textScaleFactor: 1.5,
                      ),
                      onPressed: addingstatus
                          ? () {
                              setState(() {
                                if (_formKey.currentState!.validate()) {
                                  addNewAddress();
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
