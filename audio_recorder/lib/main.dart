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
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordDurationSeconds = 0;
  List<File> _recordedFiles = [];

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission is not granted';
    }
  }

  Future<void> _startRecording() async {
    try {
      await _recorder.openRecorder();

      _recorder.onProgress!.listen((RecordingDisposition event) {
        setState(() {
          _recordDurationSeconds = event.duration.inSeconds;
        });
      });

      if (_recorder.isStopped) {
        final filePath = '/Users/waynewong/Desktop/recording.aac';

        await _recorder.startRecorder(
          toFile: filePath,
          codec: Codec.aacMP4,
        );
        setState(() {
          _isRecording = true;
        });
      } else {
        print('Failed to open recorder');
      }
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordDurationSeconds = 0; // Reset recording duration
      });
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  void _playRecording(String filePath) async {
    try {
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.aacMP4,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Failed to play recording: $e');
    }
  }

  void _stopPlayback() async {
    try {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
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
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              'Audio',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            Text(
              'Recording Duration: $_recordDurationSeconds seconds',
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _recordedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Recording ${index + 1}'),
                    onTap: () {
                      _playRecording(_recordedFiles[index].path);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
            child: Icon(_isRecording ? Icons.stop : Icons.mic),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _isPlaying ? _stopPlayback : null,
            tooltip: _isPlaying ? 'Stop Playback' : 'Play Recording',
            child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
