import 'package:flutter/material.dart';

class Responsive{
  Responsive();
 ResponsiveDevice getDeviceType(BuildContext context){
  final double mediaWidth=MediaQuery.of(context).size.width;
    if(mediaWidth>=1024){
      return ResponsiveDevice.desktop;
    }
    else if(mediaWidth>=768){
      return ResponsiveDevice.tablet;
    }
    else{
      return ResponsiveDevice.mobile;
    }
  }
  }

enum ResponsiveDevice{
  mobile,
  tablet,
  desktop,
}