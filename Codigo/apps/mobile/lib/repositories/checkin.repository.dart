import 'package:app/domain/checkin/checkin.dart';
import 'package:app/services/checkin/checkin_remote_service.dart';
import 'package:app/database/checkin/checkin.dao.dart';
import 'package:app/services/connectivity_service.dart';

class CheckinRepository {
  final CheckinRemoteService remote;
  final CheckinDao local;
  final ConnectivityService net;

  CheckinRepository({
    required this.remote,
    required this.local,
    required this.net,
  });

  Future<List<Checkin>> getFeed() async {
    final isOnline = await net.isOnline();

    if (isOnline) {
      try {
        final data = await remote.getFeed();
        await local.cacheFeed(data); 
        return data;
      } catch (e) {
      }
    }
    
    return local.getFeed();
  }

  Future<void> createCheckin({
    required String groupId,
    required String title,
    String? description,
    String? image,
  }) async {
    await remote.createCheckin(
      groupId: groupId, 
      title: title, 
      description: description, 
      image: image
    );
  }

  Future<void> toggleLike(String checkinId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await remote.unlikeCheckin(checkinId);
    } else {
      await remote.likeCheckin(checkinId);
    }
  }
}