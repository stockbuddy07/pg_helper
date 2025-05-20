class RoomFormModel {
  final String roomNumber;
  final String roomSize;
  final String roomSharing;

  RoomFormModel({
    required this.roomNumber,
    required this.roomSize,
    required this.roomSharing,
  });

  Map<String, dynamic> toMap() {
    return {
      'RoomNumber': roomNumber,
      'RoomSize': roomSize,
      'RoomSharing': roomSharing,
    };
  }
}
