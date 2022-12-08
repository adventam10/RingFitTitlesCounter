import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'ringfit_title.freezed.dart';
part 'ringfit_title.g.dart';

@freezed
class RingfitTitle with _$RingfitTitle {
  const factory RingfitTitle({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'skill') required int skill,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'rank1') required int rank1,
    @JsonKey(name: 'rank2') required int rank2,
    @JsonKey(name: 'rank3') required int rank3,
    @JsonKey(name: 'rank4') required int rank4
  }) = _RingfitTitle;

  factory RingfitTitle.fromJson(Map<String, dynamic> json) => _$RingfitTitleFromJson(json);
}