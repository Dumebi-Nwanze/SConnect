import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:sconnect_v1/screens/solves_screen.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';

import '../models/solves_model.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
}

Future<Uint8List> compressImage(Uint8List? imagefile) async {
  Im.Image? image = Im.decodeImage(imagefile!);
  final compressedImage = Im.encodeJpg(image!, quality: 75);

  return Uint8List.fromList(compressedImage);
}

List<SolvesModel> sortSolves(List<SolvesModel> solves) {
  List<SolvesModel> _solves = solves;
  _solves.sort((a, b) => (b.upvotes.length - b.downvotes.length)
      .abs()
      .compareTo(a.upvotes.length - a.downvotes.length)
      .abs());
  return _solves;
}
