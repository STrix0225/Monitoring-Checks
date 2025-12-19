class BodyPartsModel {
   final String id;
   final String front_pillar_upper_outer;
   final String front_pillar_lower_outer;
   final String cowl_assembly;
   final String wheel_house_inner;
   final String rear_floor_side_member_subassembly;
   final String outer_subassembly;

   BodyPartsModel({
      required this.id,
      required this.front_pillar_upper_outer,
      required this.front_pillar_lower_outer,
      required this.cowl_assembly,
      required this.wheel_house_inner,
      required this.outer_subassembly,
      required this.rear_floor_side_member_subassembly
   });

   factory BodyPartsModel.fromJson(Map data) {
      return BodyPartsModel(
         id: data['_id'],
         front_pillar_upper_outer: data['front_pillar_upper_outer'],
         front_pillar_lower_outer: data['front_pillar_lower_outer'],
         cowl_assembly: data['cowl_assembly'],
         wheel_house_inner: data['wheel_house_inner'],
         outer_subassembly: data['outer_subassembly'],
         rear_floor_side_member_subassembly: data['rear_floor_side_member_subassembly']
      );
   }
}