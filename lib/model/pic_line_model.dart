class PicLineModel {
   final String id;
   final String id_pic;
   final String password;
   final String gambar_produk;

   PicLineModel({
      required this.id,
      required this.id_pic,
      required this.password,
      required this.gambar_produk
   });

   factory PicLineModel.fromJson(Map data) {
      return PicLineModel(
         id: data['_id'],
         id_pic: data['id_pic'],
         password: data['password'],
         gambar_produk: data['gambar_produk']
      );
   }
}