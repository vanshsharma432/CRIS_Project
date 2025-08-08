import 'package:intl/intl.dart';

class TrainRequest {
  final int totalPassengers;
  final int requestedPassengers;
  final int acceptedPassengers;
  final String currentStatus;
  final String remarksByRailways;
  final DateTime requestedOn;
  final DateTime trainStartDate;
  final DateTime trainJourneyDate;
  final String sourceStation;
  final String destination;
  final String requestedBy;
  final String zone;
  final String division;
  final DateTime lastUpdated;
  final int pnr;
  final int trainNo;
  final String seatClass;
  final bool isSelected;
  final String eqRequestNo;
  final int priority;

  TrainRequest({
    required this.totalPassengers,
    required this.requestedPassengers,
    required this.acceptedPassengers,
    required this.currentStatus,
    required this.remarksByRailways,
    required this.requestedOn,
    required this.trainStartDate,
    required this.trainJourneyDate,
    required this.sourceStation,
    required this.destination,
    required this.requestedBy,
    required this.zone,
    required this.division,
    required this.lastUpdated,
    required this.pnr,
    required this.trainNo,
    required this.seatClass,
    required this.isSelected,
    required this.eqRequestNo,
    required this.priority,
  });

  TrainRequest copyWith({
    int? totalPassengers,
    int? requestedPassengers,
    int? acceptedPassengers,
    String? currentStatus,
    String? remarksByRailways,
    DateTime? requestedOn,
    DateTime? trainStartDate,
    DateTime? trainJourneyDate,
    String? sourceStation,
    String? destination,
    String? requestedBy,
    String? zone,
    String? division,
    DateTime? lastUpdated,
    int? pnr,
    int? trainNo,
    String? seatClass,
    bool? isSelected,
    String? eqRequestNo,
    int? priority,
  }) {
    return TrainRequest(
      totalPassengers: totalPassengers ?? this.totalPassengers,
      requestedPassengers: requestedPassengers ?? this.requestedPassengers,
      acceptedPassengers: acceptedPassengers ?? this.acceptedPassengers,
      currentStatus: currentStatus ?? this.currentStatus,
      remarksByRailways: remarksByRailways ?? this.remarksByRailways,
      requestedOn: requestedOn ?? this.requestedOn,
      trainStartDate: trainStartDate ?? this.trainStartDate,
      trainJourneyDate: trainJourneyDate ?? this.trainJourneyDate,
      sourceStation: sourceStation ?? this.sourceStation,
      destination: destination ?? this.destination,
      requestedBy: requestedBy ?? this.requestedBy,
      zone: zone ?? this.zone,
      division: division ?? this.division,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      pnr: pnr ?? this.pnr,
      trainNo: trainNo ?? this.trainNo,
      seatClass: seatClass ?? this.seatClass,
      isSelected: isSelected ?? this.isSelected,
      eqRequestNo: eqRequestNo ?? this.eqRequestNo,
      priority: priority ?? this.priority,
    );
  }

  factory TrainRequest.fromJson(Map<String, dynamic> json) {
    // Handles non-ISO formatted dates from API
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateFormat("dd-MM-yyyy hh:mm:ss a").parse(dateStr);
      } catch (_) {
        return DateTime.tryParse(dateStr) ?? DateTime.now();
      }
    }

    return TrainRequest(
      totalPassengers: json['totalPassengers'] ?? 0,
      requestedPassengers: json['requestPassengers'] ?? 0,
      acceptedPassengers: json['acceptedPassengers'] ?? 0,
      currentStatus: json['currentStatus'] ?? '',
      remarksByRailways: json['remarks'] ?? '',
      requestedOn: parseDate(json['createdOn']),
      trainStartDate: parseDate(json['trainStartDate']),
      trainJourneyDate: parseDate(json['jrnyDate']),
      sourceStation: json['boardingStation'] ?? '',     // Not in response
      destination: json['destination'] ?? '',         // Not in response
      requestedBy: json['requestedBy'] ?? '',         // Not in response
      zone: json['assignedToZone'] ?? '',                       // May be set manually
      division: json['assignedToDiv'] ?? '',               // May be set manually
      lastUpdated: DateTime.now(),                    // Not in response
      pnr: int.tryParse(json['pnr'].toString()) ?? 0,
      trainNo: int.tryParse(json['trainNo'].toString()) ?? 0,
      seatClass: json['journeyClass'] ?? '',             // Not in response
      isSelected: false,
      eqRequestNo: json['eqRequestNo'] ?? '',
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPassengers': totalPassengers,
    'requestedPassengers': requestedPassengers,
    'acceptedPassengers': acceptedPassengers,
    'currentStatus': currentStatus,
    'remarksByRailways': remarksByRailways,
    'requestedOn': requestedOn.toIso8601String(),
    'trainStartDate': trainStartDate.toIso8601String(),
    'trainJourneyDate': trainJourneyDate.toIso8601String(),
    'sourceStation': sourceStation,
    'destination': destination,
    'requestedBy': requestedBy,
    'zone': zone,
    'division': division,
    'lastUpdated': lastUpdated.toIso8601String(),
    'pnr': pnr,
    'trainNo': trainNo,
    'seatClass': seatClass,
    'isSelected': isSelected,
    'eqRequestNo': eqRequestNo,
    'priority': priority,
  };
}
