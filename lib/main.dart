import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

AudioPlayer audioPlayer;
Duration duration;
Duration position;

String localFilePath;

PlayerState playerState = PlayerState.stopped;

get isPlaying => playerState == PlayerState.playing;
get isPaused => playerState == PlayerState.paused;

get durationText =>
    duration != null ? duration.toString().split('.').first : '';
get positionText =>
    position != null ? position.toString().split('.').first : '';

StreamSubscription _audioPlayerStateSubscription;

bool isMuted = false;


void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new AudioApp())));
}


class AudioApp extends StatefulWidget {
  @override
  _AudioAppState createState() => new _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
   // _positionSubscription.cancel();
    //_audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }


  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    /*_audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });*/

    audioPlayer.durationHandler = (Duration d) {
      print('Max duration: $d');
      setState(() => duration = d);
    };

  /*  audioPlayer.positionHandler = (Duration p) => {
    print('Current position: $p');
    setState(() => duration = position);
    }; */

    audioPlayer.completionHandler = () {
      onComplete();
      setState(() {
        position = duration;
      });
    };

    audioPlayer.errorHandler = (msg) {
      print('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    };
  }
  Future<ByteData> loadAsset(String steps) async {
    var step = await rootBundle.load('assets/sounds/$steps.wav');
    return step;
  }

  bool selected;

  Future calling(String music) async{
    play(music);
    onComplete();
  }

  Future playNext(String music) async{
    play(music);
  }

  Future play(String music) async {
    stop();
    //final result = await audioPlayer.play(kUrl);
    var steps = music;
    print(music);
    final file = new File('${(await getTemporaryDirectory()).path}/$steps.wav');
    await file.writeAsBytes((await loadAsset(steps)).buffer.asUint8List());
    final result = await audioPlayer.play(file.path, isLocal: true);

      if (result == 1)
      setState(() {
        print('_AudioAppState.play... PlayerState.playing');
        playerState = PlayerState.playing;
        //selected = Colors.blue;
      });
  }



  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
   // this.selected = false;
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  Future mute(bool muted) async {
    final result = await audioPlayer.setVolume(6.0);
    if (result == 1)
      setState(() {
        isMuted = muted;
      });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new ListTileTheme(
        child: new Scaffold(
          appBar: new AppBar(

            title: const Text('Cholekettu'),
          ),
          body: new ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
            new EntryItem(data[index]),
            itemCount: data.length,
          ),

          bottomNavigationBar: new BottomAppBar(
            elevation: 4.0,
              child: new SizedBox(
              height: 60.0,//mainAxisAlignment: MainAxisAlignment.center,
              child: new Row(
                children: <Widget>[

                  new IconButton(
                      onPressed: isPlaying ? null : () => calling('jathi 1'),
                      iconSize: 45.0,
                      icon: new Icon(Icons.play_arrow),
                      color: Colors.cyan),
                  new IconButton(
                      onPressed: isPlaying ? () => pause() : null,
                      iconSize: 45.0,
                      icon: new Icon(Icons.pause),
                      color: Colors.cyan),
                  new IconButton(
                      onPressed: isPlaying || isPaused ? () => stop() : null,
                      iconSize: 45.0,
                      icon: new Icon(Icons.stop),
                      color: Colors.cyan),

                ],
              )
          ))
      ),
      ) );
  }
}
class EntryItem extends StatelessWidget {

  const EntryItem(this.entry);
  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty)
      return root.titles;
    return new ExpansionTile(
      key: new PageStorageKey<Entry>(root),
      title: root.titles,

      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class Entry {
  Entry(this.titles, [this.children = const <Entry>[]]);
  final ListTile titles;
  final List<Entry> children;
}

final List<Entry> data = <Entry>[

  new Entry(
    new ListTile(title: const Text('1st half steps')),
    <Entry>[
      new Entry(
        new ListTile(title: const Text('Step 1'),
          onTap:(){
          isPlaying ? null : _AudioAppState().calling('jathi 1');
          },
          )),
      new Entry(
        new ListTile(title: const Text('Step 2'),
            onTap:(){
              _AudioAppState().calling('jathi 2');

            },)),
      new Entry(
        new ListTile(title: const Text('Step 3'))),
      new Entry(
          new ListTile(title: const Text('Step 4'))),
      new Entry(
          new ListTile(title: const Text('Step 5'))),
      new Entry(
          new ListTile(title: const Text('Step 6'))),
      new Entry(
          new ListTile(title: const Text('Step 7'))),
      new Entry(
          new ListTile(title: const Text('Step 8'))),
      new Entry(
          new ListTile(title: const Text('Step 9'))),
      new Entry(
          new ListTile(title: const Text('Step 10'))),
      new Entry(
          new ListTile(title: const Text('Step 11'))),
      new Entry(
          new ListTile(title: const Text('Step 12'))),
      new Entry(
          new ListTile(title: const Text('Step 13'))),
      new Entry(
          new ListTile(title: const Text('Step 14'))),
      new Entry(
          new ListTile(title: const Text('Step 15'))),
      new Entry(
          new ListTile(title: const Text('Step 16'))),
      new Entry(
          new ListTile(title: const Text('Step 17'))),
      new Entry(
          new ListTile(title: const Text('Step 18'))),
      new Entry(
          new ListTile(title: const Text('Step 19')))
    ],
  ),
  new Entry(
    new ListTile(title: const Text('2nd half steps')),
    <Entry>[
      new Entry(
          new ListTile(title: const Text('Group 1')),
        <Entry>[
          new Entry(
            new ListTile(title: const Text('Step 1'))),
          new Entry(
            new ListTile(title: const Text('Step 2'))),
          new Entry(
            new ListTile(title: const Text('Step 3'))),
          new Entry(
            new ListTile(title: const Text('Step 4'))),
        ],
      ),
      new Entry(
          new ListTile(title: const Text('Group 2')),
        <Entry>[
          new Entry(
            new ListTile(title: const Text('Step 1'))),
          new Entry(
            new ListTile(title: const Text('Step 2'))),
          new Entry(
            new ListTile(title: const Text('Step 3'))),
          new Entry(
            new ListTile(title: const Text('Step 4'))),
          new Entry(
            new ListTile(title: const Text('Step 5'))),
          new Entry(
            new ListTile(title: const Text('Step 6'))),
          new Entry(
            new ListTile(title: const Text('Step 7'))),
          new Entry(
            new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(
          new ListTile(title: const Text('Group 3')),
        <Entry>[
          new Entry(
            new ListTile(title: const Text('Step 1'))),
          new Entry(
            new ListTile(title: const Text('Step 2'))),
          new Entry(
            new ListTile(title: const Text('Step 3'))),
          new Entry(
            new ListTile(title: const Text('Step 4'))),
          new Entry(
            new ListTile(title: const Text('Step 5'))),
          new Entry(
            new ListTile(title: const Text('Step 6'))),
          new Entry(
            new ListTile(title: const Text('Step 7'))),
          new Entry(
            new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(
          new ListTile(title: const Text('Group 4')),
        <Entry>[
          new Entry(
            new ListTile(title: const Text('Step 1'))),
          new Entry(
            new ListTile(title: const Text('Step 2'))),
          new Entry(
            new ListTile(title: const Text('Step 3'))),
          new Entry(
            new ListTile(title: const Text('Step 4'))),
          new Entry(
            new ListTile(title: const Text('Step 5'))),
          new Entry(
            new ListTile(title: const Text('Step 6'))),
          new Entry(
            new ListTile(title: const Text('Step 7'))),
          new Entry(
            new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(
          new ListTile(title: const Text('Group 5')),
        <Entry>[
          new Entry(
              new ListTile(title: const Text('Step 1'))),
          new Entry(
              new ListTile(title: const Text('Step 2'))),
          new Entry(
              new ListTile(title: const Text('Step 3'))),
          new Entry(
              new ListTile(title: const Text('Step 4'))),
          new Entry(
              new ListTile(title: const Text('Step 5'))),
          new Entry(
              new ListTile(title: const Text('Step 6'))),
          new Entry(
              new ListTile(title: const Text('Step 7'))),
          new Entry(
              new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(new ListTile(title: const Text('Group 6')),
        <Entry>[
          new Entry(
              new ListTile(title: const Text('Step 1'))),
          new Entry(
              new ListTile(title: const Text('Step 2'))),
          new Entry(
              new ListTile(title: const Text('Step 3'))),
          new Entry(
              new ListTile(title: const Text('Step 4'))),
          new Entry(
              new ListTile(title: const Text('Step 5'))),
          new Entry(
              new ListTile(title: const Text('Step 6'))),
          new Entry(
              new ListTile(title: const Text('Step 7'))),
          new Entry(
              new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(new ListTile(title: const Text('Group 7')),
        <Entry>[
          new Entry(
              new ListTile(title: const Text('Step 1'))),
          new Entry(
              new ListTile(title: const Text('Step 2'))),
          new Entry(
              new ListTile(title: const Text('Step 3'))),
          new Entry(
              new ListTile(title: const Text('Step 4'))),
          new Entry(
              new ListTile(title: const Text('Step 5'))),
          new Entry(
              new ListTile(title: const Text('Step 6'))),
          new Entry(
              new ListTile(title: const Text('Step 7'))),
          new Entry(
              new ListTile(title: const Text('Step 8'))),
        ],
      ),
      new Entry(new ListTile(title: const Text('Group 8')),
        <Entry>[
          new Entry(
              new ListTile(title: const Text('Step 1'))),
          new Entry(
              new ListTile(title: const Text('Step 2'))),
          new Entry(
              new ListTile(title: const Text('Step 3'))),
          new Entry(
              new ListTile(title: const Text('Step 4'))),
          new Entry(
              new ListTile(title: const Text('Step 5'))),
          new Entry(
              new ListTile(title: const Text('Step 6'))),
          new Entry(
              new ListTile(title: const Text('Step 7'))),
          new Entry(
              new ListTile(title: const Text('Step 8'))),
        ],
      ),
    ],
  ),
  new Entry(new ListTile(title: const Text('Chathushram Jathi')),
    <Entry>[
      new Entry(
        new ListTile(title: const Text('Jathi 1'),
         //selected: _AudioAppState().selected,
         onTap:(){

           _AudioAppState().calling('jathi 1');
          // _AudioAppState().playNext('jathi 2');
            },
        )),
      new Entry(
        new ListTile(title: const Text('Jathi 2'),
          onTap:(){

            _AudioAppState().calling('jathi 2');
            },)),
      new Entry(
          new ListTile(title: const Text('Jathi 3'),
            onTap:(){
              _AudioAppState().calling('jathi 3');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 4'),
          onTap:(){
            _AudioAppState().calling('jathi 4');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 5'),
          onTap:(){
            _AudioAppState().calling('jathi 5');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 6'),
          onTap:(){
            _AudioAppState().calling('jathi 6');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 7'),
          onTap:(){
            _AudioAppState().calling('jathi 7');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 8'),
          onTap:(){
            _AudioAppState().calling('jathi 8');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 9'),
          onTap:(){
            _AudioAppState().calling('jathi 9');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 10'),
          onTap:(){
            _AudioAppState().calling('jathi 10');},)),
      new Entry(
        new ListTile(title: const Text('Jathi 11'),
          onTap:(){
            _AudioAppState().calling('jathi 11');},)),
    ],
  ),
  new Entry(new ListTile(title: const Text('Tisram Jathi')),
    <Entry>[
      new Entry(
          new ListTile(title: const Text('Tisram Steps'),
            onTap:(){
              _AudioAppState().calling('tisram steps');},)),
      new Entry(
          new ListTile(title: const Text('Tisram Jathi 1'),
            onTap:(){
              _AudioAppState().calling('tisram 1');},)),
      new Entry(
          new ListTile(title: const Text('Tisram Jathi 2'),
            onTap:(){
              _AudioAppState().calling('tisram 2');},)),
      new Entry(
          new ListTile(title: const Text('Tisram Jathi 3'),
            onTap:(){
              _AudioAppState().calling('tisram 3');},)),
      new Entry(
          new ListTile(title: const Text('Tisram Jathi 4'),
            onTap:(){
              _AudioAppState().calling('tisram 4');},)),
      new Entry(
          new ListTile(title: const Text('Tisram Jathi 5'),
            onTap:(){
              _AudioAppState().calling('tisram 5');},)),
    ],
  ),
  new Entry(new ListTile(title: const Text('Misram Jathi')),
    <Entry>[
      new Entry(
          new ListTile(title: const Text('Misram Steps'),
            onTap:(){
              _AudioAppState().calling('misram steps');},)),
      new Entry(
          new ListTile(title: const Text('Misram Jathi 1'),
            onTap:(){
              _AudioAppState().calling('misram 1');},)),
      new Entry(
          new ListTile(title: const Text('Misram Jathi 2'),
            onTap:(){
              _AudioAppState().calling('misram 2');},)),
      new Entry(
          new ListTile(title: const Text('Misram Jathi 3'),
            onTap:(){
              _AudioAppState().calling('misram 3');},)),

    ],
  ),
  new Entry(new ListTile(title: const Text('Khandam Jathi')),
    <Entry>[
      new Entry(
          new ListTile(title: const Text('Khandam Steps'),
            onTap:(){
              _AudioAppState().calling('khandam steps');
              },)),
      new Entry(
          new ListTile(title: const Text('Khandam Jathi 1'),
            onTap:(){
              _AudioAppState().calling('khandam 1');
              },
            )),
      new Entry(
          new ListTile(title: const Text('Khandam Jathi 2'),
            onTap:(){
              _AudioAppState().calling('khandam 2');
              },
            )),

    ],
  ),
];

