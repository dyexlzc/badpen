import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart'; //查找目录的类库
import 'Page_add.dart';
import 'Func_json.dart';
import 'dart:convert';
import 'dart:io';
import 'package:xxtea/xxtea.dart';
import 'Func_file.dart';
import 'package:flutter/services.dart';
import 'package:share_extend/share_extend.dart';
//私/密项目，是一个能够多端同步密码的软件，给用户带来良好的体验
//整套软件采用红ios设计语言。因为好看~~

//void main() => runApp(new MyApp());

var result;
var Cmain = new Mainpen();
var ppp = new BadpenState();

class Mainpen extends StatefulWidget {
  @override
  createState() => new BadpenState();
}

class BadpenState extends State<Mainpen> with SingleTickerProviderStateMixin {
  final TextStyle _biggerFont = new TextStyle(fontSize: 18.0);
  int _currentIndex = 0;
  TabController _tabController;
  String _json;
  var ListJson;
  BuildContext _context;
  Widget _LL;

  int n = 0;

///////////////////////////////Function/////////////////////////////////

  @override
  void initState() {
    super.initState();
    print("初始化主页");
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _setJsonList(BuildContext context, int index) {
    if (result != null) {
      // print("主页面的：" + jsonEncode(result));
      print(index);
      return GestureDetector(
        onTap: () {
          print(xxtea.decryptToString(
              PwdList.fromJson(result.data[index]).content, UserPwd));
          showDialog<Null>(
              context: context,
              child: new CupertinoAlertDialog(
                title: Text(
                  xxtea.decryptToString(
                      PwdList.fromJson(result.data[index]).title, UserPwd),
                  style: TextStyle(color: Color.fromRGBO(23, 177, 255, 1)),
                  softWrap: true, //开启自动换行
                ),
                content: Text(xxtea.decryptToString(
                    PwdList.fromJson(result.data[index]).content, UserPwd)),
              ));
          /* result.data[index]=index;//改变一下  可以成功改变
          print(jsonEncode(result));*/
        },
        child: new Container(
            //width: ,
            /* decoration: BoxDecoration(
              color: Colors.white,
            ),*/
            margin: EdgeInsets.only(top: 2.0),
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                new Text(
                  //这里要将读取的标题也做解密处理
                  xxtea.decryptToString(
                      PwdList.fromJson(result.data[index]).title,
                      // result.data[index]['title'],
                      UserPwd), //使用全局密码解密title
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromRGBO(0, 0, 0, 1)),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.delete,
                    semanticLabel: 'Del',
                  ),
                  onPressed: () {
                    showDialog<Null>(
                      barrierDismissible: false,
                      context: _context,
                      child: new CupertinoAlertDialog(
                        title: new Text("提示"),
                        content: new Text("确认删除  " +
                            xxtea.decryptToString(
                                PwdList.fromJson(result.data[index]).title,
                                UserPwd) +
                            "?"),
                        actions: <Widget>[
                          new CupertinoButton(
                            child: new Text("不删除"),
                            onPressed: () {
                              Navigator.pop(_context);
                            },
                          ),
                          new CupertinoButton(
                            child: new Text("删除"),
                            onPressed: () {
                              // print("当前密文");
                              print(result.data);
                              setState(() {
                                result.data.removeAt(index);
                              });

                              PassBook()
                                  .writeJSON(jsonEncode(result)); //修改后直接写入

                              print(result.data);
                              //执行保存操作
                              Navigator.pop(_context);
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.pencil,
                    semanticLabel: 'Edit',
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          fullscreenDialog: false,
                            builder: (context) => new PageAdd__(
                                Atitle:xxtea.decryptToString(
                                    PwdList.fromJson(result.data[index]).title,
                                    UserPwd),
                                Acontent:xxtea.decryptToString(
                                    PwdList.fromJson(result.data[index])
                                        .content,
                                    UserPwd),
                                Aid:index
                                ))).then(
                      (_) {
                        setState(() {
                          //result = result;
                        });
                      },
                    );
                  },
                ),
              ],
            )),
      );
    } else {
      return Text("aa");
    }
  }



  @override
  Widget build(BuildContext context) {
    _context = context;
    AssetImage('assets/pay.png');
    TextEditingController _ChangePwd = new TextEditingController();
    Widget man = DefaultTextStyle(
        style: new TextStyle(fontStyle: FontStyle.normal),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Color.fromRGBO(255, 255, 255, 0),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  title: Text('首页'),
                  ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                title: Text('设置'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <= 1);
            switch (index) {
              case 0:
                return CupertinoPageScaffold(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    navigationBar: new CupertinoNavigationBar(
                        leading: CupertinoButton(
                          child: Text("退出"),
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        middle: new Text('私密笔记'),
                        trailing: CupertinoButton(
                            //这样设置的按钮没有不居中的问题，因为将padding设置为0
                            padding: EdgeInsets.zero,
                            child: const Tooltip(
                              message: 'Back',
                              child: Icon(CupertinoIcons.plus_circled),
                              excludeFromSemantics: true,
                            ),
                            onPressed: () {
                              print("打开添加page");
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    fullscreenDialog: false,
                                      builder: (context) => PageAdd__(
                                            Atitle: "",
                                            Acontent: "",
                                            Aid: -1,
                                          ))).then(
                                (_) {
                                  setState(() {
                                    //result = result;
                                  });
                                },
                              );
                            })),
                    child: ListView.separated(
                        //直接改变List组件
                        itemCount: result == null ? 0 : result.data.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          return _setJsonList(context, index); //返回指定index的项
                        }));
                break;
              case 1:
                return CupertinoPageScaffold(
                      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                      navigationBar: CupertinoNavigationBar(
                        middle: Text("设置"),
                        automaticallyImplyLeading: false,
                        transitionBetweenRoutes: false,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.5)),
                        child: ListView(
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.only(top: 32.0)),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  border: const Border(
                                    top: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                    bottom: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                  ),
                                ),
                                height: 44.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: Row(
                                      children: <Widget>[
                                        CupertinoButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text(
                                            '更改密码',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    23, 122, 220, 1)),
                                          ),
                                          onPressed: () {
                                            showDialog<Null>(
                                              context: _context,
                                              barrierDismissible: false,
                                              child: new CupertinoAlertDialog(
                                                title: new Text("更改密码"),
                                                content: CupertinoTextField(
                                                  placeholder: "请输入新的密码",
                                                  controller: _ChangePwd,
                                                  obscureText: true,
                                                ),
                                                actions: <Widget>[
                                                  new CupertinoButton(
                                                    child: new Text("取消"),
                                                    onPressed: () {
                                                      Navigator.pop(_context);
                                                    },
                                                  ),
                                                  new CupertinoButton(
                                                    child: new Text("确认"),
                                                    onPressed: () {
                                                      /*showDialog<Null>(
                                                    context: context,
                                                    child: new CupertinoAlertDialog(
                                                      title: Text(
                                                        "正在加密，请勿操作",
                                                        style: TextStyle(color: Color.fromRGBO(0, 0, 255, 1)),
                                                      ),
                                                    ));
                                                  */
                                                      //更改密码需要把json的密码本全部重新加密

                                                      //}
                                                      //step2.将所有data用老密码解密并且用新密码加密
                                                      //try{
                                                      var n =
                                                          result.data.length;
                                                      var _result = result;
                                                      //step1.更改密码
                                                      //setState(){
                                                      _result.pwd =
                                                          xxtea.encryptToString(
                                                              _ChangePwd.text,
                                                              _ChangePwd
                                                                  .text); //自己与自己加密更换密码
                                                      // String _tl=result.data.toString();
                                                      //print(_tl);
                                                      for (var i = 0;
                                                          i < n;
                                                          i++) {
                                                        var title = xxtea
                                                            .decryptToString(
                                                                PwdList.fromJson(
                                                                        result.data[
                                                                            i])
                                                                    .title,
                                                                UserPwd);
                                                        var content = xxtea
                                                            .decryptToString(
                                                                PwdList.fromJson(
                                                                        result.data[
                                                                            i])
                                                                    .content,
                                                                UserPwd);
                                                        //先解密原来的数据

                                                        // setState(){
                                                        // result.data[i].SetProp("555");
                                                        //result.data[i].content=xxtea.encryptToString(content,_ChangePwd.text);
                                                        //}
                                                        var p = new Map<String,
                                                            String>();
                                                        p['title'] = xxtea
                                                            .encryptToString(
                                                                title,
                                                                _ChangePwd
                                                                    .text);
                                                        p['content'] = xxtea
                                                            .encryptToString(
                                                                content,
                                                                _ChangePwd
                                                                    .text);
                                                        //setState(() {
                                                        _result.data[i] = p;
                                                        //});
                                                        //print(title+"---"+content);

                                                      }

                                                      print("二次密文:");
                                                      print(_result.data);
                                                      PassBook().writeJSON(
                                                          jsonEncode(
                                                              _result)); //修改后直接写入
                                                      setState(() {
                                                        UserPwd =
                                                            _ChangePwd.text;
                                                        result = _result;
                                                        // print("用户密码:"+UserPwd);
                                                      });

                                                      /*Navigator.pop(_context);//关闭正在加密的对话框
                                                    showDialog<Null>(
                                                      context: context,
                                                      child: new CupertinoAlertDialog(
                                                        title: Text(
                                                          "加密成功",
                                                          style: TextStyle(color: Color.fromRGBO(0, 255, 0, 1)),
                                                        ),
                                                    ));*/
                                                      //}catch(e){
                                                      // print(e);
                                                      //}
                                                      Navigator.pop(_context);
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 32.0)),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  border: const Border(
                                    top: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                    bottom: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                  ),
                                ),
                                height: 44.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: Row(
                                      children: <Widget>[
                                        CupertinoButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text(
                                            '导出密码本',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    23, 122, 220, 1)),
                                          ),
                                          onPressed: () async{
                                             String dir = (await getApplicationDocumentsDirectory()).path+"/PwdBook.txt";
                                              // 返回本地文件目录
                                            ShareExtend.share(dir, "file"); 
                                            //以文件形式分享
                                            /** 复制到剪粘板 */
                                            print(result.toJson());
                                            print(jsonEncode(result));
                                            Clipboard.setData(new ClipboardData(
                                                text: jsonEncode(result)
                                                    
                                                    )); //复制到截切版
                                            showDialog<Null>(
                                                context: _context,
                                                barrierDismissible: true,
                                                child: new CupertinoAlertDialog(
                                                  content: Text(
                                                    "已复制到剪切板",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 1)),
                                                  ),
                                                ));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.5),
                                  border: const Border(
                                    top: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                    bottom: BorderSide(
                                        color: Color(0xFFBCBBC1), width: 0.0),
                                  ),
                                ),
                                height: 44.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: Row(
                                      children: <Widget>[
                                        CupertinoButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text(
                                            '赞助',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    23, 122, 220, 1)),
                                          ),
                                          onPressed: () {
                                            showDialog<Null>(
                                              context: _context,
                                              barrierDismissible: true,
                                              child: new CupertinoAlertDialog(
                                                content:Column(
                                                children: <Widget>[
                                                  Text(
                                                    "支付宝支持作者，带来更多IOS原生控件作品！",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 1)),
                                                    softWrap: true,
                                                  ),
                                                  Image(
                                                    image: new AssetImage(
                                                        'assets/pay.png'),
                                                    width: 200,
                                                    height: 200,
                                                  ),
                                                ],
                                              ),
                                              title:Text("赞助作者")
                                              )
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                break;
            }
            return null;
          },
        ));
    //step2:读取文本，如果文本为空或者文件没有创建密码，就提示
    //String FileState = PassBook().readJSON();
    // PassBook().readJSON(_context);
    // print(G_json);

    return man;
  }

  ////////////////otherFunction//////////////////////
  ///
 

  localPath() async {
    //获得app缓存位置
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path; //获取到程序路径
      print(appDocPath);
    } catch (err) {
      print(err);
    }
  }


//_getLocalFile函数，获取本地文件目录
  Future<File> _getLocalFile() async {
    // 获取本地文档目录
    String dir = (await getApplicationDocumentsDirectory()).path;
    // 返回本地文件目录
    return new File('$dir/PwdBook.txt');
  }


  // 写入 json 数据,也是直接写入string到文件
  Future<Null> writeJSON(String p) async {
    try {
      await (await _getLocalFile()).writeAsString(p);
    } catch (err) {
      //print(err);
    }
  }

  Save(String title, String content) {
    setState(() {
      result.data.add(new PwdList(title, content));
      print("添加页面的：" + jsonEncode(result));
      writeJSON(jsonEncode(result));
    });
  }
}
