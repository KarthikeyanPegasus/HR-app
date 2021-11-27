import 'package:flutter/material.dart';

class Textfieldcontainer extends StatelessWidget {
  final Widget child;
  const Textfieldcontainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 40),
      width: size.width * 0.8,
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(800),
          borderRadius: BorderRadius.circular(50)),
      child: child,
    );
  }
}
