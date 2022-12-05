import 'package:flutter/material.dart';

height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}


BoxDecoration myOutlineBoxDecoration(Color color) {
  return BoxDecoration(
    border: Border.all(
        width: 1.0,
      color: color
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(5.0)
    ),
  );
}