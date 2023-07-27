import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();
  bool _isLoading = false;

  //What is Uint8 List?
  // Uint8List is a list of integers
  //where the values in the list are only 8 bits each,
  //or one byte. The U of Uint8List means unsigned,
  //so the values range from 0 to 255 .
  late Uint8List _imageData = Uint8List(0);
 
  void _convertTextToImage() async{
    setState(() {
      _isLoading = true;
    });

    const baseUrl = 'https://api.stability.ai';
    final url = Uri.parse(
        '$baseUrl/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image'
    );

    // Make the HTTP POST request to the Stability Platform API
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sk-L0Ac78KXgfU8BrpXAZVca2VVczpmv22GxGEdMBdeaBgyKh4I',
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
            'text': _textController.text ?? '',
            'weight': 1,
          }
        ],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode !=200){
      _showErrorDialog('Failed to generate image');
    }
    else{
      try{
        _imageData = (response.bodyBytes);
        setState(() {

        });
      }
      on Exception
      catch(e){
        _showErrorDialog('Failed to generate image');
      }
    }
  }


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
  
  
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black54,
          appBar: AppBar(
            title: const Text("sAI"),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                  fillColor: Colors.white,
                  filled: true,
                  // contentPadding: const EdgeInsets.all(16),
                  // labelStyle: TextStyle(color: Colors.red),
                )
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,

                  ),
                  onPressed: _convertTextToImage,
                  child: _isLoading
                      ? const SizedBox(height:30, width:30,child: CircularProgressIndicator(color: Colors.redAccent))
                      : const Text('Generate Image'),
                ),
              ),
              const SizedBox(height: 30,),
              if (_imageData != null) Image.memory(_imageData)
            ],
          ),
        ),
    );

    
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
