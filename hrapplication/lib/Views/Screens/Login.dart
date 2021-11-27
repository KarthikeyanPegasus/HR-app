import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrapplication/Constants.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Screens/dashboard.dart';
import 'package:hrapplication/Views/Screens/Hrdashboard.dart';
import 'package:hrapplication/Views/Screens/employeedashboard.dart';
import 'package:hrapplication/Views/Screens/search.dart';
import 'package:hrapplication/Views/Widgets/textfieldcontainer.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List arr = [];
  List details = [];
  late http_service http;
  late List1 jsonlist;
  late String username, password;
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    http = http_service();
    super.initState();
  }

  Future getUser() async {
    var data = {'username': username, 'password': password};
    Response response = await http.getResponse("login", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;

        if (arr.isEmpty) {
          Fluttertoast.showToast(
              msg: "Check Username and Password or Contact Admin",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          details = json.decode(arr[0]);
          log(details.toString());
          if (details[0] == "No Master") {
            //pure employer
            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => Dashboard(
                      emp_list: details[1],
                    )));
          } else if (details[1] == "0") {
            //pure employee

            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => EmployeeDashboarding(
                      emp_id: details[0],
                      emp_list: "",
                    )));
          } else if (details[1] != null) {
            //division heads
            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => EmployeeDashboard(
                      emp_id: details[0],
                      emp_list: details[1],
                    )));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: accentcolor,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/our_logo.png"),
              Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Textfieldcontainer(
                      child: TextField(
                          controller: usernameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "User Name",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          )))),
              Container(
                child: Textfieldcontainer(
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  username = usernameController.text;
                  password = passwordController.text;
                  FocusScope.of(context).requestFocus(new FocusNode());
                  getUser();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 25),
                  width: size.width * 0.4,
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.green),
                  child: Text(
                    "Proceed",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
