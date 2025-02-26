import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtc_rawdata/agora_rtc_rawdata.dart';
import 'package:faceunity_ui/Faceunity_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = 'b646785207b84110be190b025b1f4b3c';
const token = null;
const channelId = '2021';
const uid = 0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RtcEngine engine;
  bool startPreview = false, isJoined = false;
  List<int> remoteUid = [];
  @override
  void initState() {
    super.initState();
    this._initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    this._deinitEngine();
  }

  _initEngine() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        logConfig: LogConfig(level: LogLevel.logLevelNone)));

    engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      log('onJoinChannelSuccess connection: ${connection.toJson()} elapsed: $elapsed');
      setState(() {
        isJoined = true;
      });
    }, onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
      log('onUserJoined connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
      setState(() {
        remoteUid.add(rUid);
      });
    }, onUserOffline:
            (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
      log('onUserOffline connection: ${connection.toJson()} remoteUid: $rUid reason: $reason');
      setState(() {
        remoteUid.remove(rUid);
      });
    }));
    await engine.enableVideo();
    await engine.startPreview();
    setState(() {
      startPreview = true;
    });
    var handle = await engine.getNativeHandle();
    // await AgoraRtcRawdata.registerAudioFrameObserver(handle);
    await AgoraRtcRawdata.registerVideoFrameObserver(handle);

    await engine.joinChannel(
        token: '',
        channelId: channelId,
        uid: uid,
        options: ChannelMediaOptions());
  }

  _deinitEngine() async {
    // await AgoraRtcRawdata.unregisterAudioFrameObserver();
    await AgoraRtcRawdata.unregisterVideoFrameObserver();
    await engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            if (startPreview)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: 0),
                ),
              ),
            Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.of(remoteUid.map(
                    (e) => Container(
                      width: 120,
                      height: 120,
                      child: AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: engine,
                          canvas: VideoCanvas(uid: e),
                          connection: RtcConnection(
                            channelId: channelId,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            //传camera 回调显示 UI，不传不显示
            FaceunityUI(
              cameraCallback: () => engine.switchCamera(),
            )
          ],
        ),
      ),
    );
  }
}
