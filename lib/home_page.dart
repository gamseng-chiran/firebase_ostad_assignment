import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final List<String> storedImage = [];
  XFile? _pickedImage;

  void initState(){
    super.initState();
    _getImageFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show images'),
      ),
      body: GridView.builder(
        itemCount: storedImage.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
       itemBuilder:  (context, index) {
         return Card(
          child: Image.network(storedImage[index],
          fit: BoxFit.cover,)
          
         );
       }),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickImage();
        },
        child: Icon(Icons.add),
       ),
    );
  }
  Stream<ListResult> listAll(Reference storageRef) async*{
    String? pageToken;
    do{
      final listResult = await storageRef.list(
        ListOptions(
          maxResults: 100,
          pageToken: pageToken,
        ),
      );
      yield listResult;
      pageToken = listResult.nextPageToken;
    } while(pageToken != null);
  }
  Future<void> _getImageFromStorage () async{
    final storageRef = _firebaseStorage.ref().child('image');
    final listResult = listAll(storageRef);
    storedImage.clear();
    await for (ListResult result in listResult){
      for(Reference reference in result.items){
        final url = await reference.getDownloadURL();
        storedImage.add(url);
        setState(() {
          
        });
      }
    }
  }
  Future<void> _pickImage() async{
    final ImagePicker imagePicker = ImagePicker();
    _pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (_pickedImage != null){
      File imageFile = File(_pickedImage!.path);
      await _uploadImageToFirebase(imageFile);
    }  
    }
    Future<void> _uploadImageToFirebase(File imageFile) async{
      final storageRef = _firebaseStorage.ref().child('image/${_pickedImage!.name}');
      await storageRef.putFile(imageFile);
      _getImageFromStorage();
    }
}