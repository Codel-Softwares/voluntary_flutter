// lib/models/post.dart (Exemplo de como poderia ser, se ainda não tiver os likes)
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String description;
  final String imageUrl;
  final String userUid;
  final String username;           // <--- Campo para o nome de usuário
  final String userProfileImage;   // <--- Campo para a URL da imagem de perfil
  final String tipoPerfil;
  final int likes;
  final List<String> likedBy;
  final Timestamp createdAt; // Adicionado para manter o timestamp de criação

  Post({
    required this.id,
    required this.description,
    this.imageUrl = '',
    required this.userUid,
    required this.username,          // O nome de usuário é essencial
    this.userProfileImage = '',      // Imagem de perfil pode ter um padrão vazio
    required this.tipoPerfil,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt, // Deve ser required
  });

  // Método para criar um Post a partir de um mapa de dados (vindo do Firestore)
  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      userUid: map['userUid'] ?? '',
      username: map['username'] ?? 'Usuário Desconhecido', // <--- Garante que lê 'username' ou um padrão
      userProfileImage: map['userProfileImage'] ?? '',     // <--- Garante que lê 'userProfileImage' ou um padrão
      tipoPerfil: map['tipoPerfil'] ?? '',
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(), // Garante que lê 'createdAt'
    );
  }

  // Método para converter um Post em um mapa (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'imageUrl': imageUrl,
      'userUid': userUid,
      'username': username,
      'userProfileImage': userProfileImage,
      'tipoPerfil': tipoPerfil,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
    };
  }
}