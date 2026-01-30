import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for customer operations via Supabase.
class CustomerRemoteDataSource {
  CustomerRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetch all customers, optionally filtered by updatedAt for incremental sync.
  /// Returns raw JSON data from Supabase.
  Future<List<Map<String, dynamic>>> fetchCustomers({DateTime? since}) async {
    print('[CustomerRemoteDS] fetchCustomers called, since=$since');
    print('[CustomerRemoteDS] auth.uid=${_client.auth.currentUser?.id}');

    var query = _client.from('customers').select();

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    print('[CustomerRemoteDS] Query returned ${response.length} customers');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch customers assigned to a specific RM.
  Future<List<Map<String, dynamic>>> fetchCustomersByRm(
    String rmId, {
    DateTime? since,
  }) async {
    var query = _client.from('customers').select().eq('assigned_rm_id', rmId);

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single customer by ID.
  Future<Map<String, dynamic>?> fetchCustomerById(String id) async {
    final response = await _client
        .from('customers')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Create a new customer on the server.
  /// Returns the created customer data.
  Future<Map<String, dynamic>> createCustomer(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('customers')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing customer on the server.
  /// Returns the updated customer data.
  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('customers')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete a customer on the server.
  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Upsert a customer (insert or update based on ID).
  Future<Map<String, dynamic>> upsertCustomer(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('customers')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  /// Get count of customers assigned to an RM.
  Future<int> getCustomerCountByRm(String rmId) async {
    final response = await _client
        .from('customers')
        .select('id')
        .eq('assigned_rm_id', rmId)
        .isFilter('deleted_at', null)
        .count();
    return response.count;
  }
}

/// Remote data source for key person operations via Supabase.
class KeyPersonRemoteDataSource {
  KeyPersonRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetch all key persons, optionally filtered by updatedAt.
  Future<List<Map<String, dynamic>>> fetchKeyPersons({DateTime? since}) async {
    var query = _client.from('key_persons').select();

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch key persons for a specific customer.
  Future<List<Map<String, dynamic>>> fetchKeyPersonsByCustomer(
    String customerId,
  ) async {
    final response = await _client
        .from('key_persons')
        .select()
        .eq('customer_id', customerId)
        .eq('owner_type', 'CUSTOMER')
        .isFilter('deleted_at', null)
        .order('is_primary', ascending: false)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch key persons for a specific HVC.
  Future<List<Map<String, dynamic>>> fetchKeyPersonsByHvc(String hvcId) async {
    final response = await _client
        .from('key_persons')
        .select()
        .eq('hvc_id', hvcId)
        .eq('owner_type', 'HVC')
        .isFilter('deleted_at', null)
        .order('is_primary', ascending: false)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch key persons for a specific broker.
  Future<List<Map<String, dynamic>>> fetchKeyPersonsByBroker(
    String brokerId,
  ) async {
    final response = await _client
        .from('key_persons')
        .select()
        .eq('broker_id', brokerId)
        .eq('owner_type', 'BROKER')
        .isFilter('deleted_at', null)
        .order('is_primary', ascending: false)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Create a new key person.
  Future<Map<String, dynamic>> createKeyPerson(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('key_persons')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing key person.
  Future<Map<String, dynamic>> updateKeyPerson(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('key_persons')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete a key person.
  Future<void> deleteKeyPerson(String id) async {
    await _client.from('key_persons').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Upsert a key person.
  Future<Map<String, dynamic>> upsertKeyPerson(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('key_persons')
        .upsert(data)
        .select()
        .single();
    return response;
  }
}
