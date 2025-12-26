class PicLineModel {
   final String id;
   final String id_pic;
   final String nama;
   final String line;
   final String password;
   final String photo;

   PicLineModel({
      required this.id,
      required this.id_pic,
      required this.nama,
      required this.line,
      required this.password,
      required this.photo
   });

   factory PicLineModel.fromJson(Map<String, dynamic> data) {
      final rawId = data['_id'] ?? data['id'] ?? '';
      final rawIdPic = data['id_pic'] ?? data['idPic'] ?? '';
      final rawNama = data['nama'] ?? data['name'] ?? '';
      final rawLine = data['line'] ?? '';
      final rawPassword = data['password'] ?? data['pass'] ?? '';
      final rawPhoto = data['photo'] ?? data['photo_pic'] ?? '';

      return PicLineModel(
         id: rawId is String ? rawId : rawId.toString(),
         id_pic: rawIdPic is String ? rawIdPic : rawIdPic.toString(),
         nama: rawNama is String ? rawNama : rawNama.toString(),
         line: rawLine is String ? rawLine : rawLine.toString(),
         password: rawPassword is String ? rawPassword : rawPassword.toString(),
         photo: rawPhoto is String ? rawPhoto : rawPhoto.toString(),
      );
   }
}