import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wb_warehouse/features/reviews/dto/response/review_dto.dart';

part 'reviews_dto.g.dart';

@immutable
@JsonSerializable(createToJson: false)
class ReviewsDto {
  final List<ReviewDto> feedbacks;

  const ReviewsDto({
    required this.feedbacks,
  });

  factory ReviewsDto.fromJson(Map<String, dynamic> json) => _$ReviewsDtoFromJson(json);
}