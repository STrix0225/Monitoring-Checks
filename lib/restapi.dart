import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart' as ApiConfig;

class DataService {

  final String token = '694514be380728163dc2a32d';
  final String project = 'monitoring_ng';
  final String appid = '69454e57380728163dc2a38d';
  
  Future insertKepalaDepartemen(String appid, String username, String password) async {
    String uri = 'https://api.247go.app/v5/insert/';

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'token': token,
        'project': project,
        'collection': 'kepala_departemen',
        'appid': appid,
        'username': username,
        'password': password
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
      'token': token,
      'project': project,
      'collection': 'daily_target',
      'appid': appid,
      'customer': customer,
      'category': category,
      'product': product,
      'target_qty': targetQty.toString(),
      'actual_qty': '0', // BARU - default 0
      'delivery_date': deliveryDate.toIso8601String(),
      'status': 'On Progress', // BARU - default status
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '[]';
    }
  } catch (e) {
    return '[]';
  }
}

Future getNgItemsUnconfirmed() async {
  String uri = 'https://api.247go.app/v5/select_where/token/' + 
      token + '/project/' + project + '/collection/quality_check_results/appid/' + 
      appid + '/where_field/confirmed/where_value/false';
  
  try {
    final response = await http.get(Uri.parse(uri));
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '[]';
    }
  } catch (e) {
    print('Error getNgItemsUnconfirmed: $e');
    return '[]';
  }
}

Future getAllNgItems() async {
  String uri = 'https://api.247go.app/v5/select_where/token/' + 
      token + '/project/' + project + '/collection/quality_check_results/appid/' + 
      appid + '/where_field/status/where_value/NG';
  
  try {
    final response = await http.get(Uri.parse(uri));
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '[]';
    }
  } catch (e) {
    print('Error getAllNgItems: $e');
    return '[]';
  }
}
  Future<dynamic> insertPicLine(String token, String project, String appid, String id_pic, String nama, String line, String password, String photo) async {
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

      final responseBody = response.body;
      print('insertPicLine - HTTP ${response.statusCode} - body: $responseBody');

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(responseBody);
          return decoded;
        } catch (e) {
          return responseBody;
        }
      } else {
        return '[]';
      }
    } catch (e) {
      print('insertPicLine error: $e');
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
        return '[]';
      }
    } catch (e) {
      return '[]';
    }
  }

  Future selectId(String token, String project, String collection, String appid, String id) async {
    String encodedId = Uri.encodeComponent(id);
    String uri = 'https://api.247go.app/v5/select_id/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/id/' + encodedId;

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      return '[]';
    }
  }

  Future selectWhere(String token, String project, String collection, String appid, String where_field, String where_value) async {
    final ef = Uri.encodeComponent(where_field);
    final ev = Uri.encodeComponent(where_value);
    String uri = 'https://api.247go.app/v5/select_where/token/' + token + '/project/' + project + '/collection/' + collection + '/appid/' + appid + '/where_field/' + ef + '/where_value/' + ev;

    try {
      final response = await http.get(Uri.parse(uri));
      print('selectWhere -> GET $uri -> HTTP ${response.statusCode} -> body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      print('selectWhere error for $uri : $e');
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
      return '[]';
    }
  }

  Future<bool> removeAll(String token, String project, String collection, String appid) async {
    String uri = 'https://api.247go.app/v5/remove_all/token/$token/project/$project/collection/$collection/appid/$appid';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeId(String token, String project, String collection, String appid, String id) async {
    final uri = Uri.parse(
      'https://api.247go.app/v5/remove_id/token/$token/project/$project/collection/$collection/appid/$appid/id/$id',
    );

    try {
      final response = await http.get(uri);
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == '1';
      } else {
        return false;
      }
    } catch (e) {
      print('Error removeId: $e');
      return false;
    }
  }

  Future<bool> removeWhere(String token, String project, String collection, String appid, String whereField, String whereValue) async {
    String uri = 'https://api.247go.app/v5/remove_where/token/$token/project/$project/collection/$collection/appid/$appid/where_field/$whereField/where_value/$whereValue';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeOrWhere(String token, String project, String collection, String appid, String orWhereField, String orWhereValue) async {
    String uri = 'https://api.247go.app/v5/remove_or_where/token/$token/project/$project/collection/$collection/appid/$appid/or_where_field/$orWhereField/or_where_value/$orWhereValue';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWhereLike(String token, String project, String collection, String appid, String wlikeField, String wlikeValue) async {
    String uri = 'https://api.247go.app/v5/remove_where_like/token/$token/project/$project/collection/$collection/appid/$appid/wlike_field/$wlikeField/wlike_value/$wlikeValue';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWhereIn(String token, String project, String collection, String appid, String winField, String winValue) async {
    String uri = 'https://api.247go.app/v5/remove_where_in/token/$token/project/$project/collection/$collection/appid/$appid/win_field/$winField/win_value/$winValue';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWhereNotIn(String token, String project, String collection, String appid, String wnotinField, String wnotinValue) async {
    String uri = 'https://api.247go.app/v5/remove_where_not_in/token/$token/project/$project/collection/$collection/appid/$appid/wnotin_field/$wnotinField/wnotin_value/$wnotinValue';

    try {
      final response = await http.delete(Uri.parse(uri));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future updateAll(String update_field, String update_value, String token, String project, String collection, String appid) async {
    String uri = 'https://api.247go.app/v5/update_all/';

    try {
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
      final response = await http.put(Uri.parse(uri), body: {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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
        return '[]';
      }
    } catch (e) {
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

  Future<bool> updateDailyTargetActualQty(String targetId, int newActualQty) async {
  String uri = 'https://api.247go.app/v5/update_id/';
  
  try {
    final response = await http.put(Uri.parse(uri), body: {
      'update_field': 'actual_qty',
      'update_value': newActualQty.toString(),
      'token': token,
      'project': project,
      'collection': 'daily_target',
      'appid': appid,
      'id': targetId,
    });

    return response.statusCode == 200;
  } catch (e) {
    print('Error updateDailyTargetActualQty: $e');
    return false;
  }
}

// Method untuk update status daily_target berdasarkan progress
Future<bool> updateDailyTargetStatus(String targetId, String status) async {
  String uri = 'https://api.247go.app/v5/update_id/';
  
  try {
    final response = await http.put(Uri.parse(uri), body: {
      'update_field': 'status',
      'update_value': status,
      'token': token,
      'project': project,
      'collection': 'daily_target',
      'appid': appid,
      'id': targetId,
    });

    return response.statusCode == 200;
  } catch (e) {
    print('Error updateDailyTargetStatus: $e');
    return false;
  }
}

// Method untuk konfirmasi NG dan kurangi actual_qty
Future<bool> confirmNgAndUpdateQty(String ngResultId, String targetId, int currentActualQty) async {
  // 1. Update quality_check_results.confirmed = true
  String uri = 'https://api.247go.app/v5/update_id/';
  
  try {
    // Update NG result
    final response1 = await http.put(Uri.parse(uri), body: {
      'update_field': 'confirmed',
      'update_value': 'true',
      'token': token,
      'project': project,
      'collection': 'quality_check_results',
      'appid': appid,
      'id': ngResultId,
    });

    if (response1.statusCode != 200) return false;

    // 2. Kurangi actual_qty di daily_target
    int newActualQty = currentActualQty - 1;
    if (newActualQty < 0) newActualQty = 0;
    
    return await updateDailyTargetActualQty(targetId, newActualQty);
  } catch (e) {
    print('Error confirmNgAndUpdateQty: $e');
    return false;
  }
}


  Future<dynamic> insertQualityParameters({
    required String category,
    required String product,
    required List<Map<String, dynamic>> parameters,
  }) async {
    String uri = 'https://api.247go.app/v5/insert/';
    try {
      final response = await http.post(Uri.parse(uri), body: {
        'token': ApiConfig.token,
        'project': ApiConfig.project,
        'collection': 'quality_parameters',
        'appid': ApiConfig.appid,
        'category': category,
        'product': product,
        'parameters': jsonEncode(parameters),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      print('insertQualityParameters error: $e');
      return '[]';
    }
  }

  Future insertQualityCheckResult({
  required String targetId, // BARU: WAJIB
  required String picId,
  required String productName,
  required String category,
  required String customer,
  required String status,
  required List<Map<String, dynamic>> parameters,
  required List<String> ngReasons,
  required List<String> photos,
  required String notes,
}) async {
  String uri = 'https://api.247go.app/v5/insert/';
  
  try {
    final response = await http.post(Uri.parse(uri), body: {
      'token': token,
      'project': 'monitoring_ng',
      'collection': 'quality_check_results',
      'appid': appid,
      'target_id': targetId, // BARU: target_id
      'pic_id': picId,
      'product_name': productName,
      'category': category,
      'customer': customer,
      'check_date': DateTime.now().toIso8601String(),
      'status': status,
      'quantity_ok': status == 'OK' ? '1' : '0',
      'quantity_ng': status == 'NG' ? '1' : '0',
      'parameters': jsonEncode(parameters),
      'ng_reasons': jsonEncode(ngReasons),
      'photos': jsonEncode(photos),
      'notes': notes,
      'confirmed': 'false',
      'disposition': '',
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '[]';
    }
  } catch (e) {
    print('Error insertQualityCheckResult: $e');
    return '[]';
  }
}

  // Get quality parameters by category + product (mengembalikan JSON string)
  Future getQualityParametersByProduct(String category, String product) async {
  try {
    // Pertama, ambil semua parameter untuk kategori
    String response = await selectWhere(
      token,
      project,
      'quality_parameters',
      appid,
      'category',
      category,
    );
    
    final responseApi = jsonDecode(response);
    if (responseApi['data'] != null) {
      List<dynamic> data = responseApi['data'] as List<dynamic>;
      
      // Cari parameter untuk produk spesifik
      var productParams = data.firstWhere(
        (item) => item['product'] == product,
        orElse: () => null,
      );
      
      if (productParams != null) {
        return jsonEncode({'data': productParams});
      }
    }
    
    return '{"data": null}';
  } catch (e) {
    print('Error getQualityParametersByProduct: $e');
    return '{"data": null}';
  }
}

  // Helper upload photo for NG: return filename/url (string)
  Future<String> uploadPhotoForNg(List<int> fileBytes, String ext) async {
    try {
      final res = await upload(ApiConfig.token, ApiConfig.project, fileBytes, ext);
      if (res is Map) {
        // Try common keys
        if (res.containsKey('data')) return res['data'].toString();
        if (res.containsKey('file')) return res['file'].toString();
        if (res.containsKey('url')) return res['url'].toString();
        return res.toString();
      } else if (res is String) {
        return res;
      } else {
        return '';
      }
    } catch (e) {
      print('uploadPhotoForNg error: $e');
      return '';
    }
  }

  // Insert quality check result (dipakai oleh UI)
  Future<dynamic> insertQualityResult({
    required String targetId,
    required String picId,
    required String productName,
    required String category,
    required String customer,
    required String status,
    required List<Map<String, dynamic>> parameters,
    required List<String> ngReasons,
    required List<String> photos,
    required String notes,
  }) async {
    String uri = 'https://api.247go.app/v5/insert/';

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'token': ApiConfig.token,
        'project': ApiConfig.project,
        'collection': 'quality_check_results',
        'appid': ApiConfig.appid,
        'target_id': targetId,
        'pic_id': picId,
        'product_name': productName,
        'category': category,
        'customer': customer,
        'check_date': DateTime.now().toIso8601String(),
        'status': status,
        'quantity_ok': status == 'OK' ? '1' : '0',
        'quantity_ng': status == 'NG' ? '1' : '0',
        'parameters': jsonEncode(parameters),
        'ng_reasons': jsonEncode(ngReasons),
        'photos': jsonEncode(photos),
        'notes': notes,
        'confirmed': 'false',
        'disposition': '',
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      print('Error insertQualityResult: $e');
      return '[]';
    }
  }

  // Get NG items (unconfirmed)
  Future getUnconfirmedNgItems() async {
    String uri = 'https://api.247go.app/v5/select_where/token/' +
        ApiConfig.token + '/project/' + ApiConfig.project + '/collection/quality_check_results/appid/' +
        ApiConfig.appid + '/where_field/status/where_value/NG';

    try {
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '[]';
      }
    } catch (e) {
      print('Error getUnconfirmedNgItems: $e');
      return '[]';
    }
  }
}

// Compatibility alias (dipakai di beberapa file)
class DataServiceV2 extends DataService {}