import 'package:json_annotation/json_annotation.dart';

part 'flag.g.dart';

@JsonSerializable()
class Flag {
  final String reason;
  final String? comment; // Optional comment for "Other" reason

  Flag({required this.reason, this.comment});

  factory Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);

  Map<String, dynamic> toJson() => _$FlagToJson(this);
}
