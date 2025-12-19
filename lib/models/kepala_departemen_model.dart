class KepalaDepartemenModel {
   final String id;
   final String username;
   final String password;
   final String photo_pic;
   final String nama_pic;
   final String line;
   final String id_pic;
   final String password_pic;

   KepalaDepartemenModel({
      required this.id,
      required this.username,
      required this.password,
      required this.photo_pic,
      required this.nama_pic,
      required this.line,
      required this.id_pic,
      required this.password_pic
   });

   factory KepalaDepartemenModel.fromJson(Map data) {
      return KepalaDepartemenModel(
         id: data['id'] ?? data['_id'] ?? '',
         username: data['username'],
         password: data['password'],
         photo_pic: data['photo_pic'],
         nama_pic: data['nama_pic'],
         line: data['line'],
         id_pic: data['id_pic'],
         password_pic: data['password_pic']
      );
   }
}