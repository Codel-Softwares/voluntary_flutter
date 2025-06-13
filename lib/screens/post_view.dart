import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/user_services.dart';

//import '../widgets/loading_dialog.dart'; // Chat gpt recomenda usar um

class PostView extends StatefulWidget {
  const PostView({Key? key}) : super(key: key);

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _userNome;
  String? _imagemPerfil;
  String _tipoPerfil = 'comun';
  LatLng? _location;
  bool _isEvent = false;
  bool _mapVisible = false;
  LatLng? _selectedLocation;

  final picker = ImagePicker();
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initLocation();
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await getUserProfile();
    if (userProfile != null) {
      setState(() {
        _userNome = userProfile.nomeUsuario;
        _imagemPerfil = userProfile.imagemPerfil;
        _tipoPerfil = userProfile.tipoPerfil ?? 'comun';
      });
    }
  }

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Erro no upload: $e");
      return null;
    }
  }

  Future<void> _handlePost() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Descrição não pode estar vazia.")));
      return;
    }

    //showDialog(context: context, builder: (_) => const LoadingDialog());

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl ?? '', // Use '' se a imagem for nula
        'description': _descriptionController.text,
        'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
        'createdAt': Timestamp.now(),
        'userUid': user.uid,
        'username': _userNome,         
        'userProfileImage': _imagemPerfil, 
        'tipoPerfil': _tipoPerfil,
        'likes': 0, // Inicializa likes
        'likedBy': [], // Inicializa likedBy
        'location': _location != null
            ? {
                'latitude': _location!.latitude,
                'longitude': _location!.longitude,
              }
            : null,
        'isEvent': _isEvent,
      });

      Navigator.of(context).pop(); // fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Postado com sucesso!")));

      setState(() {
        _image = null;
        _descriptionController.clear();
        _tagsController.clear();
      });
    } catch (e) {
      Navigator.of(context).pop();
      print("Erro ao postar: $e");
    }
  }

  void _openMapModal() {
    setState(() {
      _mapVisible = true;
    });
  }

  void _closeMapModal() {
    setState(() {
      _mapVisible = false;
    });
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      setState(() {
        _location = _selectedLocation;
        _mapVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _image != null
              ? Image.file(_image!, fit: BoxFit.cover, height: double.infinity, width: double.infinity)
              : Container(color: Colors.grey[300]),
          Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              children: [
                // Perfil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: _imagemPerfil != null ? NetworkImage(_imagemPerfil!) : null,
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Text('@${_userNome ?? '...'}', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.map, color: Colors.white),
                      onPressed: _openMapModal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Escolher imagem"),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Coloque sua descrição aqui...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            hintText: 'Tags separadas por vírgula',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_tipoPerfil == "ONG")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Tipo: ${_isEvent ? 'Evento' : 'Post'}"),
                              Switch(
                                value: _isEvent,
                                onChanged: (val) => setState(() => _isEvent = val),
                              ),
                            ],
                          ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _handlePost,
                          icon: Icon(Icons.send),
                          label: Text("Postar"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_mapVisible)
            Positioned.fill(
              child: Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      onTap: (pos) => setState(() => _selectedLocation = pos),
                      markers: _selectedLocation != null
                          ? {
                              Marker(markerId: MarkerId("loc"), position: _selectedLocation!)
                            }
                          : {},
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(onPressed: _closeMapModal, child: Text("Cancelar")),
                          ElevatedButton(
                            onPressed: _saveLocation,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text("Salvar Local"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
