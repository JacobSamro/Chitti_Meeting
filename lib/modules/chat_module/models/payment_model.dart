class PaymentModel {
  String? link;
  String? buttonText;
  String? description;
  String? title;
  String? topLabel;

  PaymentModel(
      {this.link,
      this.buttonText,
      this.description,
      this.title,
      this.topLabel});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    buttonText = json['buttonText'];
    description = json['description'];
    title = json['title'];
    topLabel = json['topLabel'];
  }
}
