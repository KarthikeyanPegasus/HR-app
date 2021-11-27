import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Constants.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Screens/Hrsearch.dart';
import 'package:hrapplication/Views/Screens/hralldash.dart';

import 'hrallsearch.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard(
      {Key? key, required this.emp_id, required this.emp_list})
      : super(key: key);
  final String emp_id, emp_list;
  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late http_service http;
  List arr = [];
  late List1 jsonlist, jsonlists;
  late List droplist;
  bool isloaded = false;
  int _selectedIndex = 0;
  late List accesslist = [];
  late List employe_list = widget.emp_list.toString().split(",");
  List<String> companylist = [];
  late String absent = "",
      spun = "",
      leave = "",
      duration = "",
      late = "",
      experience = "",
      name = "",
      desig = "",
      photo = "";

  Future getUser() async {
    var datas = {};
    Response responses = await http.getResponse("getdropdown", datas);

    if (responses.statusCode == 200) {
      setState(() {
        jsonlists = List1.fromJson(responses.data);
        droplist = jsonlists.list1;
        log(droplist.toString());
      });
      for (String i in droplist) {
        companylist.add(json.decode(i)[1]);
      }
      log(companylist.toString());
    }

    var data = {'emp_id': widget.emp_id};
    Response response = await http.getResponse("employee", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        log(arr.toString());
        name = json.decode(arr[0])[1].toString();
        desig = json.decode(arr[0])[2].toString();
        absent = json.decode(arr[0])[3].toString();
        spun = json.decode(arr[0])[4].toString();
        leave = json.decode(arr[0])[5].toString();
        duration = json.decode(arr[0])[6].toString();
        late = json.decode(arr[0])[7].toString();
        experience = json.decode(arr[0])[8].toString();
        photo = json.decode(arr[0])[9].toString();
        //log(employe_list.toString());
        log(photo);
        if (employe_list[employe_list.length - 1] == "0") {
          accesslist = [];
        } else {
          for (int i = 0; i < employe_list.length; i++) {
            accesslist.add(companylist[int.parse(employe_list[i])]);
          }
        }
        log(accesslist.toString());
        isloaded = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    http = http_service();

    getUser();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_selectedIndex == 1) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => Dashboard(
                empname: name,
                empid: widget.emp_id,
                accesslist: accesslist,
                empdsg: desig,
                emp_list: widget.emp_list)));
      } else if (_selectedIndex == 2) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => Search(
                empname: name,
                empid: widget.emp_id,
                empdsg: desig,
                accesslist: accesslist,
                emp_list: widget.emp_list)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double container_width = size.width * 0.8;
    double container_height = size.height * 0.7;
    return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "DashBoard",
            ),
          ),
        ),
        body: isloaded
            ? Container(
                width: size.width,
                padding: EdgeInsets.only(top: 25),
                child: SingleChildScrollView(
                  child: Container(
                    width: container_width,
                    height: container_height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            child: photo == "Null" || photo == "null"
                                ? Icon(
                                    Icons.account_box,
                                    size: 125,
                                  )
                                : Container(
                                    child: Image.memory(
                                      base64Decode(photo),
                                      fit: BoxFit.cover,
                                      height: 225,
                                      width: 225,
                                    ),
                                  ),
                          ),
                        ),
                        Text(
                          name, //replace with the count from the db.
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          desig, //replace with the count from the db.
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Experience : " +
                              experience, //replace with the count from the db.
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
//attendance,leavebalance,payroll
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            DtwiseEmployee(
                                              absent: absent,
                                              spun: spun,
                                              leave: leave,
                                              empname: name,
                                              empid: widget.emp_id,
                                              empdsg: desig,
                                              emp_list: widget.emp_list,
                                              accesslist: accesslist,
                                            )));
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 25),
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Text(
                                    "Time-Office",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.blue),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 25),
                              width: 100,
                              height: 100,
                              child: Center(
                                child: Text(
                                  "Leave Balance",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 25),
                              width: 100,
                              height: 100,
                              child: Center(
                                child: Text(
                                  "Payroll",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                label: "dashboard"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.dashboard,
                  color: Colors.black,
                ),
                label: "dashboard"),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              label: "search",
            )
          ],
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
        ));
  }
}

class LineTitles {
  static gettitledata() => FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        margin: 8,
      ),
      topTitles: SideTitles(showTitles: false, margin: 8),
      rightTitles: SideTitles(showTitles: false));
}
