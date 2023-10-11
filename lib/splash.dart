import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zassway/main.dart';
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => webapp()));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child:Image.asset("assets/logo.png",

              // fit: BoxFit.cover,
              // height: 400,
              // MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.height,
            ),
            // Image.network(
            //   'https://images.pexels.com/photos/1987301/pexels-photo-1987301.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            //   fit: BoxFit.cover,
            // ),
          ),
        ],
      ),
    );
  }
}