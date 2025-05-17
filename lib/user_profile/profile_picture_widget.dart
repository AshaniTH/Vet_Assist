import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePictureWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(File?) onImageSelected;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    required this.onImageSelected,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _imageFile = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getImage(),
            child:
                _imageFile == null && widget.imageUrl == null
                    ? const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    )
                    : null,
          ),
        ),
        TextButton(
          onPressed: _pickImage,
          child: const Text(
            'Change Photo',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return NetworkImage(widget.imageUrl!);
    }
    return null;
  }
}
