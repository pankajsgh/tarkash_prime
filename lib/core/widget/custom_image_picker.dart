import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/colors.dart';

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({super.key});

  @override
  State<CustomImagePicker> createState() =>
      _CustomImagePickerState();
}

class _CustomImagePickerState
    extends State<CustomImagePicker> {

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {

    final XFile? image =
    await picker.pickImage(
      source: source,
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 70,
    );

    if (image != null) {
      int bytes = await image.length();

      double kb = bytes / 1024;
      double mb = bytes / (1024 * 1024);

      print("this is good");
      print('Bytes: $bytes');
      print('KB: ${kb.toStringAsFixed(2)}');
      print('MB: ${mb.toStringAsFixed(2)}');
    }

    if (image != null) {

      setState(() {
        selectedImage =
            File(image.path);

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Upload Image",
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          children: [

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: Container(

                width:
                double.infinity,

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius
                      .circular(
                      25),
                ),

                child:
                selectedImage !=
                    null

                    ? ClipRRect(

                  borderRadius:
                  BorderRadius.circular(
                      25),

                  child:
                  Stack(

                    children: [

                      Image.file(

                        selectedImage!,

                        width:
                        double.infinity,

                        height:
                        double.infinity,

                        fit:
                        BoxFit.cover,

                      ),

                      Positioned(

                        top: 15,

                        right: 15,

                        child:
                        InkWell(

                          onTap:
                              () {

                            setState(
                                    () {

                                  selectedImage =
                                  null;

                                });
                          },

                          child:
                          Container(

                            padding:
                            const EdgeInsets.all(
                                8),

                            decoration:
                            const BoxDecoration(

                              color:
                              Colors.white,

                              shape:
                              BoxShape.circle,

                            ),

                            child:
                            const Icon(

                              Icons.close,

                              color:
                              Colors.red,

                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )

                    : Column(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Icon(

                      Icons
                          .cloud_upload,

                      size:
                      70,

                      color:
                      Colors.grey,

                    ),

                    const SizedBox(
                        height:
                        20),

                    const Text(

                      "Upload Image",

                      style:
                      TextStyle(

                        fontSize:
                        20,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height:
                        10),

                    Text(

                      "Select image from\ncamera or gallery",

                      textAlign:
                      TextAlign.center,

                      style:
                      TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:

      Container(

        padding:
        const EdgeInsets.all(20),

        decoration:
        const BoxDecoration(

          color:
          Colors.white,

          borderRadius:
          BorderRadius.vertical(

            top:
            Radius.circular(
                25),
          ),
        ),

        child:
        selectedImage!=null?  Row(

          children: [



            Expanded(

              child:
              ElevatedButton.icon(

                onPressed:
                    () {

                  setState(() {

                    selectedImage = null;
                  });

                },

                icon:
                const Icon(
                  Icons.refresh,
                ),

                label:
                const Text(
                  "Retry",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  primaryAppColor,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical:
                    14,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                ),
              ),
            ),
            const SizedBox(
                width: 15),
            Expanded(
              child:
              ElevatedButton.icon(
                onPressed:
                    () {

                  Navigator.pop(context, selectedImage);

                  },
                icon:
                const Icon(
                  Icons.check_circle_outline,
                ),

                label:
                const Text(
                  "Confirm",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical:
                    14,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                ),
              ),
            ),


          ],
        ):
        Row(

          children: [


            Expanded(

              child:
              ElevatedButton.icon(

                onPressed:
                    () {

                  pickImage(
                    ImageSource.camera,
                  );

                },

                icon:
                const Icon(
                  Icons.camera,
                ),

                label:
                const Text(
                  "Camera",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  primaryAppColor,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical:
                    14,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                ),
              ),
            ),

            const SizedBox(
                width: 15),

            Expanded(

              child:
              ElevatedButton.icon(

                onPressed:
                    () {

                  pickImage(
                    ImageSource.gallery,
                  );

                },

                icon:
                const Icon(
                  Icons.photo,
                ),

                label:
                const Text(
                  "Gallery",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  primaryAppColor,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical:
                    14,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}