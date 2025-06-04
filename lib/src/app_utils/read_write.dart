import 'dart:developer';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

T read<T>(String key, {T? defaultValue}) {
  final value = box.read(key);
  if (value is T) return value;
  return defaultValue as T;
}

void write<T>(String key, T value) {
  box.write(key, value);
}

void remove(String key) {
  box.remove(key);
}

void clearAllData() {
  log('\x1B[31mAlert => Clearing all cached data\x1B[0m');
  box.erase();
}