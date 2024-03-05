import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer _audioPlayer;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playRecordedAudio() {
    if (_filePath != null) {
      _audioPlayer.play(UrlSource(_filePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 140, left: 4, right: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: SocialMediaRecorder(
              // maxRecordTimeInSecond: 5,
              startRecording: () {
                // function called when start recording
              },
              stopRecording: (_time) {
                // function called when stop recording, return the recording time
              },
              sendRequestFunction: (soundFile, _time) {
                setState(() {
                  _filePath = soundFile.path;
                });
              },
              encode: AudioEncoderType.AAC,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playRecordedAudio,
        tooltip: 'Play',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
