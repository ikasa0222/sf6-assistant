import 'package:flutter/material.dart';

class PlayTimeItem {
  final int contentType;
  final String name;
  final int seconds;
  final int percentage;

  const PlayTimeItem({
    required this.contentType,
    required this.name,
    required this.seconds,
    this.percentage = 0,
  });

  String get formattedDuration {
    if (seconds <= 0) return '0分';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? "$minutes分" : ""}';
    }
    return '$minutes分钟';
  }

  Color get color {
    switch (contentType) {
      case 1:
        return const Color(0xFF01BCB5);
      case 2:
        return const Color(0xFFEA2743);
      case 3:
        return const Color(0xFFFB8A10);
      case 4:
        return const Color(0xFF6200E3);
      case 5:
        return const Color(0xFF0A65D8);
      case 6:
        return const Color(0xFFF157BC);
      case 7:
        return const Color(0xFF691C2A);
      case 8:
        return const Color(0xFFD9D9D9);
      case 9:
        return const Color(0xFFCC73FF);
      case 10:
        return const Color(0xFF007F44);
      default:
        return const Color(0xFF00ADB5);
    }
  }

  PlayTimeItem copyWith({
    int? contentType,
    String? name,
    int? seconds,
    int? percentage,
  }) {
    return PlayTimeItem(
      contentType: contentType ?? this.contentType,
      name: name ?? this.name,
      seconds: seconds ?? this.seconds,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toJson() => {
    'content_type': contentType,
    'name': name,
    'seconds': seconds,
    'percentage': percentage,
  };

  factory PlayTimeItem.fromJson(Map<String, dynamic> json) {
    return PlayTimeItem(
      contentType: json['content_type'] is num
          ? (json['content_type'] as num).toInt()
          : (int.tryParse(json['content_type']?.toString() ?? '') ?? 0),
      name: (json['name'] ?? json['content_type_name'] ?? '').toString(),
      seconds: json['seconds'] is num
          ? (json['seconds'] as num).toInt()
          : (json['play_time'] is num
              ? (json['play_time'] as num).toInt()
              : (int.tryParse(json['seconds']?.toString() ?? json['play_time']?.toString() ?? '') ?? 0)),
      percentage: json['percentage'] is num
          ? (json['percentage'] as num).toInt()
          : (int.tryParse(json['percentage']?.toString() ?? '') ?? 0),
    );
  }
}

class PlayTimeModel {
  final List<PlayTimeItem> items;
  final int totalSeconds;
  final int rankedMatches;
  final int casualMatches;
  final int customRoomMatches;
  final int battleHubMatches;
  final int targetClearCount;
  final int totalPlayPoint;

  final String ranked;
  final String casual;
  final String customRoom;
  final String battleHub;
  final String training;
  final String worldTour;
  final String total;

  const PlayTimeModel({
    this.items = const [],
    this.totalSeconds = 0,
    this.rankedMatches = 0,
    this.casualMatches = 0,
    this.customRoomMatches = 0,
    this.battleHubMatches = 0,
    this.targetClearCount = 0,
    this.totalPlayPoint = 0,
    this.ranked = '--',
    this.casual = '--',
    this.customRoom = '--',
    this.battleHub = '--',
    this.training = '--',
    this.worldTour = '--',
    this.total = '--',
  });

  bool get hasData =>
      items.isNotEmpty ||
      totalSeconds > 0 ||
      rankedMatches > 0 ||
      (ranked != '--' && ranked.isNotEmpty) ||
      (customRoom != '--' && customRoom.isNotEmpty) ||
      (battleHub != '--' && battleHub.isNotEmpty) ||
      (casual != '--' && casual.isNotEmpty) ||
      (training != '--' && training.isNotEmpty) ||
      (worldTour != '--' && worldTour.isNotEmpty) ||
      (total != '--' && total.isNotEmpty);
  bool get isEstimated => false;

  List<PlayTimeItem> get topModes => items.take(3).toList();

  String get formattedTotalDuration {
    if (totalSeconds > 0) {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      if (hours > 0) {
        return '$hours小时${minutes > 0 ? "$minutes分" : ""}';
      }
      return '$minutes分钟';
    }
    if (total != '--' && total.isNotEmpty) return total;
    return '--';
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total_seconds': totalSeconds,
    'ranked_matches': rankedMatches,
    'casual_matches': casualMatches,
    'custom_room_matches': customRoomMatches,
    'battle_hub_matches': battleHubMatches,
    'target_clear_count': targetClearCount,
    'total_play_point': totalPlayPoint,
    'ranked': ranked,
    'casual': casual,
    'customRoom': customRoom,
    'battleHub': battleHub,
    'training': training,
    'worldTour': worldTour,
    'total': total,
    'isEstimated': isEstimated,
  };

  factory PlayTimeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const PlayTimeModel();

    List<PlayTimeItem> parsedItems = [];
    if (json['items'] is List) {
      for (final e in json['items']) {
        if (e is Map<String, dynamic>) {
          parsedItems.add(PlayTimeItem.fromJson(e));
        } else if (e is Map) {
          parsedItems.add(PlayTimeItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final totalSec = json['total_seconds'] is num
        ? (json['total_seconds'] as num).toInt()
        : (int.tryParse(json['total_seconds']?.toString() ?? '') ?? 0);
    final rankedM = json['ranked_matches'] is num ? (json['ranked_matches'] as num).toInt() : 0;
    final casualM = json['casual_matches'] is num ? (json['casual_matches'] as num).toInt() : 0;
    final roomM = json['custom_room_matches'] is num ? (json['custom_room_matches'] as num).toInt() : 0;
    final hubM = json['battle_hub_matches'] is num ? (json['battle_hub_matches'] as num).toInt() : 0;
    final targetM = json['target_clear_count'] is num ? (json['target_clear_count'] as num).toInt() : 0;
    final pointM = json['total_play_point'] is num ? (json['total_play_point'] as num).toInt() : 0;

    return PlayTimeModel(
      items: parsedItems,
      totalSeconds: totalSec,
      rankedMatches: rankedM,
      casualMatches: casualM,
      customRoomMatches: roomM,
      battleHubMatches: hubM,
      targetClearCount: targetM,
      totalPlayPoint: pointM,
      ranked: _formatDuration(json['ranked'] ?? json['play_time_ranked'] ?? json['ranked_play_time'] ?? json['rank']),
      casual: _formatDuration(json['casual'] ?? json['play_time_casual'] ?? json['casual_play_time']),
      customRoom: _formatDuration(json['customRoom'] ?? json['custom_room'] ?? json['room'] ?? json['play_time_room'] ?? json['play_time_custom_room'] ?? json['custom_room_play_time']),
      battleHub: _formatDuration(json['battleHub'] ?? json['battle_hub'] ?? json['hub'] ?? json['play_time_hub'] ?? json['play_time_battle_hub'] ?? json['battle_hub_play_time']),
      training: _formatDuration(json['training'] ?? json['practice'] ?? json['play_time_training'] ?? json['training_play_time'] ?? json['practice_play_time']),
      worldTour: _formatDuration(json['worldTour'] ?? json['world_tour'] ?? json['play_time_world_tour'] ?? json['world_tour_play_time'] ?? json['tour']),
      total: _formatDuration(json['total'] ?? json['total_play_time'] ?? json['play_time_total'] ?? json['all']),
    );
  }

  static String _formatDuration(dynamic val) {
    if (val == null) return '--';
    if (val is String) {
      final s = val.trim();
      if (s.isEmpty || s == '0' || s == '0:00' || s == '00:00' || s == '0秒') return '--';
      return s;
    }
    if (val is Map) {
      final h = val['hours'] ?? val['hour'] ?? 0;
      final m = val['minutes'] ?? val['minute'] ?? val['min'] ?? 0;
      final s = val['seconds'] ?? val['second'] ?? val['sec'] ?? 0;
      final hInt = (h is num) ? h.toInt() : (int.tryParse(h.toString()) ?? 0);
      final mInt = (m is num) ? m.toInt() : (int.tryParse(m.toString()) ?? 0);
      final sInt = (s is num) ? s.toInt() : (int.tryParse(s.toString()) ?? 0);
      if (hInt > 0) return '$hInt小时${mInt > 0 ? "$mInt分" : ""}';
      if (mInt > 0) return '$mInt分钟';
      if (sInt > 0) return '$sInt秒';
      return '--';
    }
    if (val is num) {
      final sec = val.toInt();
      if (sec <= 0) return '--';
      final hours = sec ~/ 3600;
      final minutes = (sec % 3600) ~/ 60;
      if (hours > 0) {
        return '$hours小时${minutes > 0 ? "$minutes分" : ""}';
      } else if (minutes > 0) {
        return '$minutes分钟';
      }
      return '$sec秒';
    }
    return val.toString();
  }
}
