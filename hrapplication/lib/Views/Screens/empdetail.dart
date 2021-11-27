import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrapplication/Entity/list1.dart';
import 'package:hrapplication/Interacter/http_service.dart';
import 'package:hrapplication/Views/Screens/dtwiseemp.dart';

import '../../Constants.dart';

class Empdetail extends StatelessWidget {
  const Empdetail(
      {Key? key,
      required this.currentdate,
      required this.fromdate,
      required this.todate,
      required this.comp,
      required this.companylist,
      required this.allcompany})
      : super(key: key);
  final String currentdate, fromdate, todate, comp, companylist, allcompany;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bodycolor,
      appBar: AppBar(
        title: Container(
          child: Center(
            child: Text(
              currentdate,
            ),
          ),
        ),
      ),
      body: Stack(children: [
        Lists(
          fromdate: fromdate,
          todate: todate,
          comp: comp,
          companylist: companylist,
          allcompany: allcompany,
          currentdate: currentdate,
        ),
      ]),
      extendBody: true,
    );
  }
}

class Lists extends StatefulWidget {
  const Lists({
    Key? key,
    required this.fromdate,
    required this.todate,
    required this.currentdate,
    required this.comp,
    required this.companylist,
    required this.allcompany,
  }) : super(key: key);
  final String fromdate, todate, currentdate, comp, companylist, allcompany;
  @override
  _ListsState createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  late http_service http;
  List arr = [];
  bool isloaded = false;
  late List1 jsonlist;
  Future getUser() async {
    var data = {
      'currentdate': widget.currentdate,
      'c_list': widget.companylist,
      'allcompany': widget.allcompany,
      'company': widget.comp
    };
    Response response = await http.getResponse("emp", data);

    if (response.statusCode == 200) {
      setState(() {
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
    log(widget.fromdate);
    http = http_service();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _width = size.width;
    double _height = size.height;
    return isloaded
        ? Container(
            width: _width,
            height: _height * 0.9,
            child: ListView.builder(
              itemBuilder: (context, index) {
                final listing = json.decode(arr[index]);
                final branch = listing[1];
                final empid = listing[2];
                final name = listing[3];
                final desig = listing[4];
                final status = listing[6];
                final intime = listing[7];
                final outtime = listing[8];
                final duration = listing[9];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => Dtwise(
                            empname: name,
                            empid: empid,
                            empdsg: desig,
                            fromdate: widget.fromdate,
                            todate: widget.todate)));
                  },
                  child: Container(
                    width: _width,
                    child: Empcard(
                        width: _width,
                        height: _height,
                        name: name,
                        desig: desig,
                        empid: empid,
                        status: status,
                        intime: intime.toString(),
                        outtime: outtime.toString(),
                        duration: duration.toString(),
                        branch: branch),
                  ),
                );
              },
              itemCount: arr.length,
            ),
          )
        : Center(
            child: Container(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
  }
}

class Empcard extends StatelessWidget {
  const Empcard({
    Key? key,
    required double width,
    required double height,
    required this.name,
    required this.desig,
    required this.status,
    required this.intime,
    required this.outtime,
    required this.duration,
    required this.branch,
    required this.empid,
  })  : _width = width,
        _height = height,
        super(key: key);

  final double _width;
  final double _height;
  final String name, desig, status, intime, outtime, duration, branch, empid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height * 0.1,
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
                    empid + " " + name,
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
                    "Designation :" + desig + "// Branch :" + branch,
                    style: TextStyle(
                      fontSize: 12,
                      color: accentcolor,
                    ),
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
    // return Container(
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
    //               name,
    //               style: TextStyle(fontSize: 20),
    //             ),
    //           ),
    //           Container(
    //             margin: EdgeInsets.only(top: 15),
    //             child: Text(
    //               desig + " in " + branch,
    //               style: TextStyle(fontSize: 16),
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
  }
}
