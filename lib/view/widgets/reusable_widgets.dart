
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food/view_model/functions.dart';


class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitWaveSpinner(
      color: Colors.blue,
    );
  }
}

class CircularPhoto extends StatefulWidget {
  const CircularPhoto({
    this.url,
    this.radius = 150,
    super.key,
  });

  final String? url;
  final double radius;

  @override
  State<CircularPhoto> createState() => _CircularPhotoState();
}

class _CircularPhotoState extends State<CircularPhoto> {

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      return const Icon(Icons.image_outlined);
    }

    return FutureBuilder(
        initialData: appImageCache[widget.url],
        future: getImageData(widget.url),
      builder: (_, snap) {

        if(snap.connectionState != ConnectionState.done) {
          return const LoadingIndicator();
        }

        if(!snap.hasData) {
          return const Text("No image data");
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(360.0), //add border radius
          child: Image.memory(
           snap.requireData!,
            height: widget.radius,
            width: widget.radius,
            fit: BoxFit.cover,
            errorBuilder: (_, e, trace) => IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        );
      }
    );
  }
}

class RectangularPhoto extends StatefulWidget {
  const RectangularPhoto({
    this.url,
    this.maxHeight = 200,
    this.maxWidth = 450,
    super.key,
  });

  final String? url;
  final double maxWidth;
  final double maxHeight;

  @override
  State<RectangularPhoto> createState() => _RectangularPhotoState();
}

class _RectangularPhotoState extends State<RectangularPhoto> {

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      return const Icon(Icons.image_outlined);
    }


    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        minWidth: 350,
        minHeight: 150,
      ),
      child: Card(
        child: FutureBuilder(
          initialData: appImageCache[widget.url],
          future: getImageData(widget.url),
          builder: (_, snap) {

            if(snap.connectionState != ConnectionState.done) {
              return const LoadingIndicator();
            }

            if(!snap.hasData) {
              return const Text("No image data");
            }

            return Image.memory(
              snap.requireData!,
              fit: BoxFit.contain,
              errorBuilder: (_, e, trace) => IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
            );
          }
        ),
      ),
    );
  }
}
