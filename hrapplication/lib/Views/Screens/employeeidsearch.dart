import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Views/Screens/empdetail.dart';
import 'package:intl/intl.dart';
import 'package:hrapplication/Constants.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Widgets/listItems.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'Hrdashboard.dart';
import 'hralldash.dart';

class Idsearch extends StatefulWidget {
  const Idsearch(
      {Key? key,
      required this.empname,
      required this.empid,
      required this.empdsg,
      required this.emp_list,
      required this.accesslist})
      : super(key: key);

  final String empname, empid, empdsg;
  final String emp_list;
  final List accesslist;

  @override
  _IdsearchState createState() => _IdsearchState();
}

class _IdsearchState extends State<Idsearch> {
  late http_service http;
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  List arr = [];
  int _selectedIndex = 2;
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
    log("Comp" + comp.toString());
    log("allcompany" + allcompany.toString());
    log("companylist" + companylist.join(','));
    Response response = await http.getResponse("", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        log(arr.toString());
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_selectedIndex == 0) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => EmployeeDashboard(
                emp_id: widget.empid, emp_list: widget.emp_list)));
      } else if (_selectedIndex == 1) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => Dashboard(
                empname: widget.empname,
                empid: widget.empid,
                accesslist: widget.accesslist,
                empdsg: widget.empdsg,
                emp_list: widget.emp_list)));
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
      log("All company >>" + allcompany.toString());
      log(companylist.toString());
      companylist = widget.accesslist.cast();
      if (companylist.contains("All")) {
      } else {
        companylist.add("All");
      }

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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

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
                                      log(from);
                                    });
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: _width * 0.2,
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
                                    width: _width * 0.2,
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
                              FloatingSearchBar(
                                hint: 'Search...',
                                scrollPadding:
                                    const EdgeInsets.only(top: 16, bottom: 56),
                                transitionDuration:
                                    const Duration(milliseconds: 800),
                                transitionCurve: Curves.easeInOut,
                                physics: const BouncingScrollPhysics(),
                                axisAlignment: isPortrait ? 0.0 : -1.0,
                                openAxisAlignment: 0.0,
                                width: isPortrait ? 600 : 500,
                                debounceDelay:
                                    const Duration(milliseconds: 500),
                                onQueryChanged: (query) {
                                  // Call your model, bloc, controller here.
                                },
                                // Specify a custom transition to be used for
                                // animating between opened and closed stated.
                                transition:
                                    CircularFloatingSearchBarTransition(),
                                actions: [
                                  FloatingSearchBarAction(
                                    showIfOpened: false,
                                    child: CircularButton(
                                      icon: const Icon(Icons.place),
                                      onPressed: () {},
                                    ),
                                  ),
                                  FloatingSearchBarAction.searchToClear(
                                    showIfClosed: false,
                                  ),
                                ],
                                builder: (context, transition) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Material(
                                      color: Colors.white,
                                      elevation: 4.0,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: Colors.accents.map((color) {
                                          return Container(
                                              height: 112, color: color);
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
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
                                      log(from);
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
