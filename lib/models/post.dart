// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String description;
  final List<String> tags;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final int likes;
  final List<String> likedBy;
  final List<Map<String, dynamic>> comments;
  final Timestamp createdAt;
  final String uid;       // ID do usuário que criou o post
  final String authorName; // Nome do autor do post

  Post({
    required this.id,
    required this.description,
    required this.tags,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
    required this.uid,
    required this.authorName, // Adicionado ao construtor
  });

  // Método para converter um documento do Firestore em um objeto Post
  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      uid: map['uid'] ?? '',
      authorName: map['authorName'] ?? 'Anônimo', // Adicionado aqui
    );
  }

  // Método para converter um objeto Post em um mapa para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'tags': tags,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'likes': likes,
      'likedBy': likedBy,
      'comments': comments,
      'createdAt': createdAt,
      'uid': uid,
      'authorName': authorName, // Adicionado aqui
    };
  }
}