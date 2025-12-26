class KepalaDepartemenModel {
   final String id;
   final String username;
   final String password;

   KepalaDepartemenModel({
      required this.id,
      required this.username,
      required this.password
   });

   factory KepalaDepartemenModel.fromJson(Map<String, dynamic> data) {
      // API sometimes returns `_id` or `id` depending on endpoint/version.
      final rawId = data['_id'] ?? data['id'] ?? '';
      final rawUsername = data['username'] ?? data['user'] ?? '';
      final rawPassword = data['password'] ?? data['pass'] ?? '';

      return KepalaDepartemenModel(
         id: rawId is String ? rawId : rawId.toString(),
         username: rawUsername is String ? rawUsername : rawUsername.toString(),
         password: rawPassword is String ? rawPassword : rawPassword.toString(),
      );
   }
}