import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Create a 1024x1024 image
  final image = img.Image(width: 1024, height: 1024);

  // Fill with gradient (or solid blue for simplicity, matching the gradient average)
  // Let's draw a linear gradient from top to bottom
  final topColor = img.ColorRgba8(74, 144, 226, 255);
  final bottomColor = img.ColorRgba8(10, 87, 214, 255);

  for (int y = 0; y < 1024; y++) {
    final t = y / 1023.0;
    final r = (topColor.r * (1 - t) + bottomColor.r * t).toInt();
    final g = (topColor.g * (1 - t) + bottomColor.g * t).toInt();
    final b = (topColor.b * (1 - t) + bottomColor.b * t).toInt();
    final a = 255;

    for (int x = 0; x < 1024; x++) {
      image.setPixelRgba(x, y, r, g, b, a);
    }
  }

  // Load the foreground image
  final fgFile = File('assets/icon.png');
  final fgImage = img.decodePng(fgFile.readAsBytesSync())!;

  // Resize foreground slightly if needed, or just composite it centered
  // Let's assume it's already 1024x1024. If not, we scale it.
  final scaledFg = img.copyResize(
    fgImage,
    width: 800,
    height: 800,
    interpolation: img.Interpolation.linear,
  );

  // Draw the foreground centered
  img.compositeImage(
    image,
    scaledFg,
    dstX: (1024 - 800) ~/ 2,
    dstY: (1024 - 800) ~/ 2,
  );

  // Save the result
  final outFile = File('assets/icon_composite.png');
  outFile.writeAsBytesSync(img.encodePng(image));
  print('Composited icon saved to assets/icon_composite.png');
}
