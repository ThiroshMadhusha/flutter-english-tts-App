import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped }

class _MyAppState extends State<MyApp> {
  late FlutterTts _flutterTts;
  String? _tts;
  TtsState _ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        print("Error: $message");
        _ttsState = TtsState.stopped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Flutter TTS')),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [input(), button()]),
            )));
  }

  // *******************************************************

  // Add toggle button to input widget
  void toggleButtonPressed() {
    setState(() {
      if (_ttsState == TtsState.playing) {
        stop();
      } else {
        speak();
      }
    });
  }

  // input TTS text field
  Widget input() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(25.0),
      child: Stack(
        alignment:
            Alignment.topRight, // Align toggle button to top-right corner
        children: [
          TextField(
            onChanged: (String value) {
              setState(() {
                _tts = value;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Capture The Page Text',
            ),
            maxLines: null, // Allows for multiline input
          ),
          Padding(
            padding: const EdgeInsets.all(
                8.0), // Add padding around the toggle button
            child: ElevatedButton(
              onPressed: toggleButtonPressed,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8.0),
                primary: Colors.grey[300],
              ),
              child: Icon(
                _ttsState == TtsState.playing
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget input() {
  //   return Container(
  //     alignment: Alignment.topCenter,
  //     padding: const EdgeInsets.all(25.0),
  //     child: TextField(
  //       onChanged: (String value) {
  //         setState(() {
  //           _tts = value;
  //         });
  //       },
  //       decoration: const InputDecoration(
  //         border: OutlineInputBorder(),
  //         labelText: 'Capture The Page Text',
  //       ),
  //       maxLines: null, // Allows for multiline input
  //     ),
  //   );
  // }

  // Widget input() => Container(
  //       alignment: Alignment.topCenter,
  //       padding: const EdgeInsets.all(25.0),
  //       child: TextField(
  //         onChanged: (String value) {
  //           setState(() {
  //             _tts = value;
  //           });
  //         },
  //       ),
  //     );

  // *******************************************************

  // play and stop button

  Widget button() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: _ttsState == TtsState.stopped ? speak : stop,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _ttsState == TtsState.stopped ? 'Play' : 'Stop',
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }

  // Widget button() {
  //   if (_ttsState == TtsState.stopped) {
  //     return TextButton(onPressed: speak, child: const Text('Play'));
  //   } else {
  //     return TextButton(onPressed: stop, child: const Text('Stop'));
  //   }
  // }

  // speak function
  Future speak() async {
    await _flutterTts.setVolume(3);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(4);

    if (_tts != null) {
      if (_tts!.isNotEmpty) {
        await _flutterTts.speak(_tts!);
      }
    }
  }

  // stop function
  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    }
  }
}
