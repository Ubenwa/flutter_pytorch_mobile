import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pytorch_mobile_v2/pytorch_mobile_v2.dart';
import 'package:pytorch_mobile_v2/model.dart';
import 'package:pytorch_mobile_v2/enums/dtype.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Model? _imageModel, _customModel;

  String? _imagePrediction;
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  //load your model
  Future loadModel() async {
    String pathImageModel = "assets/models/resnet-lite.ptl";
    String pathCustomModel = "assets/models/custom_model-lite.ptl";
    try {
      _imageModel = await PyTorchMobile.loadModel(pathImageModel);
      _customModel = await PyTorchMobile.loadModel(pathCustomModel);
    } on PlatformException {
      throw Exception("Only supported for android and ios so far");
    }
  }

  //run an image model
  Future runImageModel() async {
    //pick a random image
    final PickedFile? image = await _picker.getImage(
        source: (Platform.isIOS ? ImageSource.gallery : ImageSource.camera),
        maxHeight: 224,
        maxWidth: 224);
    //get prediction
    //labels are 1000 random english words for show purposes
    _imagePrediction = await _imageModel!.getImagePrediction(
        File(image!.path), 224, 224, "assets/labels/labels.csv");

    setState(() {
      _image = File(image.path);
    });
  }

  //run a custom model with number inputs
  Future runCustomModel() async {
    _prediction = await _customModel!
        .getPrediction([1, 2, 3, 4], [1, 2, 2], DType.float32);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch Mobile Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            Center(
              child: Visibility(
                visible: _imagePrediction != null,
                child: Text("$_imagePrediction"),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: runImageModel,
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: runCustomModel,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run custom model",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: _prediction != null,
                child: Text(_prediction != null ? "${_prediction![0]}" : ""),
              ),
            )
          ],
        ),
      ),
    );
  }
}
