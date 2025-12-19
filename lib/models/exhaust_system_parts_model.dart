class ExhaustSystemPartsModel {
   final String id;
   final String exhaust_system;
   final String exhaust_manifold;
   final String diesel_exhaust_gas_post_treatment_device;

   ExhaustSystemPartsModel({
      required this.id,
      required this.exhaust_system,
      required this.exhaust_manifold,
      required this.diesel_exhaust_gas_post_treatment_device
   });

   factory ExhaustSystemPartsModel.fromJson(Map data) {
      return ExhaustSystemPartsModel(
         id: data['_id'],
         exhaust_system: data['exhaust_system'],
         exhaust_manifold: data['exhaust_manifold'],
         diesel_exhaust_gas_post_treatment_device: data['diesel_exhaust_gas_post-treatment_device']
      );
   }
}