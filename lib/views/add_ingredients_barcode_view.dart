import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class AddIngredientsView extends StatefulWidget {
  @override
  _AddIngredientsViewState createState() => _AddIngredientsViewState();
}

class _AddIngredientsViewState extends State<AddIngredientsView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  late BarcodeScanner _barcodeScanner;
  bool _isInitialized = false;
  bool _isDetecting = false;
  String? _scannedValue;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner(formats: [
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8
    ]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420
      );
      await _controller!.initialize();

      _controller!.startImageStream(_processCameraImage);

      setState(() {
        _isInitialized = true;
      });
    }
  }

  Uint8List convertYUV420toNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;

    final Uint8List nv21Image = Uint8List(ySize + uvSize);

    // Copy Y plane
    int index = 0;
    for (int row = 0; row < height; row++) {
      nv21Image.setRange(
        index,
        index + width,
        image.planes[0].bytes,
        row * image.planes[0].bytesPerRow,
      );
      index += width;
    }

    // Interleave VU for NV21
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final int uvIndex = row * uvRowStride + col * uvPixelStride;
        nv21Image[index++] = vPlane[uvIndex]; // V
        nv21Image[index++] = uPlane[uvIndex]; // U
      }
    }

    return nv21Image;
  }


  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      // Convert to NV21
      Uint8List nv21Bytes = convertYUV420toNV21(image);

      final inputImage = InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg, // Or detect it from sensor
          format: InputImageFormat.nv21, // This is key!
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        final box = barcode.boundingBox;
        if (box != null) {
          final imageSize = Size(image.width.toDouble(), image.height.toDouble());
          final centerRect = Rect.fromCenter(
            center: Offset(imageSize.width / 2, imageSize.height / 2),
            width: 200,
            height: 200,
          );

          if (_scannedValue == null && centerRect.overlaps(box)) {
            setState(() {
              _scannedValue = barcode.rawValue;
            });
            await _controller?.stopImageStream();
            break;
          }
        }
      }

      if (_scannedValue == null) {
        debugPrint("No barcode has been scanned yet.");
      } else {
        debugPrint("Scanned Value: $_scannedValue");
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint("Barcode detection error: $e");
    }

    _isDetecting = false;
  }



  @override
  void dispose() {
    _controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isInitialized && _controller != null
              ? SizedBox.expand(child: CameraPreview(_controller!))
              : const Center(child: CircularProgressIndicator()),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Focus circles
          Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 6),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ],
            ),
          ),

          // Instruction text
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Text(
                  "Point your camera at the bar code to scan",
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Display scanned barcode
          if (_scannedValue != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 80),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Scanned: $_scannedValue",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
