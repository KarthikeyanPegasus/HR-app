import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Views/Screens/dashboard.dart';
import 'package:hrapplication/Views/Screens/empdetail.dart';
import 'package:intl/intl.dart';
import 'package:hrapplication/Constants.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Widgets/listItems.dart';

class Search extends StatefulWidget {
  const Search({Key? key, required this.accesslist, required this.emp_list})
      : super(key: key);
  final List accesslist;
  final String emp_list;
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late http_service http;
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  List arr = [];
  int _selectedIndex = 1;
  late String from = "", to = "";
  String comp = "All";
  late List droplist;
  List<String> companylist = [];
  List<String> allcompany = [];
  late List1 jsonlist;
  bool isloaded = false;
  DateTime fromTime =
      DateTime(DateTime.now().day, DateTime.now().month, DateTime.now().day);
  DateTime toTime =
      DateTime(DateTime.now().day, DateTime.now().month, DateTime.now().day);
  Future getUser() async {
    var data = {
      'fromdate': from,
      'todate': to,
      'company': comp,
      'c_list': companylist.join(','),
      'allcompany': allcompany.join(',')
    };

    log(companylist.join(','));
    log(allcompany.join(','));

    Response response = await http.getResponse("", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        // log(json.decode(arr[1])[0].toString());
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => Dashboard(
                  emp_list: widget.emp_list,
                )));
      }
    });
  }

  Future getdropdownitems() async {
    var data = {};
    Response response = await http.getResponse("getdropdown", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        droplist = jsonlist.list1;
        log(droplist.toString());
        isloaded = true;
      });
      for (var i in droplist) {
        String k = json.decode(i)[1];
        allcompany.add(k);
      }

      companylist = widget.accesslist.cast();

      companylist.add("All");

      log(companylist.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    http = http_service();
    getdropdownitems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _width = size.width;
    double _height = size.height;

    return Scaffold(
        backgroundColor: bodycolor,
        appBar: AppBar(
          title: Container(
            child: Center(
              child: Text(
                "Menu",
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: isloaded
              ? Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: _width,
                        height: 60,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime.now())
                                      .then((date) {
                                    setState(() {
                                      fromTime = date!;
                                      from = dateFormat.format(fromTime);
                                    });
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: _width * 0.3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey.withAlpha(120),
                                    ),
                                    child: Center(
                                      child: Text(from == ""
                                          ? "From"
                                          : fromTime.day.toString() +
                                              "/" +
                                              fromTime.month.toString() +
                                              "/" +
                                              fromTime.year.toString()),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime.now())
                                      .then((date) {
                                    setState(() {
                                      toTime = date!;
                                      to = dateFormat.format(toTime);
                                    });
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: _width * 0.3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey.withAlpha(120),
                                    ),
                                    child: Center(
                                      child: Text(to == ""
                                          ? "to"
                                          : toTime.day.toString() +
                                              "/" +
                                              toTime.month.toString() +
                                              "/" +
                                              toTime.year.toString()),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.grey.withAlpha(120),
                                ),
                                child: DropdownButton<String>(
                                  value: comp,
                                  icon: const Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      comp = newValue!;
                                    });
                                  },
                                  items: companylist
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: accentcolor.withAlpha(120),
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      from = dateFormat.format(fromTime);
                                      to = dateFormat.format(toTime);
                                      getUser();
                                    },
                                    icon: Icon(Icons.search)),
                              )
                            ],
                          ),
                        ),
                      ),
                      arr != null
                          ? Container(
                              width: _width,
                              height: _height * 0.8,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  final listing = json.decode(arr[index]);
                                  final date = listing[0];
                                  final onroll = listing[1];
                                  final present = listing[2];
                                  final late = listing[4];
                                  final early = listing[5];
                                  final ot = listing[6];
                                  final absent = listing[7];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Empdetail(
                                                      currentdate: date,
                                                      fromdate: from,
                                                      comp: comp,
                                                      companylist:
                                                          companylist.join(","),
                                                      allcompany:
                                                          allcompany.join(","),
                                                      todate: to)));
                                    },
                                    child: Container(
                                      width: _width,
                                      child: ListItem(
                                          width: _width,
                                          date: date,
                                          present: present.toString(),
                                          absent: absent.toString(),
                                          ot: ot.toString(),
                                          early: early.toString(),
                                          late: late.toString(),
                                          onroll: onroll.toString()),
                                    ),
                                  );
                                },
                                itemCount: arr.length,
                              ),
                            )
                          : Container(
                              width: _width,
                              height: _height,
                              child: Center(
                                child: Container(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                )),
        ),
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: "dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "search")
          ],
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
        ));
  }
}
