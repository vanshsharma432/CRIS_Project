import 'dart:math';
import '../models/train_request_model.dart';

final List<String> stations = ['NDLS', 'PNBE', 'BCT', 'HWH', 'MAS', 'SBC', 'CSMT', 'LKO', 'CNB', 'JAT'];
final List<String> names = ['Amit Sharma', 'Rajesh Kumar', 'Neha Verma', 'Sonia Gupta', 'Manoj Sinha'];
final List<String> statuses = ['Initiated', 'WL', 'CNF'];
final List<String> remarks = [
  'Processed successfully',
  'Pending approval',
  'Cleared by Zonal HQ',
  'Auto-approved',
  'Cross-check needed'
];
final List<String> zones = ['NR', 'ER', 'WR', 'SR', 'CR', 'NFR'];
final List<String> divisions = ['NDLS', 'LKO', 'BPL', 'UMB', 'JBP', 'HWH'];

DateTime randomDate({bool withTime = true}) {
  final now = DateTime.now();
  final rand = Random();
  final date = now.subtract(Duration(days: rand.nextInt(90))).add(Duration(days: rand.nextInt(90)));
  return withTime ? date.add(Duration(hours: rand.nextInt(24), minutes: rand.nextInt(60))) : date;
}

final List<TrainRequest> trainRequests = List.generate(30, (index) {
  final rand = Random();
  int total = rand.nextInt(6) + 1;
  int requested = rand.nextInt(total) + 1;
  int accepted = rand.nextInt(requested) + 1;
  priority: rand.nextInt(4); // 0–3

  final startDate = randomDate();
  final journeyDate = startDate.add(Duration(days: rand.nextInt(3))); // same or 1-2 days later

  return TrainRequest(
    currentStatus: statuses[rand.nextInt(statuses.length)],
    requestedOn: randomDate(),
    sourceStation: stations[rand.nextInt(stations.length)],
    destination: stations[rand.nextInt(stations.length)],
    trainNo: rand.nextInt(90000) + 1000,
    trainStartDate: startDate,
    trainJourneyDate: journeyDate,
    pnr: rand.nextInt(900000000) + 1000000000,
    lastUpdated: randomDate(),
    totalPassengers: total,
    requestedPassengers: requested,
    acceptedPassengers: accepted,
    requestedBy: names[rand.nextInt(names.length)],
    zone: zones[rand.nextInt(zones.length)],
    division: divisions[rand.nextInt(divisions.length)],
    remarksByRailways: remarks[rand.nextInt(remarks.length)],
    isSelected: false,
    priority: rand.nextInt(6)+1,
  );
});


