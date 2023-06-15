import 'package:cool_alert/cool_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:loyaltycard/ecom/model/addressModel.dart';
import 'package:loyaltycard/ecom/model/cartModel.dart';
import "ui/cartui.dart";
import 'package:icon_badge/icon_badge.dart';
import "address.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'ApiControllers.dart';
import "orderDetails.dart";

class ShippingDiscount extends StatefulWidget {
  const ShippingDiscount({Key? key}) : super(key: key);
  @override
  State<ShippingDiscount> createState() => ShippingDiscountPage();
}

class ShippingDiscountPage extends State<ShippingDiscount>
    with TickerProviderStateMixin {
  static const routeName = 'cart';
  bool loadingorder = true;
  CartModel cartobj = CartModel();
  ApiController apiobj = ApiController();
  CartUI uiobj = CartUI();
  CartDetails cartdetails = CartDetails.fromMap({
    'cartproducts': {},
    'totalQuantity': 0,
    'totalAmount': 0,
    'shipping': 0,
    'couponDiscount': 0,
    'couponCode': "",
    'grandTotal': 0,
  });
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Map userprofile = {};
  bool userloggein = false;

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userprofiletemp = (prefs.getString('profile') ?? "");

    setState(() {
      if (userprofiletemp.isNotEmpty) {
        userprofile = jsonDecode(userprofiletemp);
        userloggein = true;
        getShippingAddress();
      } else {
        userloggein = false;
        Navigator.pushNamedAndRemoveUntil(
            context, 'login', ModalRoute.withName('login'));
      }
    });
  }

  @override
  void initState() {
    initCart();
    cartDetails();

    super.initState();
  }

  initCart() async {
    CartDetails cartdetails2 = await cartobj.details();
    setState(() {
      cartdetails = cartdetails2;
    });
  }

  resetList() {
    getCouponAmount();
    // setState(() {});
  }

  Future cartDetails() async {
    CartDetails cartdetails2 = await cartobj.details();
    setState(() {
      cartdetails = cartdetails2;
    });
    getShippingAmount();
    _loadUserInfo();
  }

//Address management list
  bool has_address = false;
  bool loading_address = false;
  ContactAddress address = ContactAddress(
    name: "",
    address1: "",
    zipcode: "0",
    contact_no: "",
    email: "",
  );

  Future addNewAddress() async {
    Map<String, dynamic>? contactaddresss = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Address(),
      ),
    );
    if (contactaddresss != null) {
      Map<String, dynamic> tcontactaddresss = contactaddresss;
      bool has_address1 = true;
      ContactAddress address1 = ContactAddress.fromJson(tcontactaddresss);
      setAddres(has_address1, address1);
    }
  }

  setAddres(bool has_address_v, ContactAddress address_v) {
    getShippingAmount();
    setState(() {
      has_address = has_address_v;
      address = address_v;
    });
  }

  List<ContactAddress> addresslist = [];

  Future getShippingAddress() async {
    setState(() {
      loading_address = true;
    });
    List<ContactAddress> addresslisttemp = [];
    List<Map<String, dynamic>> webaddresslist =
        await apiobj.getDataFromServerList(
            "shippingAddress/" + userprofile["id"].toString());
    setState(() {
      loading_address = false;
    });
    webaddresslist.forEach((element) {
      addresslisttemp.add(ContactAddress.fromJson(element));
    });
    if (addresslisttemp.length > 0) {
      setState(() {
        addresslist = addresslisttemp;

        bool has_address1 = true;
        setAddres(has_address1, addresslisttemp[0]);
      });
    }
  }

  Future getShippingAmount() async {
    Map shippingAmount =
        await apiobj.getDataFromServerMap("shippingAmt/" + address.zipcode);
    print(shippingAmount);
    if (shippingAmount.containsKey("attr_val")) {
      cartdetails.setShipping = shippingAmount["attr_val"];
    }
  }
  // end of address list management

  //start of coupon management
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // use controllers to bind fields to value passed in
  final TextEditingController _couponController = TextEditingController();
  bool has_coupon = false;
  bool applyingCoupon = false;
  String applyCode = "Apply Coupon";
  Map coupondata = {
    "has_coupon": 0,
    "coupon_code": "",
    "coupon_discount": "0",
    "coupon_discount_type": "",
    "coupon_message": ""
  };
  Future setCouponAmount() async {
    FocusScope.of(context).unfocus();
    setState(() {
      applyingCoupon = true;
      applyCode = "Applying";
    });

    Map? couponresponse = await apiobj.postCall(
      {
        "couponcode": _couponController.text,
        "total_amount": cartdetails.totalAmount.toString()
      },
      "/applyCoupon",
    );

    if (couponresponse != null &&
        couponresponse.containsKey("has_coupon") &&
        couponresponse["has_coupon"].toString() == "1") {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Coupon has been appied',
        widget: Container(
          padding: EdgeInsets.only(top: 20),
          child: uiobj.h1("You have saved",
              couponresponse["coupon_discount"].toString() + " INR"),
        ),
      );
      setState(() {
        coupondata = couponresponse;
        applyingCoupon = false;
        applyCode = "Apply Coupon";
        has_coupon = true;
        cartdetails.setCouponDiscount =
            couponresponse["coupon_discount"].toString();
        cartdetails.setCouponCode = couponresponse["coupon_code"];
        _couponController.text = "";
      });
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: 'Invalid coupon code',
      );
      resetCoupon();
    }
  }

  resetCoupon() {
    setState(() {
      _couponController.text = "";
      applyingCoupon = false;
      applyCode = "Apply Coupon";
      has_coupon = false;
      cartdetails.setCouponDiscount = "0";
      cartdetails.setCouponCode = "";
      coupondata = {
        "has_coupon": 0,
        "coupon_code": "",
        "coupon_discount": "0",
        "coupon_discount_type": "",
        "coupon_message": ""
      };
    });
  }

  Future getCouponAmount() async {}
  //end of coupon management

  //order Submit Api
  bool submittingOrder = false;
  String submitOrderText = "Order Now";
  Future submitOrder() async {
    setState(() {
      submittingOrder = true;
      submitOrderText = "Submitting..";
    });
    List cartlist = [];
    cartdetails.cartproducts.forEach((key, value) {
      CartProduct cartobj = value;
      cartlist.add(cartobj.toMap());
    });
    Map orderData = {
      "name": address.name,
      "email": address.email,
      "contact_no": address.contact_no,
      "user_id": userprofile["id"].toString(),
      "zipcode": address.zipcode,
      "address": address.address1,
      "total": cartdetails.grandTotal.toString(),
      "sub_total": cartdetails.totalAmount.toString(),
      "quantity": cartdetails.totalQuantity.toString(),
      "coupon_code": cartdetails.couponCode,
      "discount": cartdetails.couponDiscount.toString(),
      "shipping": cartdetails.shipping,
      "cartdata": cartlist
    };
    print("${orderData}");
    Map? orderResponse =
        await apiobj.postCall(orderData, "/orderFromApp", ismultilevel: true);
    if (orderResponse != null && orderResponse.containsKey("order_key")) {
      await cartobj.deleteAllCart();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => OrderDetails(
                    order_key: orderResponse["order_key"],
                  )),
          ModalRoute.withName('home'));
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: 'Unable to generate order, please contact to shop owner',
      );
      Navigator.pushNamedAndRemoveUntil(
          context, 'home', ModalRoute.withName('/home'));
    }
  }
  //Submit Order

  Future<bool> checkBackByUser() async {
    return await CoolAlert.show(
        context: context,
        type: CoolAlertType.confirm,
        text: 'Are you sure you want to go back?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        cancelBtnTextStyle: TextStyle(color: Colors.black),
        confirmBtnColor: Colors.red,
        onCancelBtnTap: () {
          Navigator.of(context).pop(false);
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop(true);
        });
  }

  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => checkBackByUser(),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Shipping & Discount"),
            actions: [
              IconBadge(
                icon: Icon(Icons.shopping_cart_outlined),
                itemCount: cartdetails.totalQuantity,
                badgeColor: Colors.red,
                itemColor: Colors.white,
                hideZero: true,
                onTap: resetList,
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade300,
          bottomNavigationBar: uiobj.bottomBar(Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  uiobj.h2("Sub Total", cartdetails.totalAmount),
                  uiobj.h2("Discount", cartdetails.couponDiscount),
                  uiobj.h2("Shipping", cartdetails.shipping),
                  uiobj.h1("Total Amount", cartdetails.grandTotal),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: has_address
                    ? [
                        submittingOrder
                            ? SizedBox(
                                height: 10,
                              )
                            : uiobj.bottomBarbutton("Back to Cart", () {
                                Navigator.of(context).pop();
                              }, icon: Icons.arrow_back_sharp),
                        SizedBox(
                          width: 20,
                        ),
                        uiobj.bottomBarbutton(
                            submitOrderText,
                            submittingOrder
                                ? null
                                : () {
                                    submitOrder();
                                  })
                      ]
                    : [],
              )
            ],
          )),
          body: Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    uiobj.roundContainer(
                      ListTile(
                        title: Text.rich(
                            TextSpan(text: 'Total ', children: <InlineSpan>[
                          TextSpan(
                            text: cartdetails.totalQuantity.toString(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' item(s) in cart',
                          )
                        ])),
                        contentPadding: EdgeInsets.all(10),
                        trailing: uiobj.h1("", cartdetails.totalAmount),
                      ),
                    ),
                    loading_address
                        ? uiobj.roundContainer(
                            Center(
                              child: Text("Looking for address"),
                            ),
                            padding: EdgeInsets.all(30))
                        : (has_address
                            ? uiobj.addressBlock(address)
                            : uiobj.roundContainer(
                                Column(
                                  children: [
                                    Text("No shipping address found"),
                                    ElevatedButton(
                                        onPressed: addNewAddress,
                                        child: Text("Add Shipping Address"))
                                  ],
                                ),
                              )),
                    SizedBox(
                      height: 30,
                    ),
                    uiobj.roundContainer(
                      Form(
                        key: _formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              height: 60,
                              color: Colors.white,
                              child: TextFormField(
                                controller: _couponController,
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                // name is the key. can't change it. must delete and re-create.
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Coupon Code';
                                  } else if (value.length < 3) {
                                    return 'Enter Coupon Code';
                                  }
                                  return null;
                                },
                                style: TextStyle(fontSize: 16),
                                decoration: uiobj.inputDecoration(
                                    TextStyle(), "Enter Discount Coupon Code"),
                              ),
                            ),
                            uiobj.bottomBarbutton(
                                applyCode,
                                applyingCoupon
                                    ? null
                                    : () {
                                        setState(() {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setCouponAmount();
                                          }
                                        });
                                      },
                                icon: Icons.check)
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(15),
                    ),
                    has_coupon
                        ? uiobj.roundContainer(ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: uiobj.h1(
                                  "Total Saving",
                                  coupondata["coupon_discount"]
                                      .toString()
                                      .toUpperCase()),
                            ),
                            title: Text(
                              coupondata["coupon_code"]
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              coupondata["coupon_message"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: TextButton(
                              child: Icon(Icons.delete),
                              onPressed: resetCoupon,
                            ),
                          ))
                        : SizedBox(
                            height: 0,
                          ),
                  ],
                ),
              );
            },

            /// handles others as you did on question
          ),
        ));
  }
}
