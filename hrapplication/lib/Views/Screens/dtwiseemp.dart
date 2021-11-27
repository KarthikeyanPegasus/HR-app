import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:intl/intl.dart';

import '../../Constants.dart';

class Dtwise extends StatefulWidget {
  const Dtwise(
      {Key? key,
      required this.empname,
      required this.empid,
      required this.empdsg,
      required this.fromdate,
      required this.todate})
      : super(key: key);
  final String empname, empid, empdsg, fromdate, todate;

  @override
  _DtwiseState createState() => _DtwiseState();
}

late String from = "", to = "";

class _DtwiseState extends State<Dtwise> {
  int _selectedIndex = 0;
  DateTime fromTime = DateTime(
      DateTime.now().day - 1, DateTime.now().month, DateTime.now().year);
  DateTime toTime =
      DateTime(DateTime.now().day, DateTime.now().month, DateTime.now().year);
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  late List1 jsonlist;
  bool isloaded = true;
  late http_service http;
  List arr = [];
  bool isfrompicked = false;
  bool istopicked = false;
  bool isshow = false;
  Future getUser() async {
    // String from = dateFormat.format(fromTime);
    // String to = dateFormat.format(toTime);
    var data = {
      'empid': widget.empid,
      'fromdate': from,
      'todate': to,
    };
    Response response = await http.getResponse("dt", data);

    if (response.statusCode == 200) {
      setState(() {
        log(from);
        log(to);
        jsonlist = List1.fromJson(response.data);
        arr = jsonlist.list1;
        isloaded = true;
        log(arr.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    http = http_service();

    log(from);
    log(to);

    getUser();
    isloaded = false;
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
              widget.empname + "\n" + widget.empdsg,
            ),
          ),
        ),
      ),
      body: isloaded
          ? Container(
              height: _height,
              width: _width,
              child: Column(
                children: [
                  Container(
                    width: _width,
                    height: 42,
                    margin: EdgeInsets.only(top: 12),
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
                                isfrompicked = true;
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
                                    ? "from"
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
                                istopicked = true;
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
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: accentcolor.withAlpha(120),
                          ),
                          child: IconButton(
                              onPressed: () {
                                if (isfrompicked && istopicked) {
                                  from = dateFormat.format(fromTime);
                                  to = dateFormat.format(toTime);
                                }
                                isloaded = false;
                                getUser();
                              },
                              icon: Icon(Icons.search)),
                        )
                      ],
                    ),
                  ),
                  Details(
                    arr: arr,
                  )
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
      extendBody: true,
    );
  }
}

class Details extends StatefulWidget {
  const Details({
    Key? key,
    required this.arr,
  }) : super(key: key);
  final List arr;
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    List arr = widget.arr;
    Size size = MediaQuery.of(context).size;
    double _width = size.width;
    double _height = size.height;
    // ignore: unnecessary_null_comparison
    return arr != null
        ? Container(
            width: _width,
            height: _height * 0.8,
            child: ListView.builder(
              itemBuilder: (context, index) {
                final listing = json.decode(arr[index]);
                final date = listing[5];
                final status = listing[6];
                final intime = listing[7];
                final outtime = listing[8];
                final duration = listing[9];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                      width: _width,
                      child: Datewisecard(
                          date: date,
                          status: status,
                          intime: intime.toString(),
                          outtime: outtime.toString(),
                          duration: duration.toString())),
                );
              },
              itemCount: arr.length,
            ),
          )
        : Center(
            child: Container(
              width: _width,
              height: _height,
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class Datewisecard extends StatelessWidget {
  const Datewisecard({
    Key? key,
    required this.date,
    required this.status,
    required this.intime,
    required this.outtime,
    required this.duration,
  }) : super(key: key);

  final String date, status, intime, outtime, duration;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _width = size.width;
    double _height = size.height;
    return Container(
      width: _width,
      height: _height * 0.07,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.lightBlue.shade900),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: _width * 0.7,
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5, left: 5),
                  alignment: Alignment.topLeft,
                  child: Text(
                    date,
                    style: TextStyle(
                        fontSize: 18,
                        color: accentcolor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    "In-Time:" +
                        intime +
                        " // Out-time :" +
                        outtime +
                        " // Duration: " +
                        duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: accentcolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          status == "P"
              ? Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green),
                  child: Center(
                    child: Text(
                      status,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : status == "AB"
                  ? Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.yellow.shade800),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
        ],
      ),
    );
    //Container(
    //   width: _width,
    //   height: _height * 0.225,
    //   child: Center(
    //     child: Container(
    //       margin: EdgeInsets.only(top: 15),
    //       width: _width * 0.9,
    //       height: _height * 0.2,
    //       decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(25),
    //           color: Colors.grey.withAlpha(120)),
    //       child: Column(
    //         children: [
    //           Container(
    //             margin: EdgeInsets.only(top: 25),
    //             child: Text(
    //               date,
    //               style: TextStyle(fontSize: 20),
    //             ),
    //           ),
    //           Container(
    //               margin: EdgeInsets.only(top: 10),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 children: [
    //                   status == "P"
    //                       ? Container(
    //                           width: 80,
    //                           height: 40,
    //                           decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(10),
    //                               color: Colors.green),
    //                           child: Center(
    //                             child: Text(
    //                               status,
    //                               style: TextStyle(color: Colors.white),
    //                             ),
    //                           ),
    //                         )
    //                       : status == "AB"
    //                           ? Container(
    //                               width: 80,
    //                               height: 40,
    //                               decoration: BoxDecoration(
    //                                   borderRadius: BorderRadius.circular(10),
    //                                   color: Colors.red),
    //                               child: Center(
    //                                 child: Text(
    //                                   status,
    //                                   style: TextStyle(color: Colors.white),
    //                                 ),
    //                               ),
    //                             )
    //                           : Container(
    //                               width: 80,
    //                               height: 40,
    //                               decoration: BoxDecoration(
    //                                   borderRadius: BorderRadius.circular(10),
    //                                   color: Colors.yellow.shade800),
    //                               child: Center(
    //                                 child: Text(
    //                                   status,
    //                                   style: TextStyle(color: Colors.white),
    //                                 ),
    //                               ),
    //                             ),
    //                   Container(
    //                     width: 80,
    //                     height: 40,
    //                     child: Center(
    //                       child: Text(
    //                         "In Time: " + intime,
    //                       ),
    //                     ),
    //                   ),
    //                   Container(
    //                     width: 80,
    //                     height: 40,
    //                     child: Center(
    //                       child: Text(
    //                         "Out Time: " + outtime,
    //                       ),
    //                     ),
    //                   ),
    //                   Container(
    //                     width: 80,
    //                     height: 40,
    //                     child: Center(
    //                       child: Text(
    //                         "Duration: " + duration,
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ))
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    ;
  }
}
