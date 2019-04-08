import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//json格式形如'{"data": [{  "title": "淘宝密码",  "content": "qq292856273xdlzc"},{  "title": "微信",  "content": "qq292856273xdlzc"}]}';
class Father_PwdList {
  //多级嵌套的JSON解析
  var data;
  var pwd;
  Father_PwdList.fromJson(Map<String, dynamic> map)
      : data = map['data'],
        pwd = map['pwd'];
        
  Map<String, dynamic> toJson() => {
        'data': data,
        'pwd': pwd,
      };
}

class PwdList {
  String title;
  String content; //固定类，一个是类别，一个是内容

  PwdList(this.title, this.content);
  SetProp(String t,String c){
    title=t;
    content=c;
  }
  PwdList.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };
}
