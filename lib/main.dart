import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'qdZ2Xhrlum8JgDBXMlHGy01yNkmUZfkXDt3fc9X4';
  final keyClientKey = '4lI1uUf5OXPIJLV0u5hzcOkSzNIdD7AfFDdUGZEX';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);
  
  var firstObject = ParseObject('FirstClass')
    ..set(
        'message', 'Hey ! First message from Flutter. Parse is now connected');
  await firstObject.save();
  
  print('done');

}