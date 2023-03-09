import 'dart:io';
import 'package:ai_note_taking/src/features/transcription/data/service/transcription_request.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

//TODO: Add tests

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  _TranscriptionScreenState createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  //region Variables
  final audioPlayer = AudioPlayer();
  late String _selectedFileName = 'No file selected';
  late File _selectedFile;

  String _text = 'Transcription incoming...';
  bool isLoading = false;
  bool isFilePlaying = false;
  //endregion

  //region Override Methods
  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedFile = File('');
    });
  }
  //endregion

  //TODO: Add picker menu for format-supported files
  //TODO: Fix unsupported file formats
  //region File Transcription
  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        //type: FileType.custom,
        //allowedExtensions: ['mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'],
        );
    if (result != null) {
      File file = File(result.files.single.path!);
      audioPlayer.setSourceUrl(file.path);

      if (audioPlayer.source != null) {
        displaySelectedFile(
            file.path.substring(file.path.lastIndexOf('/') + 1));
        setState(() {
          _selectedFile = file;
        });
      }
    } else {
      setState(() {
        _selectedFileName = 'No file selected';
      });
    }
  }

  void transcriptionFromLocalFile() {}

  //TODO: Add transcription checks (file format, file size)
  ///Displays file transcription
  void transcriptionConfirmation() {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Transcribe"),
      onPressed: () {
        setState(() {
          isLoading = true;
        });
        displayTranscription(_selectedFile.path);
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Transcription"),
      content:
          Text("Would you like to transcribe this file? ($_selectedFileName)"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void displayTranscription(String filePath) async {
    TranscriptionRequest transcriptionModel =
        TranscriptionRequest(requestFilePath: filePath);

    var result = await transcriptionModel.getTranscription(filePath);

    setState(() {
      _text = result.text;
      isLoading = false;
      _selectedFileName = 'No file selected';
    });
  }

  void displaySelectedFile(fileName) {
    setState(() {
      _selectedFileName = fileName;
    });
  }

  //endregion

  //region Audio Player
  /// Play selected file from local storage
  void playFile(source) {
    audioPlayer.play(source);
    Fluttertoast.showToast(
        msg: "File is playing",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      isFilePlaying = true;
    });
  }

  /// Pause selected file
  void stopFile() {
    audioPlayer.stop();
    Fluttertoast.showToast(
        msg: "File stopped playing",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      isFilePlaying = false;
    });
  }
  //endregion

  //TODO: Split screen into components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: SingleChildScrollView(
                child: Text(
                  _text,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isLoading ? true : false,
            child: const LinearProgressIndicator(
              minHeight: 5,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () async {
                    pickFile();
                  },
                  icon: const Icon(Icons.folder),
                  label: const Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedFile != null) {
                      transcriptionConfirmation();
                    } else {
                      null;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10.0),
                    backgroundColor:
                        _selectedFile.path.isEmpty ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.transcribe_rounded),
                ),
                Text(_selectedFileName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
