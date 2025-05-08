// ignore_for_file: non_constant_identifier_names, file_names

class UserAskQuestionModel {
  late String Question;
  late String? UserId;
  late String? dateTime;
  late String? Status;
  late String? answer;

  UserAskQuestionModel(this.Question, this.UserId, this.dateTime, this.Status,this.answer);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'Question': Question,
    'UserId': UserId,
    'DateTime': dateTime,
    'Status': Status,
    'Answer':answer
  };

  factory UserAskQuestionModel.fromJson(Map<String, dynamic> v) {
    return UserAskQuestionModel(
      v["Question"] ?? "",
      v["UserId"] ?? "",
      v["DateTime"] ?? "",
      v["Status"] ?? "",
      v["Answer"] ?? ""
    );
  }
}
