class BedRetrievalModel {
  final String id;          // e.g. “bed1”
  final String roomNumber;  // e.g. “101”
  final String status;      // “available” | “not_available”

  BedRetrievalModel({
    required this.id,
    required this.roomNumber,
    required this.status,
  });

  factory BedRetrievalModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return BedRetrievalModel(
      id: id,
      roomNumber: data['roomNumber'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
