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
  final _recorder = FlutterSoundRecorder();

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
    _recorder.closeRecorder();
    super.dispose();
  }

  Future record() async{
    if (!isRecorderReady) return;

    await _recorder.startRecorder(toFile: 'audio');

    
  }

  Future stop() async{
    if (!isRecorderReady) return;

    final path = await _recorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: $audioFile');
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
            StreamBuilder<RecordingDisposition>(
              stream: _recorder.onProgress, 
              builder: (context, snapshot) {
                final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;

                String twoDigits (int n) => n.toString().padLeft(2,'0');
                final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

                return Text('$twoDigitMinutes:$twoDigitSeconds', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),);
              }),
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
          ],
        )
      ),
    );
  }
}
