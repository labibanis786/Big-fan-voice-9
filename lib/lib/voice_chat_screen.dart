import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// ✅ Agora Config এক ফাইলেই থাকবে
const String agoraAppId = "739a61014ae64d2eaf7dd9eb4872664e"; // তোমার Agora App ID
const String agoraToken = ""; // যদি টোকেন না লাগে ফাঁকা রাখো
const String defaultChannel = "bigfun_voice_chat"; // ডিফল্ট রুম নাম

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
    // Mic permission চাইবে
    await [Permission.microphone].request();

    // Agora Engine তৈরি
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));

    // Event Handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _joined = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Audio চালু করে join করবে
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
      appBar: AppBar(title: const Text("Voice Chat")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_joined ? "✅ Joined channel" : "⏳ Joining..."),
            const SizedBox(height: 20),
            if (_remoteUid != null)
              Text("🎧 User $_remoteUid joined")
            else
              const Text("No remote user yet"),
          ],
        ),
      ),
    );
  }
}

// ✅ Main Function
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
