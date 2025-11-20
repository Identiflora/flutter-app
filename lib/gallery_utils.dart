import 'package:flutter/material.dart';
import 'package:identiflora/camera_utils.dart';
import 'package:image_picker/image_picker.dart';

// Stable caller for the state of photo gallery
class GalleryWidget extends StatefulWidget {
  const GalleryWidget({super.key});

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState(); 
}

// Photo gallery widget logic
class _GalleryWidgetState extends State<GalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () async {
              // Get image
              final ImagePicker picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);

              // Pass image to display picture screen
              if(image != null && context.mounted) {
                Navigator.push(
                  context, 
                  MaterialPageRoute<void>(
                    builder: (context) => DisplayPictureScreen(imgPath: image.path)
                  )
                );
              }
            },
            child: Image.asset('assets/homepage/photo_gallery_icon.png', width: 80, height: 80)
          ),
        ),
      )
    );
  }
}