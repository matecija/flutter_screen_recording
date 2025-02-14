import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:quiver/async.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget  {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool recording = false;
  int _time = 0;

  requestPermissions() async {
    await PermissionHandler().requestPermissions([
      PermissionGroup.storage,
      PermissionGroup.photos,
      PermissionGroup.microphone,
    ]);
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startTimer();
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: 1000),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() => _time++);
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Screen Recording'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Time: $_time\n'),

            !recording
                ? Center(
                    child: RaisedButton(
                      child: Text("Record Screen"),
                      onPressed: () {
                        setState(() {
                          recording = !recording;
                          print("Recording stopped at $_time");
                        });
                        startScreenRecord(false);
                      },
                    ),
                  )
                : Container(),
            !recording
                ? Center(
                    child: RaisedButton(
                      child: Text("Record Screen & audio"),
                      onPressed:() {
                        setState(() {
                          recording = !recording;
                          print("Recording stopped at $_time");
                        });
                        startScreenRecord(true , pathName: "/storage/emulated/0/Download");
                      } ,
                    ),
                  )
                : Center(
                    child: RaisedButton(
                      child: Text("Stop Record"),
                      onPressed: () {
                        setState(() {
                          recording = !recording;
                          print("Recording stopped at $_time");
                        });
                        stopScreenRecord();
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  startScreenRecord(bool audio ,{String pathName}) async {
    bool start = false;
    await Future.delayed(const Duration(milliseconds: 1000));

    if (audio) {
      int width, height;
      start = await FlutterScreenRecording.startRecordScreenAndAudio(
          "Title" + _time.toString(),
          path: pathName,
          width: width, height: height,
          titleNotification: "dsffad",
          messageNotification: "sdffd");
    } else {
      int width, height;

      // // Record screen at quarter size, ie file size reduced by x16
      // Size win = window.physicalSize / 4; // Reduce size
      // width = win.width ~/ 10 * 10; // Round to multiple of 10
      // height = win.height ~/ 10 * 10;
      start = await FlutterScreenRecording.startRecordScreen(
        "Title" + _time.toString(),
          path: pathName,
          width: width, height: height,
          titleNotification: "dsffad", messageNotification: "sdffd",
      );
    }

   /* if (start) {
      setState(() => recording = !recording);
      print("Recording started at $_time");
    }*/

    return start;
  }

  stopScreenRecord() async {
    String path = await FlutterScreenRecording.stopRecordScreen;

    File videoFile = File(path);
    int fileSizeBytes = await videoFile.length();
    print('Video file size $fileSizeBytes bytes');

    print("Opening video");
    print(path);
    OpenFile.open(path);
  }
/* Screen Capture
  startScreenCapture() async {
    String path = await FlutterScreenRecording.startScreenCapture(name, path);

    File captureFile = File(path);
    int fileSizeBytes = await captureFile.length();
    print('Video file size $fileSizeBytes bytes');

    print("Saved image at : $path");
    OpenFile.open(path);
  }*/
}
