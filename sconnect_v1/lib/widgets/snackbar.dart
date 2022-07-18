import 'package:flutter/material.dart';

snackBar(BuildContext context, String info) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        info,
        style: const TextStyle(),
      ),
      backgroundColor: Colors.black,
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
