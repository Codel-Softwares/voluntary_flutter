// lib/models/post.dart (Exemplo de como poderia ser, se ainda não tiver os likes)
class Post {
  final String id;
  final String description;
  final String imageUrl;
  final String userUid;
  final String username;
  final String userProfileImage;
  final String tipoPerfil;
  final int likes; // Adicionado para contar os likes
  final List<String> likedBy; // Adicionado para rastrear quem curtiu (opcional, mas bom para evitar multi-likes)

  Post({
    required this.id,
    required this.description,
    this.imageUrl = '',
    required this.userUid,
    required this.username,
    this.userProfileImage = '',
    required this.tipoPerfil,
    this.likes = 0,
    this.likedBy = const [],
  });

  // Método para criar um Post a partir de um mapa de dados (vindo do Firestore, por exemplo)
  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      userUid: map['userUid'] ?? '',
      username: map['username'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      tipoPerfil: map['tipoPerfil'] ?? '',
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
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
    };
  }
}