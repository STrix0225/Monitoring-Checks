class FuelSystemPartsModel {
   final String id;
   final String canister;
   final String fuel_inlet_pipe;

   FuelSystemPartsModel({
      required this.id,
      required this.canister,
      required this.fuel_inlet_pipe
   });

   factory FuelSystemPartsModel.fromJson(Map data) {
      return FuelSystemPartsModel(
         id: data['_id'],
         canister: data['canister'],
         fuel_inlet_pipe: data['fuel_inlet_pipe']
      );
   }
}