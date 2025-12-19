class InteriorPartsModel {
   final String id;
   final String instrument_panel_reinforcement;

   InteriorPartsModel({
      required this.id,
      required this.instrument_panel_reinforcement
   });

   factory InteriorPartsModel.fromJson(Map data) {
      return InteriorPartsModel(
         id: data['_id'],
         instrument_panel_reinforcement: data['instrument_panel_reinforcement']
      );
   }
}