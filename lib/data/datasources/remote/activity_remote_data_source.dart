import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/utils/date_time_utils.dart';

/// Remote data source for activity operations via Supabase.
class ActivityRemoteDataSource {
  ActivityRemoteDataSource(this._client);

  final SupabaseClient _client;
  final _log = AppLogger.instance;

  static const String _tableName = 'activities';
  static const String _photosTableName = 'activity_photos';
  static const String _storageBucket = 'activity-photos';

  // ==========================================
  // Fetch Operations
  // ==========================================

  /// Fetch all activities, optionally filtered by updatedAt for incremental sync.
  /// Returns raw JSON data from Supabase.
  Future<List<Map<String, dynamic>>> fetchActivities({DateTime? since}) async {
    var query = _client.from(_tableName).select();

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch activities for a specific user.
  Future<List<Map<String, dynamic>>> fetchActivitiesByUser(
    String userId, {
    DateTime? since,
  }) async {
    var query = _client.from(_tableName).select().eq('user_id', userId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch activities for a specific customer.
  Future<List<Map<String, dynamic>>> fetchActivitiesByCustomer(
    String customerId, {
    DateTime? since,
  }) async {
    var query = _client
        .from(_tableName)
        .select()
        .eq('customer_id', customerId)
        .eq('object_type', 'CUSTOMER');

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch activities for a specific HVC.
  Future<List<Map<String, dynamic>>> fetchActivitiesByHvc(
    String hvcId, {
    DateTime? since,
  }) async {
    var query = _client
        .from(_tableName)
        .select()
        .eq('hvc_id', hvcId)
        .eq('object_type', 'HVC');

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch activities for a specific broker.
  Future<List<Map<String, dynamic>>> fetchActivitiesByBroker(
    String brokerId, {
    DateTime? since,
  }) async {
    var query = _client
        .from(_tableName)
        .select()
        .eq('broker_id', brokerId)
        .eq('object_type', 'BROKER');

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single activity by ID.
  Future<Map<String, dynamic>?> fetchActivityById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  // ==========================================
  // CRUD Operations
  // ==========================================

  /// Create a new activity on the server.
  /// Returns the created activity data.
  Future<Map<String, dynamic>> createActivity(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_tableName)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing activity on the server.
  /// Returns the updated activity data.
  Future<Map<String, dynamic>> updateActivity(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete an activity on the server.
  Future<void> deleteActivity(String id) async {
    await _client.from(_tableName).update({
      'deleted_at': DateTime.now().toUtcIso8601(),
    }).eq('id', id);
  }

  /// Upsert an activity (insert or update based on ID).
  Future<Map<String, dynamic>> upsertActivity(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_tableName)
        .upsert(data)
        .select()
        .single();
    return response;
  }

  // ==========================================
  // Photo Operations
  // ==========================================

  /// Fetch photos for an activity.
  Future<List<Map<String, dynamic>>> fetchActivityPhotos(
    String activityId,
  ) async {
    final response = await _client
        .from(_photosTableName)
        .select()
        .eq('activity_id', activityId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Upload a photo to Supabase Storage.
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadPhoto(
    String activityId,
    String localPath,
    String fileId,
  ) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('File not found: $localPath');
    }

    final bytes = await file.readAsBytes();
    final extension = localPath.split('.').last.toLowerCase();
    final storagePath = 'activities/$activityId/$fileId.$extension';

    await _client.storage.from(_storageBucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage.from(_storageBucket).getPublicUrl(storagePath);
    return publicUrl;
  }

  /// Upload a photo from bytes (for web support).
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadPhotoBytes(
    String activityId,
    Uint8List bytes,
    String fileId, {
    String extension = 'jpg',
  }) async {
    final storagePath = 'activities/$activityId/$fileId.$extension';
    
    // Map file extension to proper MIME type (jpg -> jpeg)
    final mimeType = extension == 'jpg' ? 'jpeg' : extension;

    await _client.storage.from(_storageBucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$mimeType',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage.from(_storageBucket).getPublicUrl(storagePath);
    _log.debug('activity.remote | Uploaded photo bytes -> $publicUrl');
    return publicUrl;
  }

  /// Create a photo record in the database.
  Future<Map<String, dynamic>> createPhotoRecord(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_photosTableName)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Delete a photo from storage and database.
  Future<void> deletePhoto(String photoId, String photoUrl) async {
    // Extract storage path from URL
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      // Find the index after 'activity-photos' bucket
      final bucketIndex = pathSegments.indexOf('activity-photos');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_storageBucket).remove([storagePath]);
      }
    } catch (e) {
      _log.error('activity.remote | Error deleting photo from storage: $e');
    }

    // Delete database record
    await _client.from(_photosTableName).delete().eq('id', photoId);
  }

  // ==========================================
  // Statistics
  // ==========================================

  /// Get count of activities for a customer.
  Future<int> getActivityCountByCustomer(String customerId) async {
    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('customer_id', customerId)
        .eq('object_type', 'CUSTOMER')
        .isFilter('deleted_at', null)
        .count();
    return response.count;
  }

  /// Get count of activities by status for a user.
  Future<int> getActivityCountByStatus(String userId, String status) async {
    final response = await _client
        .from(_tableName)
        .select('id')
        .eq('user_id', userId)
        .eq('status', status)
        .isFilter('deleted_at', null)
        .count();
    return response.count;
  }

  // ==========================================
  // Audit Log Operations
  // ==========================================

  static const String _auditLogsTableName = 'activity_audit_logs';

  /// Create a single audit log entry in remote database.
  Future<Map<String, dynamic>> createAuditLog(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_auditLogsTableName)
        .insert(data)
        .select()
        .single();
    _log.debug('activity.remote | Created audit log ${data['id']}');
    return response;
  }

  /// Upsert multiple audit logs (for batch sync).
  Future<void> upsertAuditLogs(List<Map<String, dynamic>> logs) async {
    if (logs.isEmpty) return;
    
    await _client.from(_auditLogsTableName).upsert(logs);
    _log.debug('activity.remote | Synced ${logs.length} audit logs');
  }

  /// Fetch audit logs for an activity from remote.
  Future<List<Map<String, dynamic>>> fetchAuditLogs(String activityId) async {
    final response = await _client
        .from(_auditLogsTableName)
        .select()
        .eq('activity_id', activityId)
        .order('performed_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
