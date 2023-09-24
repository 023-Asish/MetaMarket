import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadMediaPage extends StatefulWidget {
  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  File _media= File('');
  final picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late VideoPlayerController _controller;
  Future<void> ?_initializeVideoPlayerFuture;

  Future<void> _getMediaAndUpload() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _media = File(pickedFile.path);
        _controller = VideoPlayerController.file(_media);
        _initializeVideoPlayerFuture = _controller.initialize();
      } else {
        print('No media selected.');
      }
    });

    // Upload media to Firebase Storage bucket
    final ref = _storage.ref().child('media/${DateTime.now()}.mp4');
    final task = ref.putFile(_media);

    // Get download URL of uploaded media and save it to Firestore collection
    final url = await (await task).ref.getDownloadURL();
    _firestore.collection('media').add({'url': url});
  }

  @override
  void dispose() {
    // Ensure the video player is stopped and released when the widget is disposed.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Media'),
      ),
      body: Center(
        child: _media == null
            ? Text('No media selected.')
            : FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getMediaAndUpload,
        tooltip: 'Pick Media',
        child: Icon(Icons.add),
      ),
    );
  }
}
