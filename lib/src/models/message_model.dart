class MessageModel {
  String? userId;
  String? userName;
  String? messageText;
  String? createDate;

  MessageModel({
    this.userId,
    this.userName,
    this.messageText,
    this.createDate,
  });
  MessageModel.fromJson(Map<String, dynamic> json) {
    userId = json["userId"]?.toString();
    userName = json["userName"]?.toString();
    messageText = json["messageText"]?.toString();
    createDate = json["createDate"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["userId"] = userId;
    data["userName"] = userName;
    data["messageText"] = messageText;
    data["createDate"] = createDate;
    return data;
  }
}
