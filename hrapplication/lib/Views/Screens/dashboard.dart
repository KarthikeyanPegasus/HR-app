import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Constants.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Screens/search.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.emp_list}) : super(key: key);

  final String emp_list;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late double pre_per, ab_per;
  late List accesslist = [];
  List arr = [];
  String comp = "Present";
  List<String> companylist = [];
  late String date;
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  DateFormat dateFormatchart = DateFormat("dd/MM");
  late List droplist;
  late List employe_list = widget.emp_list.toString().split(",");
  List employeesabsent = [];
  List employeesovertime = [];
  List employeespresent = [];
  List employerdates = [];
  List employeeleaves = [];
  String from = "";
  DateTime fromTime =
      DateTime(DateTime.now().day, DateTime.now().month, DateTime.now().day);

  late http_service http;
  bool isloaded = false;
  late List1 jsonlist, jsonlists;
  late var mindate, maxdate;
  late int present, absent, late, early, overall, overtime, leave;
  List<String> shortlist = ["Present", "Absent", "Overtime", "Leave"];

  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    http = http_service();
    getUser();
    super.initState();
  }

  Future getchart() async {
    log(accesslist.toString());
    var data = {
      'fromdate': from,
      'c_list': accesslist.join(","),
      'company': "All",
      'allcompany': companylist.join(',')
    };
    Response response = await http.getResponse("employerdashboardchart", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        log(arr.toString());
        employeespresent.clear();
        employeesabsent.clear();
        employeesovertime.clear();
        employeeleaves.clear();
        employerdates.clear();

        mindate = json.decode(arr[0])[0];
        // int.parse(json.decode(arr[0])[0][0] + json.decode(arr[0])[0][1]);
        maxdate = json.decode(arr[arr.length - 1])[0];
        for (int i = 0; i < arr.length; i++) {
          employerdates.add(
              int.parse(json.decode(arr[i])[0][0] + json.decode(arr[i])[0][1]));
          employeespresent.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[2]).toDouble()]);
          employeesabsent.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[4]).toDouble()]);
          employeesovertime.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[7]).toDouble()]);
          employeeleaves.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[3]).toDouble()]);
        }

        log(mindate.toString());
        log(maxdate.toString());
        log(mindate.toString());
        log(mindate.toString());
        log(mindate.toString());

        isloaded = true;
      });
    }
  }

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

    for (String i in employe_list) {
      accesslist.add(companylist[int.parse(i)]);
    }
    var data = {
      'fromdate': from,
      'c_list': accesslist.join(","),
      'company': "All",
      'allcompany': companylist.join(',')
    };
    log("Access list" + accesslist.toString());
    Response response = await http.getResponse("employerdashboard", data);

    if (response.statusCode == 200) {
      setState(() {
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        log(arr[0].toString());
        date = arr[arr.length - 1][0];
        overall = json.decode(arr[arr.length - 1])[1];
        present = json.decode(arr[arr.length - 1])[2];
        leave = json.decode(arr[arr.length - 1])[3];
        absent = json.decode(arr[arr.length - 1])[4];
        late = json.decode(arr[arr.length - 1])[5];
        early = json.decode(arr[arr.length - 1])[6];
        overtime = json.decode(arr[arr.length - 1])[7];
        pre_per = json.decode(arr[arr.length - 1])[8];
        ab_per = json.decode(arr[arr.length - 1])[10];
        mindate = json.decode(arr[0])[0];
        // int.parse(json.decode(arr[0])[0][0] + json.decode(arr[0])[0][1]);
        maxdate = json.decode(arr[arr.length - 1])[0];
        for (int i = 0; i < arr.length; i++) {
          employerdates.add(
              int.parse(json.decode(arr[i])[0][0] + json.decode(arr[i])[0][1]));
          employeespresent.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[2]).toDouble()]);
          employeesabsent.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[4]).toDouble()]);
          employeesovertime.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[7]).toDouble()]);
          employeeleaves.add(
              [json.decode(arr[i])[0], (json.decode(arr[i])[3]).toDouble()]);
        }

        log(accesslist.toString());
        log(mindate.toString());
        log(maxdate.toString());
        isloaded = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => Search(
                  accesslist: accesslist,
                  emp_list: widget.emp_list,
                )));
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
        body: Container(
          width: size.width,
          padding: EdgeInsets.only(top: 25),
          child: isloaded
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        overall
                            .toString(), //replace with the count from the db.
                        style: TextStyle(color: Colors.black, fontSize: 48),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Total Employees", //replace with the count from the db.
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        width: size.width,
                        margin: EdgeInsets.only(top: 25),
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                width: container_width,
                                height: 125,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.red),
                                child: Center(
                                    child: Container(
                                        child: Text(ab_per.toString()))),
                              ),
                              Container(
                                width: container_width * pre_per / 100,
                                height: 125,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.green),
                                child: Center(
                                    child: Container(
                                        child: Text(pre_per.toString()))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: container_width * 0.8,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Present :"),
                                  Text(present.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Absent :"),
                                  Text(absent.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Present percentage :"),
                                  Text(pre_per.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Absent percentage :"),
                                  Text(ab_per.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Late :"),
                                  Text(late.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Early :"),
                                  Text(early.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Over Time :"),
                                  Text(overtime.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Leave :"),
                                  Text(leave.toString())
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
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
                                  margin: EdgeInsets.only(top: 25),
                                  height: 50,
                                  width: container_width * 0.3,
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
                            Container(
                              margin: EdgeInsets.only(top: 25),
                              child: Container(
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
                                  items: shortlist
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.only(top: 25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: accentcolor.withAlpha(120),
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    from = dateFormat.format(fromTime);

                                    getchart();
                                  },
                                  icon: Icon(Icons.search)),
                            )
                          ],
                        ),
                      ),
                      comp == "Present"
                          ? Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 25, bottom: 120),
                                height: container_height * 0.5,
                                width: container_width * 1.1,
                                child: LineChart(LineChartData(
                                    minX: dateFormat
                                        .parse(maxdate)
                                        .millisecondsSinceEpoch
                                        .toDouble(),
                                    maxX: dateFormat
                                        .parse(mindate)
                                        .millisecondsSinceEpoch
                                        .toDouble(),
                                    minY: 0,
                                    maxY: overall.toDouble(),
                                    titlesData: FlTitlesData(
                                        show: true,
                                        topTitles:
                                            SideTitles(showTitles: false),
                                        bottomTitles: SideTitles(
                                          showTitles: true,
                                          getTextStyles: (context, value) =>
                                              TextStyle(fontSize: 10),
                                          getTitles: (value) {
                                            final DateTime date = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    value.toInt());
                                            final parts = date
                                                .toIso8601String()
                                                .split("T");
                                            return parts.first.substring(8, 10);
                                          },
                                        ),
                                        rightTitles:
                                            SideTitles(showTitles: false)),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Color(0xFF37434d),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List<FlSpot>.generate(
                                            employeespresent.length,
                                            (i) => FlSpot(
                                                dateFormat
                                                    .parse(
                                                        employeespresent[i][0])
                                                    .millisecondsSinceEpoch
                                                    .toDouble(),
                                                employeespresent[i][1])),
                                        barWidth: 3,
                                      ),
                                    ])),
                              ),
                            )
                          : comp == "Absent"
                              ? Container(
                                  margin: EdgeInsets.only(top: 25, bottom: 120),
                                  height: container_height * 0.5,
                                  width: container_width * 1.1,
                                  child: LineChart(LineChartData(
                                      minX: dateFormat
                                          .parse(maxdate)
                                          .millisecondsSinceEpoch
                                          .toDouble(),
                                      maxX: dateFormat
                                          .parse(mindate)
                                          .millisecondsSinceEpoch
                                          .toDouble(),
                                      minY: 0,
                                      maxY: overall.toDouble(),
                                      titlesData: LineTitles.gettitledata(),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Color(0xFF37434d),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List<FlSpot>.generate(
                                              employeesabsent.length,
                                              (i) => FlSpot(
                                                  dateFormat
                                                      .parse(
                                                          employeesabsent[i][0])
                                                      .millisecondsSinceEpoch
                                                      .toDouble(),
                                                  employeesabsent[i][1])),
                                          barWidth: 3,
                                          colors: [Colors.red, Colors.red],
                                        ),
                                      ])),
                                )
                              : comp == "Overtime"
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 25, bottom: 120),
                                      height: container_height * 0.5,
                                      width: container_width * 1.1,
                                      child: LineChart(LineChartData(
                                          minX: dateFormat
                                              .parse(maxdate)
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          maxX: dateFormat
                                              .parse(mindate)
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          minY: 0,
                                          maxY: overall.toDouble(),
                                          titlesData: LineTitles.gettitledata(),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Color(0xFF37434d),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: List<FlSpot>.generate(
                                                  employeesovertime.length,
                                                  (i) => FlSpot(
                                                      dateFormat
                                                          .parse(
                                                              employeesovertime[
                                                                  i][0])
                                                          .millisecondsSinceEpoch
                                                          .toDouble(),
                                                      employeesovertime[i][1])),
                                              barWidth: 3,
                                              colors: [
                                                Colors.yellow,
                                                Colors.yellow
                                              ],
                                            ),
                                          ])),
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.only(top: 25, bottom: 120),
                                      height: container_height * 0.5,
                                      width: container_width * 1.1,
                                      child: LineChart(LineChartData(
                                          minX: dateFormat
                                              .parse(maxdate)
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          maxX: dateFormat
                                              .parse(mindate)
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          minY: 0,
                                          maxY: overall.toDouble(),
                                          titlesData: LineTitles.gettitledata(),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Color(0xFF37434d),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: List<FlSpot>.generate(
                                                  employeeleaves.length,
                                                  (i) => FlSpot(
                                                      dateFormat
                                                          .parse(
                                                              employeeleaves[i]
                                                                  [0])
                                                          .millisecondsSinceEpoch
                                                          .toDouble(),
                                                      employeeleaves[i][1])),
                                              barWidth: 3,
                                              colors: [
                                                Colors.purple,
                                                Colors.purple
                                              ],
                                            ),
                                          ])),
                                    )
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
        ),
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

class LineTitles {
  static gettitledata() => FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        getTextStyles: (context, value) => TextStyle(fontSize: 10),
        getTitles: (value) {
          final DateTime date =
              DateTime.fromMillisecondsSinceEpoch(value.toInt());
          final parts = date.toIso8601String().split("T");
          return parts.first.substring(8, 10);
        },
      ),
      topTitles: SideTitles(showTitles: false, margin: 8),
      rightTitles: SideTitles(showTitles: false));
}
