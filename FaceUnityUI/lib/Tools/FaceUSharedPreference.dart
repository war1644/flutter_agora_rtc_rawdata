import 'package:get_storage/get_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class FaceUSharedPreference {
  static final String preKeyName = "faceunity_key_pre_";

  /// 保存
  static Future<void> saveValue(String checkId, double value) async {
    GetStorage box = GetStorage();
    // final prefs = await SharedPreferences.getInstance();
    await box.write(preKeyName + checkId.toString(), value);
  }

  /// 读取
  static Future<double> getValue(String checkId, double defaultValue) async {
    GetStorage box = GetStorage();
    String checkKey = preKeyName + checkId.toString();
    return box.hasData(checkKey) ? box.read(checkKey) : defaultValue;
    // double? res = box.read(checkKey);
    // return res == null ? defaultValue : res;
  }
}
