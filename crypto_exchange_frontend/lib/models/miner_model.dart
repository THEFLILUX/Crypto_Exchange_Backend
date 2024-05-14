class MinerModel {
  MinerModel({
    required this.index,
    required this.name,
    required this.blocksMined,
    required this.totalCoins,
    required this.work,
    required this.workPercent,
  });

  factory MinerModel.fromJson(Map<String, dynamic> json) => MinerModel(
        index: json['index'] as int,
        name: json['name'] as String,
        blocksMined: json['blocksMined'] as int,
        totalCoins: (json['totalCoins'] as num).toDouble(),
        work: json['work'] as int,
        workPercent: (json['workPercent'] as num).toDouble(),
      );

  int index;
  String name;
  int blocksMined;
  double totalCoins;
  int work;
  double workPercent;

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'blocksMined': blocksMined,
        'totalCoins': totalCoins,
        'work': work,
        'workPercent': workPercent,
      };
}
