import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// ------------------- Agora Config -------------------
const String agoraAppId = "739a61014ae64d2eaf7dd9eb4872664e"; // Replace with your Agora App ID
const String agoraToken = ""; // If you are using token-based auth
const String defaultChannel = "bigfun_voice";

// ------------------- Main Entry -------------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BigFun App",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

// ------------------- Home Screen -------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BigFun App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                );
              },
              child: const Text("Join Voice Chat"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(
                      userName: "Guest User",
                      diamonds: 100,
                    ),
                  ),
                );
              },
              child: const Text("Profile & Wallet"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                );
              },
              child: const Text("Inbox"),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Voice Chat Screen -------------------
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
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: agoraAppId));

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
      appBar: AppBar(title: const Text("Voice Chat Room")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_joined ? "You have joined the channel" : "Joining..."),
            const SizedBox(height: 20),
            Text(_remoteUid != null
                ? "User $_remoteUid joined"
                : "Waiting for users..."),
          ],
        ),
      ),
    );
  }
}

// ------------------- Profile Screen -------------------
class ProfileScreen extends StatelessWidget {
  final String userName;
  final int diamonds;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.diamonds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/avatar.png"),
            ),
            const SizedBox(height: 20),
            Text(userName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Diamonds: $diamonds",
                style: const TextStyle(fontSize: 18, color: Colors.blueAccent)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Top Up Diamonds"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Send Gift"),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Inbox Screen -------------------
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      "Welcome to BigFun!",
      "You received 20 diamonds.",
      "Friend invited you to join a voice chat."
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Inbox")),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.message, color: Colors.deepPurple),
            title: Text(messages[index]),
          );
        },
      ),
    );
  }
}
