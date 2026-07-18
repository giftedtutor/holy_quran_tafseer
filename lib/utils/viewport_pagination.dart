import 'package:flutter/material.dart';

class ViewportSegment {
  const ViewportSegment({
    required this.builder,
    required this.estimatedHeight,
  });

  final WidgetBuilder builder;
  final double estimatedHeight;
}

double measureTextHeight({
  required String text,
  required TextStyle style,
  required double maxWidth,
  TextDirection textDirection = TextDirection.rtl,
}) {
  if (text.isEmpty) return 0;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    maxLines: null,
  )..layout(maxWidth: maxWidth);
  return painter.height;
}

List<String> paginateText({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required double maxHeight,
  TextDirection textDirection = TextDirection.rtl,
}) {
  if (text.isEmpty) return [];
  if (measureTextHeight(
        text: text,
        style: style,
        maxWidth: maxWidth,
        textDirection: textDirection,
      ) <=
      maxHeight) {
    return [text];
  }

  final words = text.split(RegExp(r'\s+'));
  final chunks = <String>[];
  var buffer = StringBuffer();

  for (final word in words) {
    if (word.isEmpty) continue;
    final candidate = buffer.isEmpty ? word : '${buffer.toString()} $word';
    final height = measureTextHeight(
      text: candidate,
      style: style,
      maxWidth: maxWidth,
      textDirection: textDirection,
    );

    if (height > maxHeight && buffer.isNotEmpty) {
      chunks.add(buffer.toString());
      buffer = StringBuffer(word);
    } else {
      if (buffer.isEmpty) {
        buffer.write(word);
      } else {
        buffer.write(' $word');
      }
    }
  }

  if (buffer.isNotEmpty) {
    chunks.add(buffer.toString());
  }

  return chunks.isEmpty ? [text] : chunks;
}

List<List<ViewportSegment>> packSegmentsIntoViewportPages({
  required List<ViewportSegment> segments,
  required double maxHeight,
}) {
  if (segments.isEmpty) return [[]];

  final pages = <List<ViewportSegment>>[];
  var current = <ViewportSegment>[];
  var used = 0.0;

  for (final segment in segments) {
    final segmentHeight = segment.estimatedHeight;
    if (current.isNotEmpty && used + segmentHeight > maxHeight) {
      pages.add(current);
      current = [segment];
      used = segmentHeight;
      continue;
    }

    if (segmentHeight > maxHeight && current.isEmpty) {
      pages.add([segment]);
      current = [];
      used = 0;
      continue;
    }

    current.add(segment);
    used += segmentHeight;
  }

  if (current.isNotEmpty) {
    pages.add(current);
  }

  return pages.isEmpty ? [[]] : pages;
}
