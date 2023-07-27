import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _textController = TextEditingController();

  late Uint8List _imageData = Uint8List(0);
  bool _isLoading = false; // Add this line

  void _convertTextToImage() async {
    setState(() {
      _isLoading = true;
    });

    const baseUrl = 'https://api.stability.ai';
    final url = Uri.parse(
        '$baseUrl/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image');

    // Make the HTTP POST request to the Stability Platform API
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer sk-L0Ac78KXgfU8BrpXAZVca2VVczpmv22GxGEdMBdeaBgyKh4I',
        'Accept': 'image/png',
      },
      body: jsonEncode({
        'cfg_scale': 7,
        'clip_guidance_preset': 'FAST_BLUE',
        'height': 512,
        'width': 512,
        'samples': 1,
        'steps': 50,
        'text_prompts': [
          {
            'text': _textController.text,
            'weight': 1,
          }
        ],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode != 200) {
      _showErrorDialog('Failed to generate image');
    } else {
      try {
        _imageData = (response.bodyBytes);
        setState(() {});
      } on Exception catch (e) {
        _showErrorDialog('Failed to generate image');
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.deepPurple[100],
          appBar: AppBar(
            title: const Text(
              'Text To Image',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.deepPurple[300],
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter text',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16),
                        labelStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(185, 172, 102, 204),
                      ),
                      onPressed: _convertTextToImage,
                      child: _isLoading
                          ? const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                  color: Colors.redAccent))
                          : const Text('Generate'),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_imageData != null) Image.memory(_imageData),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(185, 172, 102, 204),
                        ),
                        onPressed: ()async{
                          String path =
                              'https://api.stability.ai/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image';
                          GallerySaver.saveImage(path).then((bool? success) {
                            setState(() {
                              print('Image is saved');
                            });
                          });
                        },
                        child: const Text('Save'))
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
