class SuspensionPartsModel {
   final String id;
   final String front_suspension_sub_frame;
   final String trailing_arm;
   final String rear_axle_beam;
   final String engine_undercover;

   SuspensionPartsModel({
      required this.id,
      required this.front_suspension_sub_frame,
      required this.trailing_arm,
      required this.rear_axle_beam,
      required this.engine_undercover
   });

   factory SuspensionPartsModel.fromJson(Map data) {
      return SuspensionPartsModel(
         id: data['_id'],
         front_suspension_sub_frame: data['front_suspension_sub_frame'],
         trailing_arm: data['trailing_arm'],
         rear_axle_beam: data['rear_axle_beam'],
         engine_undercover: data['engine_undercover']
      );
   }
}