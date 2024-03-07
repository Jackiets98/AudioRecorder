import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecorderReady = false;
  bool isPlaying = false;
  final _recorder = FlutterSoundRecorder();
  late String _recordFilePath;
  final _player = FlutterSoundPlayer();
  Timer? _timer;
  int _elapsedSeconds = 0;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initRecorder();
  }

  Future initRecorder() async{
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Micrphone Permission Is Not Granted';
    }

    await _recorder.openRecorder();
    isRecorderReady = true;
    _recorder.setSubscriptionDuration(const Duration(microseconds: 500));
  }



  @override
  void dispose() {
    // TODO: implement dispose
    _player.closePlayer();
    _recorder.closeRecorder();
    _stopTimer();
    super.dispose();
  }

  Future record() async{
    if (!isRecorderReady) return;

    // Get the external storage directory
    final directory = await getExternalStorageDirectory();
    _recordFilePath = '${directory!.path}/audio.aac';

    _startTimer();

    await _recorder.startRecorder(toFile: _recordFilePath);
  }


  Future stop() async{
    if (!isRecorderReady) return;

    final path = await _recorder.stopRecorder();
    final audioFile = File(path!);

    _stopTimer();

    print('Recorded audio: $audioFile');
  }

  Future<void> play() async {
    print('Play function called');
    if (!await File(_recordFilePath).exists()) {
      print('No recorded file found');
      return;
    }

    try {
      print('Opening player');
      await _player.openPlayer().whenComplete(() {
        isPlaying = true;
      });
      await _player.startPlayer(fromURI: _recordFilePath).whenComplete(() {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      print('Failed to play recording: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.pausePlayer();
    } catch (e) {
      print('Failed to stop playback: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}'),
              SizedBox(height: 10,),
              ElevatedButton(
                child: Icon(
                  _recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 80,
                ),
                onPressed: () async{
                  if (_recorder.isRecording) {
                    await stop();
                  }else {
                    await record();
                  }

                  setState(() {

                  });
                },
              ),
              SizedBox(height: 50,),
              ElevatedButton(
                onPressed: () async {
                  if (isPlaying) {
                    await stopPlayback(); // Pause the audio playback
                  } else {
                    if (_player.isPaused) {
                      await _player.resumePlayer(); // Resume the playback
                    } else {
                      await play(); // Start playing the audio
                    }
                  }
                  setState(() {
                    // Toggle the isPlaying state
                    isPlaying = !isPlaying;
                  });
                },
                child: Icon(
                  isPlaying ? Icons.stop : Icons.play_arrow,
                  size: 80,
                ),
              ),
            ],
          )
      ),
    );
  }
}