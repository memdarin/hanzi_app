import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import '../common/tts.dart';
import '../common/api.dart';

AudioPlayer advancedPlayer = new AudioPlayer();

class HanziDetails extends StatefulWidget {
  var wenziInfo = null;
  HanziDetails({Key key, this.wenziInfo}) : super(key: key);

  @override
  _HanziDetails createState() => new _HanziDetails();
}

class _HanziDetails extends State<HanziDetails> {
  bool isSpeak = false;
  List<String> languages;

  _playSound(String url){
//    advancedPlayer.setUrl(url);
    advancedPlayer.setVolume(1.0);
    advancedPlayer.play(url);
  }

  _findHanziByKeywords(String key) async {
    var hanziinfo = await Api().findHanzi(key);
    setState(() {
      try{
        widget.wenziInfo = json.decode(hanziinfo);
      }catch(e){}
    });
  }

  initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    languages = await Tts.getAvailableLanguages();
  }

  String _noReadRedundantWords(String meaning){
    meaning = meaning.replaceAll(new RegExp(r"基本字义\n.*?\n"), "基本字义，\n")
      .replaceAll(new RegExp(r"其他字义\n.*?\n"), "其他字义，\n")
      .replaceAll("、", "，");
    print('_noReadRedundantWords,meaning=$meaning');
    return meaning;
  }

  @override
  void initState() {
    super.initState();
    String meaning = widget.wenziInfo["meaning"];
    if(meaning==null){
      _findHanziByKeywords(widget.wenziInfo["name"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('$widget.wenziInfo["name"]');
    String meaning = widget.wenziInfo["meaning"];
    final double wid = MediaQuery.of(context).size.width-16.0;
    return new Scaffold(
        appBar: new AppBar(
          titleSpacing: 12.0,
          title: const Text('汉字'),
        ),
        body: (meaning==null) ? (new Center(
            child: Image.asset("images/loading.gif",width: 100.0,),
          )) : new SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              new Stack(
                children: <Widget>[
                  new Image.asset('images/hanzibg.gif',width: wid??300.0, fit: BoxFit.fill,),
                  new Image(
                    image: new NetworkImage(widget.wenziInfo["hanzipic"]),
//                    image: new NetworkImage('http://www.chaziwang.com/pic/zi/${wenziInfo["unicode"].toUpperCase()}.gif'),
                    width: wid??300.0,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Text("拼音：${widget.wenziInfo["pinyin"]}",style: new TextStyle(fontSize:24.0),),
                  new InkWell(
                    onTap: (){_playSound(widget.wenziInfo["fayin"]);},
                    child: new Icon(Icons.volume_up),
                  )
                ],
              ),
              new Divider(height: 16.0,),
              new InkWell(
                onTap: (){
                    isSpeak = true;
                    Tts.speak(_noReadRedundantWords(meaning));
                },
                child: new Text(meaning,style: new TextStyle(fontSize:20.0),),
              )
            ]
          )
        )
    );
  }

  @override
  void deactivate(){
    if(isSpeak==true){
      Tts.stop();
    }
  }
}