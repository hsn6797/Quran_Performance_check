import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget child;

  ReusableCard({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
//        color: kCardColor,
        child: child);
  }
}
