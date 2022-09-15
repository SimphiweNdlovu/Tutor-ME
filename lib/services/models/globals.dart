import 'package:tutor_me/services/models/users.dart';

class Globals {
  late Users _user;
  String _filesUrl = 'tutormefilesystem-dev.us-east-1.elasticbeanstalk.com';
  String _tutorMeUrl = 'tutormeapi-dev.us-east-1.elasticbeanstalk.com';
  String _token = 'Bearer ';
  String _refreshToken = '';

  late Map<String, String> header;

  Globals(Users? user, String token, String refreshToken) {
    if(user!=null){
      _user = user;
    }
    _token += token;
    _refreshToken = refreshToken;
    header = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      'Authorization': _token,
    };
  }

  Users get getUser => _user;
  String get getFilesUrl => _filesUrl;
  String get getTutorMeUrl => _tutorMeUrl;
  Map<String, String> get getHeader => header;
  String get getToken => _token;
  String get getRefreshToken => _refreshToken;

  set setUser(Users user) {
    _user = user;
  }

  set setGetFilesUrl(String filesUrl) {
    _filesUrl = filesUrl;
  }

  set setTutorMeUrl(String tutorMeUrl) {
    _tutorMeUrl = tutorMeUrl;
  }

  set setHeader(Map<String, String> header) {
    this.header = header;
  }

  set setToken(String token) {
    _token = token;
  }
  
  set setRefreshToken(String refreshToken){
    _refreshToken = refreshToken;
  }

  Globals.fromJson(Map<String, dynamic> json) {
    _user = Users.fromObject(json['user']);
    _token = json['token'];
    _refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = _user.toMap();
    data['token'] = _token;
    data['refreshToken'] = _refreshToken;
    return data;
  }
}
