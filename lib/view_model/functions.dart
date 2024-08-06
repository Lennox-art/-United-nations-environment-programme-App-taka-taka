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