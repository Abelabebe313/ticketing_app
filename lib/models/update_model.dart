class Updates {
  bool? status;
  String? message;
  Null errors;
  Data? data;

  Updates({this.status, this.message, this.errors, this.data});

  Updates.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    errors = json['errors'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['errors'] = this.errors;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<StationInfo>? stationInfo;
  List<DestinationList>? destinationList;
  List<TariffInfo>? tariffInfo;
  List<VehicleList>? vehicleList;

  Data(
      {this.stationInfo,
      this.destinationList,
      this.tariffInfo,
      this.vehicleList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['station_info'] != null) {
      stationInfo = <StationInfo>[];
      json['station_info'].forEach((v) {
        stationInfo!.add(StationInfo.fromJson(v));
      });
    }
    if (json['destination_list'] != null) {
      destinationList = <DestinationList>[];
      json['destination_list'].forEach((v) {
        destinationList!.add(DestinationList.fromJson(v));
      });
    }
    if (json['tariff_info'] != null) {
      tariffInfo = <TariffInfo>[];
      json['tariff_info'].forEach((v) {
        tariffInfo!.add(TariffInfo.fromJson(v));
      });
    }
    if (json['vehicle_list'] != null) {
      vehicleList = <VehicleList>[];
      json['vehicle_list'].forEach((v) {
        vehicleList!.add(VehicleList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.stationInfo != null) {
      data['station_info'] = this.stationInfo!.map((v) => v.toJson()).toList();
    }
    if (this.destinationList != null) {
      data['destination_list'] =
          this.destinationList!.map((v) => v.toJson()).toList();
    }
    if (this.tariffInfo != null) {
      data['tariff_info'] = this.tariffInfo!.map((v) => v.toJson()).toList();
    }
    if (this.vehicleList != null) {
      data['vehicle_list'] = this.vehicleList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StationInfo {
  String? id;
  String? name;
  String? location;
  String? departure;
  String? defaultLang;

  StationInfo(
      {this.id, this.name, this.location, this.departure, this.defaultLang});

  StationInfo.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
    location = json['location'];
    departure = json['departure'];
    defaultLang = json['default_lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['location'] = this.location;
    data['departure'] = this.departure;
    data['default_lang'] = this.defaultLang;
    return data;
  }
}

class DestinationList {
  String? id;
  String? stationId;
  String destination;
  String? distance;

  DestinationList({
    this.id,
    this.stationId,
    required this.destination,
    this.distance,
  });

  factory DestinationList.fromJson(Map<String, dynamic> json) {
    return DestinationList(
      id: json['id']?.toString(),
      stationId: json['station_id']?.toString(),
      destination: json['destination'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['station_id'] = stationId;
    data['destination'] = destination;
    data['distance'] = distance;
    return data;
  }
}

class TariffInfo {
  String? stationId;
  String? destinationId;
  String? tariff;
  String? level_1;
  String? level_2;
  String? level_3;
  String? is_lessthan_16;
  String? level_1_mini;
  String? level_2_mini;
  String? level_3_mini;
  String? updatedDate;

  TariffInfo({
    this.stationId,
    this.destinationId,
    this.tariff,
    this.level_1,
    this.level_2,
    this.level_3,
    this.is_lessthan_16,
    this.level_1_mini,
    this.level_2_mini,
    this.level_3_mini,
    this.updatedDate,
  });

  TariffInfo.fromJson(Map<String, dynamic> json) {
    stationId = json['station_id']?.toString();
    destinationId = json['destination_id']?.toString();
    tariff = json['tariff']?.toString();
    level_1 = json['level_1']?.toString();
    level_2 = json['level_2']?.toString();
    level_3 = json['level_3']?.toString();
    is_lessthan_16 = json['is_lessthan_16'];
    level_1_mini = json['level_1_mini']?.toString();
    level_2_mini = json['level_2_mini']?.toString();
    level_3_mini = json['level_3_mini']?.toString();
    updatedDate = json['updated_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['station_id'] = this.stationId;
    data['destination_id'] = this.destinationId;
    data['tariff'] = this.tariff;
    data['level_1'] = this.level_1;
    data['level_2'] = this.level_2;
    data['level_3'] = this.level_3;
    data['is_lessthan_16'] = this.is_lessthan_16;
    data['level_1_mini'] = this.level_1_mini;
    data['level_2_mini'] = this.level_2_mini;
    data['level_3_mini'] = this.level_3_mini;
    data['updated_date'] = this.updatedDate;
    return data;
  }
}

class VehicleList {
  String? id;
  String? stationId;
  String? associationName;
  String? level;
  String? plateNo;
  String? type;
  String? capacity;
  String? date;

  VehicleList(
      {this.id,
      this.stationId,
      this.associationName,
      this.level,
      this.plateNo,
      this.type,
      this.capacity,
      this.date});

  factory VehicleList.fromJson(Map<String, dynamic> json) {
    return VehicleList(
      id: json['id']?.toString(),
      stationId: json['station_id']?.toString(),
      associationName: json['association_name'],
      level: json['level'],
      plateNo: json['plate_no'],
      type: json['type'],
      capacity: json['capacity']?.toString(),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['station_id'] = this.stationId;
    data['association_name'] = this.associationName;
    data['level'] = this.level;
    data['plate_no'] = this.plateNo;
    data['type'] = this.type;
    data['capacity'] = this.capacity;
    data['date'] = this.date;
    return data;
  }
}
