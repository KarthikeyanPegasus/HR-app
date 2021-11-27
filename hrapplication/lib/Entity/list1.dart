import 'package:json_annotation/json_annotation.dart';

part 'list1.g.dart';

@JsonSerializable()
class List1 {
  @JsonKey(name: "result")
  late List list1;

  List1();
  factory List1.fromJson(Map<String, dynamic> json) => _$List1FromJson(json);
  Map<String, dynamic> toJson() => _$List1ToJson(this);
}
