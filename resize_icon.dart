import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File(r'ios\Runner\Assets.xcassets\AppIcon.appiconset\1024.png').readAsBytesSync();
  final image = img.decodeImage(bytes)!;
  final resized = img.copyResize(image, width: 512, height: 512, interpolation: img.Interpolation.cubic);
  File('app-icon-512.png').writeAsBytesSync(img.encodePng(resized));
  print('Created app-icon-512.png (512x512)');
}
