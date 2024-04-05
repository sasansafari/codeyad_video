import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

int _selectedVideoIndex = 0;

List<String> _src = [
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_src[_selectedVideoIndex]));

    _controller.initialize().then((value) {
      setState(() {});
    });

    _controller.play();
  }

  final iconColor = Colors.white;
  bool isControllersVisible = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => isControllersVisible
              ? isControllersVisible = false
              : isControllersVisible = true),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                  child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )),
              if (isControllersVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //rewwind
                        IconButton(
                            onPressed: () async {
                              final pos = await _controller.position;
                              final targetPos = pos!.inMilliseconds - 10000;
                              await _controller
                                  .seekTo(Duration(milliseconds: targetPos));
                            },
                            icon: Icon(
                              Icons.fast_rewind_rounded,
                              color: iconColor,
                            )),
                        //previus
                        IconButton(
                            onPressed: () {
                              _selectedVideoIndex--;
                              _selectedVideoIndex %= _src.length;
                              onChaneVideo();
                            },
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: iconColor,
                            )),

                        //play or pause
                        IconButton(
                            onPressed: () async {
                              _controller.value.isPlaying
                                  ? await _controller.pause()
                                  : await _controller.play();

                              setState(() {});
                            },
                            icon: Icon(
                                color: iconColor,
                                size: 45,
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded)),

                        //next
                        IconButton(
                            onPressed: () {
                              _selectedVideoIndex++;
                              _selectedVideoIndex %= _src.length;
                              onChaneVideo();
                            },
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: iconColor,
                            )),
                        //forward
                        IconButton(
                            onPressed: () async {
                              final pos = await _controller.position;
                              final targetPos = pos!.inMilliseconds + 10000;
                              await _controller
                                  .seekTo(Duration(milliseconds: targetPos));
                            },
                            icon: Icon(
                              Icons.fast_forward_rounded,
                              color: iconColor,
                            ))
                      ],
                    ),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          backgroundColor: Colors.grey),
                    )
                  ]),
                )
            ],
          ),
        ),
      ),
    ));
  }

  onChaneVideo() {
    _controller.dispose();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_src[_selectedVideoIndex]));
    _controller.addListener(() {
      setState(() {
        if (!_controller.value.isPlaying &&
            _controller.value.isInitialized &&
            (_controller.value.duration == _controller.value.position)) {
          _controller.seekTo(Duration.zero);
        }
      });
    });
    _controller.initialize().then((value) => setState(
          () {
            _controller.play();
          },
        ));
  }
}
