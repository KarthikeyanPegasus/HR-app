import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required double width,
    required this.date,
    required this.present,
    required this.absent,
    required this.ot,
    required this.early,
    required this.late,
    required this.onroll,
  })  : _width = width,
        super(key: key);

  final double _width;
  final String date, present, absent, ot, early, late, onroll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width * 0.92,
      height: 150,
      margin: EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            borderRadius: BorderRadius.circular(25)),
        child: Column(
          children: [
            Container(
                height: 75,
                child: Center(
                    child: Text(
                  date,
                  style: TextStyle(fontSize: 20),
                ))), //here comes the date
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: RichText(
                    text: TextSpan(
                      text: 'Present: ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: present + "/" + onroll,
                        ),
                      ],
                    ),
                  )),
                  Container(
                      child: RichText(
                    text: TextSpan(
                      text: 'Absent: ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: absent + "/" + onroll,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: RichText(
                    text: TextSpan(
                      text: 'Over-Time: ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ot,
                        ),
                      ],
                    ),
                  )),
                  Container(
                      child: RichText(
                    text: TextSpan(
                      text: 'Early: ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: early,
                        ),
                      ],
                    ),
                  )),
                  Container(
                      child: RichText(
                    text: TextSpan(
                      text: 'Late: ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: late,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
