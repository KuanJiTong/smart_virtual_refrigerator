import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';
import 'add_ingredients_view.dart';
import 'home_page.dart';

class AddIngredientsBarcodeView extends StatefulWidget {
  @override
  _AddIngredientsBarcodeViewState createState() => _AddIngredientsBarcodeViewState();
}

class _AddIngredientsBarcodeViewState extends State<AddIngredientsBarcodeView> with RouteAware {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  // Called when coming back to this screen
  @override
  void didPopNext() {
    _resumeScanning();
  }

  void _resumeScanning() async {
    setState(() {
      _scannedValue = null;
    });

    try {
      await _controller?.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint("Error restarting image stream: $e");
    }
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
            final product = await fetchProductByBarcode(_scannedValue!);

            if (product != null) {
              await _controller?.stopImageStream();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddIngredientsView(
                    initialName: product['title'],
                    imageUrl: product['image'],
                  ),
                ),
              );

            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid barcode UPC code'),
                  duration: Duration(seconds: 3),
                ),
              );
              _scannedValue = null;
            }

            break;
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint("Barcode detection error: $e");
    }

    _isDetecting = false;
  }



  Future<Map<String, String>?> fetchProductByBarcode(String barcode) async {
    final apiKey = dotenv.env['BARCODE_LOOKUP_API_KEY'];
    final url = Uri.parse('https://api.barcodelookup.com/v3/products?barcode=$barcode&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['products'] != null && jsonData['products'].isNotEmpty) {
        final product = jsonData['products'][0];
        return {
          'title': product['title'] ?? '',
          'image': (product['images'] as List).isNotEmpty ? product['images'][0] : '',
        };
      }
    } else {
      print('Failed to fetch product: ${response.statusCode}');
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller != null && _controller!.value.isInitialized && !_controller!.value.isTakingPicture
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
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2))),
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
