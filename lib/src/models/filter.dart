import '../models/field.dart';

class Filter {
  bool delivery;
  bool open = true;
  List<Field> fields;

  Filter();

  Filter.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      // open = jsonMap['open'] ?? true;
      delivery = jsonMap['delivery'] ?? false;
      fields = jsonMap['fields'] != null && (jsonMap['fields'] as List).length > 0
          ? List.from(jsonMap['fields']).map((element) => Field.fromJSON(element)).toList()
          : [];
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['open'] = open;
    map['delivery'] = delivery;
    map['fields'] = fields.map((element) => element.toMap()).toList();
    return map;
  }

  @override
  String toString() {
    String filter = "";
    if (delivery) {
      if (open) {
        filter = "search=available_for_delivery:1;active:1;closed:0&searchFields=available_for_delivery:=;closed:=;active:=;&searchJoin=and";
      } else {
        filter = "search=available_for_delivery:1;active:1;&searchFields=available_for_delivery:=;active:=;";
      }
    } else if (open) {
      filter = "search=closed:${open ? 0 : 1}${';active:1;'}&searchFields=closed:=;active:=;";
    }
    return filter;
  }

  Map<String, dynamic> toQuery({Map<String, dynamic> oldQuery}) {
    Map<String, dynamic> query = {};
    String relation = '';
    if (oldQuery != null) {
      relation = oldQuery['with'] != null ? oldQuery['with'] + '.' : '';
      query['with'] = oldQuery['with'] != null ? oldQuery['with'] : null;
    }
    if (delivery) {
      if (open) {
        query['search'] = relation + 'available_for_delivery:1;closed:0;active:1;';
        query['searchFields'] = relation + 'available_for_delivery:=;closed:=;active:=;';
      } else {
        query['search'] = relation + 'available_for_delivery:1;active:1;';
        query['searchFields'] = relation + 'available_for_delivery:=;active:=;';
      }
    } else if (open) {
      query['search'] = relation + 'closed:${open ? 0 : 1};active:1;available_for_delivery:0;';
      query['searchFields'] = relation + 'closed:=;active:=;available_for_delivery:=;';
    }
    if (fields != null && fields.isNotEmpty) {
      List<Field> selectedFields = [];
      for(Field field in fields){
        if(field.selected){
          selectedFields.add(field);
        }
      }
      query['fields[]'] = selectedFields.map((element) => element.id).toList();
    }
    if (oldQuery != null) {
      if (query['search'] != null) {
        query['search'] += ';' + oldQuery['search']+';active:1;';
      } else {
        query['search'] = oldQuery['search']+';active:1;';
      }

      if (query['searchFields'] != null) {
        query['searchFields'] += ';' + oldQuery['searchFields']+';active:=;';
      } else {
        query['searchFields'] = oldQuery['searchFields']+';active:=;';
      }
//      query['search'] =
//          oldQuery['search'] != null ? (query['search']) ?? '' + ';' + oldQuery['search'] : query['search'];
//      query['searchFields'] = oldQuery['searchFields'] != null
//          ? query['searchFields'] ?? '' + ';' + oldQuery['searchFields']
//          : query['searchFields'];
    }
    query['searchJoin'] = 'and';
    return query;
  }
}
