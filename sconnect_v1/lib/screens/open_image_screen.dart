import 'package:flutter/material.dart';

class OpenImageScreen extends StatelessWidget {
  final String photoUrl;
  const OpenImageScreen({Key? key, required this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        backgroundColor: Colors.black54,
        body: Container(
          color: Colors.black54,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Image(
                    fit: BoxFit.scaleDown,
                    image: NetworkImage(photoUrl),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
