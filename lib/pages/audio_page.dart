import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioPage extends StatefulWidget {
  final String fileName;

  const AudioPage({super.key, required this.fileName});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isAudioLoaded = false;
  bool _isFileMissing = false;

  @override
  void initState() {
    super.initState();
    loadAudioFile();
  }

  Future<void> loadAudioFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, widget.fileName);
    final file = File(filePath);

    if (await file.exists()) {
      await _audioPlayer.setFilePath(file.path);
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      setState(() {
        _isAudioLoaded = true;
      });
    } else {
      setState(() {
        _isFileMissing = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Audio Player"),
      ),
      body: Center(
        child: _isFileMissing
            ? const Text("No such file")
            : _isAudioLoaded
            ? audioPlayer()
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget audioPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProgressBar(
          progress: _position,
          total: _duration,
          onSeek: (duration) {
            _audioPlayer.seek(duration);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                if (_audioPlayer.playing) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
