import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class sharedPerencesFunc{

  Future saveString(key, value) async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.setString(key, value);
  }
  Future getString(key) async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    return pre.get(key);
  }
  Future getAll() async{
    var list = new List();
    SharedPreferences pre = await SharedPreferences.getInstance();
    Set<String> keys = pre.getKeys();
    for(var item in keys){
      var conTemp = pre.get(item);
      list.add(conTemp);
    }
    return list;
  }
  Future deleteString(key) async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.remove(key);
  }
  Future deleteAll() async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.clear();
  }
  Future updateString(key,msg) async{
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.setString(key, msg);
  }
}