import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:food/model/models.dart';
import 'package:food/view_model/firestore_service.dart';
import 'package:food/main.dart';
import 'package:intl/intl.dart';

final Map<String, Uint8List> appImageCache = {};

final Map<String, User> appUserCache = {};

Future<Uint8List?> getImageData (String? url) async {
  if(url == null) return null;

  Uint8List? data = appImageCache[url];
  if(data != null) return data;

  data = await loadNetworkImage(url);
  if(data == null) return null;

  appImageCache[url] = data;
  return data;
}

Future<Uint8List?> getUserPicture (String userId) async {
  User? data = appUserCache[userId];
  if(data != null) return getImageData(data.photoUrl);

  data = await getIt<FirestoreService>().getUserById(userId);
  if(data == null) return null;

  appUserCache[userId] = data;
  return getImageData(data.photoUrl);
}

Future<User?> getUserData (String userId) async {
  User? data = appUserCache[userId];
  if(data != null) return data;

  data = await getIt<FirestoreService>().getUserById(userId);
  if(data == null) return null;


  appUserCache[userId] = data;
  return data;
}

Future<Uint8List?> loadNetworkImage(String? path) async {
  if (path == null) return null;

  final completer = Completer<ImageInfo>();
  var img = NetworkImage(path);
  img
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((info, _) => completer.complete(info)));
  final imageInfo = await completer.future;
  final byteData =
  await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm a');
  return formatter.format(dateTime);
}

const List<AboutData> aboutWelcomeData = [
AboutData("beyond_an_age of_waste.jpeg", "The united nations office at Nairobi(UNON) is setting a global example in sustainability, aiming for a zero-waste compound. At the heart of this initiative is the Taka taka app, which streamlines waste management for the entire UNON community. Employees and contractors  use the app to sort waste correctly, track recycling progress, and participate in waste estimation challenges. Taka taka is turning UNON into a model of environmental responsibility, showcasing how large organizations can lead the way in the global push for sustainability"),
AboutData("food_waste.jpeg", "The United Nations Office at Nairobi(UNON) is pioneering sustainability with Taka taka app, designed to achieve a zero-waste compound. The app empowers the UNON community to sort waste accurately, track progress in recycling and take part in initiatives to minimize waste. Through Taka taka app, UNON is leading by example, demonstrating how technology can facilitate responsible waste management and inspire global sustainability efforts"),
AboutData("plastic_index.jpeg", "UNON's commitment to sustainability is exemplified by the Taka taka app,a ground breaking tool that is driving the compound towards a zero waste. With Taka taka,UNON staff and contractors can participate in fun, rewarding waste challenges and photo uploads and win lunch vouchers for their noble actions. This innovative app is not only transforming waste management at UNON but also setting a new standard for environmental stewardship in large organizations worldwide"),
];