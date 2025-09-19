// 📌 File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// Agora Configuration (replace with your actual App ID and Token if needed)
const String agoraAppId = "739a61014ae64d2eaf7dd9eb4872664e";
const String agoraToken = ""; // Add your token here if required, otherwise keep empty
const String defaultChannel = "bigfun_voice_room";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceChatScreen(),
    );
  }
}

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  int? _remoteUid;
  late RtcEngine _engine;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Request microphone permission
    await [Permission.microphone].request();

    // Create Agora Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _joined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Enable audio and join channel
    await _engine.enableAudio();
    await _engine.joinChannel(
      token: agoraToken,
      channelId: defaultChannel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Chat Room"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: _joined
            ? Text(
                _remoteUid != null
                    ? "Connected with user $_remoteUid"
                    : "Waiting for users to join...",
                style: const TextStyle(fontSize: 18),
              )
            : const Text(
                "Joining channel...",
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
