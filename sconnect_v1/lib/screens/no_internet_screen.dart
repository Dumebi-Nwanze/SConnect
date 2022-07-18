import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: SvgPicture.asset("../assets/server_down_svg.svg"),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Sorry, it seems you've lost an internet connection",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
