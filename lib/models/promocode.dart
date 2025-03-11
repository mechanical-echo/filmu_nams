class PromocodeModel {
  String name;
  String id;
  double? amount;
  int? percents;

  PromocodeModel({
    required this.id,
    required this.amount,
    required this.name,
    required this.percents,
  });

  factory PromocodeModel.fromMap(Map<String, dynamic> map, String id) {
    return PromocodeModel(
      id: id,
      amount: double.tryParse(map['amount'].toString()),
      name: map['name'] ?? '',
      percents: map['percents'],
    );
  }
}
