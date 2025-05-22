class Post {
  final String id;
  final String description;
  final String imageUrl;
  final String userUid;
  final String username;
  final String userProfileImage;
  final String tipoPerfil;
  final int likes;
  final Map<String, dynamic>? location;

  Post({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.userUid,
    required this.username,
    required this.userProfileImage,
    required this.tipoPerfil,
    required this.likes,
    required this.location,
  });
}
