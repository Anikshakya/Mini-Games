import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:juju_games/juju_games.dart';
void main() async{
  await GetStorage.init();
  runApp(const JujuGames());
}