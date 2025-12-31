// ignore_for_file: prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart' as ApiConfig;

class DataService {
   Future insertKepalaDepartemen(String appid, String username, String password) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '694514be380728163dc2a32d',
            'project': 'monitoring_ng',
            'collection': 'kepala_departemen',
            'appid': appid,
            'username': username,
            'password': password
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertProducts(String appid, String id, String category_id, String name, String customer, String quantity, String stock, String availability, String quality_status, String check_by, String check_date) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': '694514be380728163dc2a32d',
            'project': 'monitoring_ng',
            'collection': 'products',
            'appid': appid,
            'id': id,
            'category_id': category_id,
            'name': name,
            'customer': customer,
            'quantity': quantity,
            'stock': stock,
            'availability': availability,
            'quality_status': quality_status,
            'check_by': check_by,
            'check_date': check_date
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future insertDailyTarget({
    required String customer,
    required String category,
    required String product,
    required int targetQty,
    required DateTime deliveryDate,
  }) async {
    String uri = 'https://api.247go.app/v5/insert/';

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'token': ApiConfig.token,
        'project': ApiConfig.project,
      'collection': 'daily_target',
        'appid': ApiConfig.appid,
        'customer': customer,
        'category': category,
        'product': product,
        'target_qty': targetQty.toString(),
        'delivery_date': deliveryDate.toIso8601String(),
        'actual_qty': '0',
        'status': 'Not Started',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      // Print error here
      return '[]';
    }
   }

   Future insertPicLine(String token, String project, String appid, String id_pic, String nama, String line, String password, String photo) async {
      String uri = 'https://api.247go.app/v5/insert/';

      try {
         final response = await http.post(Uri.parse(uri), body: {
            'token': token,
            'project': project,
            'collection': 'pic_line',
            'appid': appid,
            'id_pic': id_pic,
            'nama': nama,
            'line': line,
            'password': password,
            'photo': photo
         });

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/select_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectId(String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/select_id/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/id/' + id;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/select_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/select_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/select_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/select_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future selectWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/select_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future removeAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/remove_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeId(String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/remove_id/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/id/' + id;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/remove_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/remove_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future removeWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/remove_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.delete(Uri.parse(uri));

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         // Print error here
         return false;
      }
   }

   Future updateAll(String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_all/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateId(String update_field, String update_value, String token, String project, String collection, String appid, String id) async {
      String uri = 'https://api.247go.app/v5/update_id/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid,
             'id': id
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhere(String where_field, String where_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'where_field': where_field,
             'where_value': where_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateOrWhere(String or_where_field, String or_where_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_or_where/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'or_where_field': or_where_field,
             'or_where_value': or_where_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereLike(String wlike_field, String wlike_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_like/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'wlike_field': wlike_field,
             'wlike_value': wlike_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereIn(String win_field, String win_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_in/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'win_field': win_field,
             'win_value': win_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future updateWhereNotIn(String wnotin_field, String wnotin_value, String update_field, String update_value, String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/update_where_not_in/';

      try {
         final response = await http.put(Uri.parse(uri),body: {
             'wnotin_field': wnotin_field,
             'wnotin_value': wnotin_value,
             'update_field': update_field,
             'update_value': update_value,
             'token': token,
             'project': project,
             'collection': collection,
             'appid': appid
         });

         if (response.statusCode == 200) {
            return true;
         } else {
            return false;
         }
      } catch (e) {
         return false;
      }
   }

   Future firstAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/first_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/first_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/first_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/first_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/first_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future firstWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/first_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/last_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/last_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/last_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/last_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/last_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future lastWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/last_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomAll(String token, String project, String collection, String appid) async {
      String uri = 'https://api.247go.app/v5/random_all/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
      String uri = 'https://api.247go.app/v5/random_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + where_field + '/where_value/' + where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomOrWhere(String token, String project, String collection, String appid, String or_where_field, String or_where_value) async {
      String uri = 'https://api.247go.app/v5/random_or_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/or_where_field/' + or_where_field + '/or_where_value/' + or_where_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereLike(String token, String project, String collection, String appid, String wlike_field, String wlike_value) async {
      String uri = 'https://api.247go.app/v5/random_where_like/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wlike_field/' + wlike_field + '/wlike_value/' + wlike_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereIn(String token, String project, String collection, String appid, String win_field, String win_value) async {
      String uri = 'https://api.247go.app/v5/random_where_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/win_field/' + win_field + '/win_value/' + win_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

   Future randomWhereNotIn(String token, String project, String collection, String appid, String wnotin_field, String wnotin_value) async {
      String uri = 'https://api.247go.app/v5/random_where_not_in/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/wnotin_field/' + wnotin_field + '/wnotin_value/' + wnotin_value;

      try {
         final response = await http.get(Uri.parse(uri));

         if (response.statusCode == 200) {
            return response.body;
         } else {
            // Return an empty array
            return '[]';
         }
      } catch (e) {
         // Print error here
         return '[]';
      }
   }

    // Method untuk mengambil semua daily targets tanpa filter tanggal
    Future getDailyTargetsByDate([DateTime? date]) async {
       try {
          String response = await selectAll(
            ApiConfig.token,
            ApiConfig.project,
            'daily_target',
            ApiConfig.appid,
          );

          if (response == '[]' || response.isEmpty) return '{"data": []}';

          // Return whatever the API returned (expected to be {"data": [...]})
          return response;
       } catch (e) {
          return '{"data": []}';
       }
    }
    Future<dynamic> upload(String token, String project, List<int> file, String ext) async {
         String url = 'https://files.247go.app/files/up';

         try {
            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.fields['token'] = token;
            request.fields['project'] = project;

            request.files.add(
               http.MultipartFile.fromBytes(
                  'file',
                  file,
                  filename: 'pic_line_${DateTime.now().millisecondsSinceEpoch}.' + ext,
               ),
            );

            final streamed = await request.send();

            if (streamed.statusCode == 200) {
               final res = await http.Response.fromStream(streamed);
               final responseBody = res.body;
               // Debug print to inspect response format
               print('Upload Response: $responseBody');

               try {
                  final decoded = jsonDecode(responseBody);
                  return decoded;
               } catch (e) {
                  return responseBody;
               }
            } else {
               throw Exception('Upload failed with status: ${streamed.statusCode}');
            }
         } catch (e) {
            print('Upload error: $e');
            throw Exception('Upload failed: $e');
         }
    }

}