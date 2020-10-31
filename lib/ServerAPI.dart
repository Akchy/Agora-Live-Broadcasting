import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ServerAPI{

  static var server = 'http://157.245.248.227';

  static Future<int> loginAPI({email,pass}) async {
    var passBytes = utf8.encode(pass);
    var passSHA = sha256.convert(passBytes);
    var url = '$server:/users/login/'+email+'/'+passSHA.toString();
    final response =await http.get(url);
    if(int.parse(response.body)==1){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      print("Login");
      await prefs.setBool('login', true);
    }
    //getDetails(email:email);
    return int.parse(response.body);
  }

  static Future<int> signUpAPI({name, email, pass, gCode, phone}) async {

    var passBytes = utf8.encode(pass);
    var passSHA = sha256.convert(passBytes);
    Map data = {
      'name':name,
      'email': email,
      'pass':passSHA.toString(),
      'phone':phone.toString(),
      'gcode':gCode
    };
    String body = json.encode(data);

    var url = server+'/users';
    http.Response response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if(int.parse(response.body)==1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('gcode', gCode);
      await prefs.setBool('login', true);
    }
    return int.parse(response.body);
  }


  static Future<dynamic> getShops({lat,lon}) async {
    print('Xperion: lat: '+ lat.toString()+' lon: '+lon.toString());
    var url = '$server:/shops/nearby/$lat/$lon';
    final response =await http.get(url);
    return response;
  }

  static Future<dynamic> getTests({id}) async {
    var url = '$server:/users/tests/$id';
    final response =await http.get(url);
    return response;
  }

  static Future<dynamic> getTiming({id}) async{
    var url = '$server:/shops/timing/'+id;
    final response =await http.get(url);
    return response;
  }


}