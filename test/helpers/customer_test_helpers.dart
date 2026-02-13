import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/core/errors/result.dart';
import 'package:leadx_crm/data/dtos/customer_dtos.dart';
import 'package:leadx_crm/data/dtos/master_data_dtos.dart';
import 'package:leadx_crm/data/services/gps_service.dart';
import 'package:leadx_crm/domain/entities/customer.dart';
import 'package:leadx_crm/domain/entities/key_person.dart';
import 'package:leadx_crm/domain/repositories/customer_repository.dart';
import 'package:leadx_crm/presentation/providers/customer_providers.dart';
import 'package:leadx_crm/presentation/providers/gps_providers.dart';
import 'package:leadx_crm/presentation/providers/master_data_providers.dart';

/// Convert ownerType string to KeyPersonOwnerType enum.
KeyPersonOwnerType _parseOwnerType(String ownerType) {
  return KeyPersonOwnerTypeExtension.fromString(ownerType);
}

// ============================================
// FAKE CUSTOMER REPOSITORY
// ============================================

/// A fake implementation of [CustomerRepository] for testing purposes.
class FakeCustomerRepository implements CustomerRepository {
  final _customersController = StreamController<List<Customer>>.broadcast();
  List<Customer> _customers = [];
  bool _hasEmittedInitial = false;

  // Control test behavior
  bool shouldCreateSucceed = true;
  bool shouldUpdateSucceed = true;
  bool shouldDeleteSucceed = true;
  String? errorMessage;

  // Track mutations for assertions
  CustomerCreateDto? lastCreatedCustomerDto;
  CustomerUpdateDto? lastUpdatedCustomerDto;
  String? lastUpdatedCustomerId;
  String? lastDeletedCustomerId;
  Customer? lastCreatedCustomer;
  Customer? lastUpdatedCustomer;

  // Search results
  List<Customer>? searchResults;

  /// Sets the customers to be returned by the stream.
  void setCustomers(List<Customer> customers) {
    _customers = customers;
    _customersController.add(customers);
    _hasEmittedInitial = true;
  }

  /// Adds a single customer to the list.
  void addCustomer(Customer customer) {
    _customers = [..._customers, customer];
    _customersController.add(_customers);
    _hasEmittedInitial = true;
  }

  @override
  Stream<List<Customer>> watchAllCustomers() {
    // Return a stream that immediately emits current state then listens to updates
    return Stream.multi((controller) {
      // Emit current state immediately
      controller.add(_customers);

      // Then listen to future updates
      final subscription = _customersController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    return _customers.where((c) => c.id == id).firstOrNull;
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return watchAllCustomers().map(
      (customers) => customers.where((c) => c.id == id).firstOrNull,
    );
  }

  @override
  Stream<List<Customer>> watchCustomersPaginated({
    required int limit,
    String? searchQuery,
  }) {
    return watchAllCustomers().map((customers) {
      var filtered = customers;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filtered = customers
            .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
      return filtered.take(limit).toList();
    });
  }

  @override
  Future<int> getCustomerCount({String? searchQuery}) async {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return _customers
          .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .length;
    }
    return _customers.length;
  }

  @override
  Future<Result<Customer>> createCustomer(CustomerCreateDto dto) async {
    await Future.delayed(const Duration(milliseconds: 50));
    lastCreatedCustomerDto = dto;

    if (!shouldCreateSucceed) {
      return Result.failure(DatabaseFailure(message: errorMessage ?? 'Failed to create customer'));
    }

    final customer = createTestCustomer(
      name: dto.name,
      address: dto.address ?? 'Test Address',
      provinceId: dto.provinceId,
      cityId: dto.cityId,
      companyTypeId: dto.companyTypeId,
      ownershipTypeId: dto.ownershipTypeId,
      industryId: dto.industryId,
      latitude: dto.latitude,
      longitude: dto.longitude,
    );
    lastCreatedCustomer = customer;
    addCustomer(customer);
    return Result.success(customer);
  }

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CustomerUpdateDto dto,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    lastUpdatedCustomerId = id;
    lastUpdatedCustomerDto = dto;

    if (!shouldUpdateSucceed) {
      return Result.failure(DatabaseFailure(message: errorMessage ?? 'Failed to update customer'));
    }

    final existingIndex = _customers.indexWhere((c) => c.id == id);
    if (existingIndex == -1) {
      return Result.failure(DatabaseFailure(message: 'Customer not found'));
    }

    final existing = _customers[existingIndex];
    final updated = existing.copyWith(
      name: dto.name ?? existing.name,
      address: dto.address ?? existing.address,
      provinceId: dto.provinceId ?? existing.provinceId,
      cityId: dto.cityId ?? existing.cityId,
      companyTypeId: dto.companyTypeId ?? existing.companyTypeId,
      ownershipTypeId: dto.ownershipTypeId ?? existing.ownershipTypeId,
      industryId: dto.industryId ?? existing.industryId,
      phone: dto.phone ?? existing.phone,
      email: dto.email ?? existing.email,
    );

    lastUpdatedCustomer = updated;
    _customers[existingIndex] = updated;
    _customersController.add(_customers);
    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    lastDeletedCustomerId = id;

    if (!shouldDeleteSucceed) {
      return Result.failure(DatabaseFailure(message: errorMessage ?? 'Failed to delete customer'));
    }

    _customers = _customers.where((c) => c.id != id).toList();
    _customersController.add(_customers);
    return const Result.success(null);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (searchResults != null) {
      return searchResults!;
    }
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.code.toLowerCase().contains(query.toLowerCase()) ||
            c.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Customer>> getCustomersByAssignedRm(String rmId) async {
    return _customers.where((c) => c.assignedRmId == rmId).toList();
  }

  @override
  Future<List<Customer>> getPendingSyncCustomers() async {
    return _customers.where((c) => c.isPendingSync).toList();
  }

  @override
  Future<List<KeyPerson>> getCustomerKeyPersons(String customerId) async {
    return [];
  }

  @override
  Future<Result<KeyPerson>> addKeyPerson(KeyPersonDto dto) async {
    return Result.success(KeyPerson(
      id: 'kp-${DateTime.now().millisecondsSinceEpoch}',
      ownerType: _parseOwnerType(dto.ownerType),
      name: dto.name,
      customerId: dto.customerId,
      brokerId: dto.brokerId,
      hvcId: dto.hvcId,
      position: dto.position,
      department: dto.department,
      phone: dto.phone,
      email: dto.email,
      isPrimary: dto.isPrimary,
      isActive: true,
      notes: dto.notes,
      createdBy: 'test-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<KeyPerson>> updateKeyPerson(
    String id,
    KeyPersonDto dto,
  ) async {
    return Result.success(KeyPerson(
      id: id,
      ownerType: _parseOwnerType(dto.ownerType),
      name: dto.name,
      customerId: dto.customerId,
      brokerId: dto.brokerId,
      hvcId: dto.hvcId,
      position: dto.position,
      department: dto.department,
      phone: dto.phone,
      email: dto.email,
      isPrimary: dto.isPrimary,
      isActive: true,
      notes: dto.notes,
      createdBy: 'test-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<void>> deleteKeyPerson(String id) async {
    return const Result.success(null);
  }

  @override
  Future<KeyPerson?> getPrimaryKeyPerson(String customerId) async {
    return null;
  }

  @override
  Stream<List<KeyPerson>> watchCustomerKeyPersons(String customerId) {
    return Stream.value(<KeyPerson>[]);
  }

  @override
  Stream<KeyPerson?> watchPrimaryKeyPerson(String customerId) {
    return Stream.value(null);
  }

  @override
  Future<Result<int>> syncFromRemote({DateTime? since}) async {
    return const Result.success(0);
  }

  @override
  Future<Result<int>> syncKeyPersonsFromRemote({DateTime? since}) async {
    return const Result.success(0);
  }

  @override
  Future<void> markAsSynced(String id, DateTime syncedAt) async {}

  void dispose() {
    _customersController.close();
  }
}

// ============================================
// FAKE GPS SERVICE
// ============================================

/// A fake implementation of [GpsService] for testing purposes.
class FakeGpsService extends GpsService {
  GpsPosition? mockPosition;
  LocationPermissionStatus mockPermissionStatus = LocationPermissionStatus.granted;
  bool shouldFail = false;
  String? failureMessage;

  /// Sets a mock position to return.
  void setPosition(double latitude, double longitude, {double accuracy = 10.0}) {
    mockPosition = GpsPosition(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );
  }

  /// Clears the mock position (simulates no location available).
  void clearPosition() {
    mockPosition = null;
  }

  @override
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    return mockPermissionStatus;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return mockPermissionStatus != LocationPermissionStatus.serviceDisabled;
  }

  @override
  Future<GpsPosition?> getCurrentPosition() async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (shouldFail) {
      return null;
    }

    if (mockPermissionStatus != LocationPermissionStatus.granted) {
      return null;
    }

    return mockPosition;
  }

  @override
  Future<GpsPosition?> getLastKnownPosition() async {
    return mockPosition;
  }
}

// ============================================
// FACTORY FUNCTIONS
// ============================================

/// Creates a test customer with customizable properties.
Customer createTestCustomer({
  String? id,
  String? code,
  String name = 'Test Customer',
  String address = 'Test Address',
  String provinceId = 'province-1',
  String cityId = 'city-1',
  String companyTypeId = 'company-type-1',
  String ownershipTypeId = 'ownership-type-1',
  String industryId = 'industry-1',
  String assignedRmId = 'rm-1',
  String? phone,
  String? email,
  double? latitude,
  double? longitude,
  bool isActive = true,
  bool isPendingSync = false,
  String? provinceName,
  String? cityName,
  String? companyTypeName,
  String? ownershipTypeName,
  String? industryName,
}) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return Customer(
    id: id ?? 'customer-$timestamp',
    code: code ?? 'CUST-$timestamp',
    name: name,
    address: address,
    provinceId: provinceId,
    cityId: cityId,
    companyTypeId: companyTypeId,
    ownershipTypeId: ownershipTypeId,
    industryId: industryId,
    assignedRmId: assignedRmId,
    createdBy: 'test-user',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    phone: phone,
    email: email,
    latitude: latitude,
    longitude: longitude,
    isActive: isActive,
    isPendingSync: isPendingSync,
    provinceName: provinceName ?? 'Test Province',
    cityName: cityName ?? 'Test City',
    companyTypeName: companyTypeName ?? 'PT',
    ownershipTypeName: ownershipTypeName ?? 'Swasta',
    industryName: industryName ?? 'Manufacturing',
  );
}

/// Creates test provinces.
List<ProvinceDto> createTestProvinces() {
  return [
    const ProvinceDto(id: 'province-1', code: 'JKT', name: 'DKI Jakarta', isActive: true),
    const ProvinceDto(id: 'province-2', code: 'JBR', name: 'Jawa Barat', isActive: true),
    const ProvinceDto(id: 'province-3', code: 'JTG', name: 'Jawa Tengah', isActive: true),
  ];
}

/// Creates test cities for a province.
List<CityDto> createTestCities({String? provinceId}) {
  final pId = provinceId ?? 'province-1';
  return [
    CityDto(id: 'city-1', code: 'JKP', name: 'Jakarta Pusat', provinceId: pId, isActive: true),
    CityDto(id: 'city-2', code: 'JKS', name: 'Jakarta Selatan', provinceId: pId, isActive: true),
    CityDto(id: 'city-3', code: 'JKT', name: 'Jakarta Timur', provinceId: pId, isActive: true),
  ];
}

/// Creates test company types.
List<CompanyTypeDto> createTestCompanyTypes() {
  return [
    const CompanyTypeDto(id: 'company-type-1', code: 'PT', name: 'PT', sortOrder: 1, isActive: true),
    const CompanyTypeDto(id: 'company-type-2', code: 'CV', name: 'CV', sortOrder: 2, isActive: true),
    const CompanyTypeDto(id: 'company-type-3', code: 'UD', name: 'UD', sortOrder: 3, isActive: true),
  ];
}

/// Creates test ownership types.
List<OwnershipTypeDto> createTestOwnershipTypes() {
  return [
    const OwnershipTypeDto(id: 'ownership-type-1', code: 'SWT', name: 'Swasta', sortOrder: 1, isActive: true),
    const OwnershipTypeDto(id: 'ownership-type-2', code: 'BUMN', name: 'BUMN', sortOrder: 2, isActive: true),
    const OwnershipTypeDto(id: 'ownership-type-3', code: 'BUMD', name: 'BUMD', sortOrder: 3, isActive: true),
  ];
}

/// Creates test industries.
List<IndustryDto> createTestIndustries() {
  return [
    const IndustryDto(id: 'industry-1', code: 'MFG', name: 'Manufacturing', sortOrder: 1, isActive: true),
    const IndustryDto(id: 'industry-2', code: 'TRD', name: 'Trading', sortOrder: 2, isActive: true),
    const IndustryDto(id: 'industry-3', code: 'SVC', name: 'Services', sortOrder: 3, isActive: true),
  ];
}

// ============================================
// TEST APP WRAPPER
// ============================================

/// Creates a [ProviderScope] configured for customer testing.
Widget createCustomerTestApp({
  required Widget child,
  FakeCustomerRepository? fakeCustomerRepository,
  FakeGpsService? fakeGpsService,
  List<Customer>? initialCustomers,
  List<ProvinceDto>? provinces,
  List<CityDto>? cities,
  List<CompanyTypeDto>? companyTypes,
  List<OwnershipTypeDto>? ownershipTypes,
  List<IndustryDto>? industries,
  Customer? existingCustomer,
  bool? shouldCreateSucceed,
  bool? shouldUpdateSucceed,
  String? errorMessage,
  List<Override> additionalOverrides = const [],
}) {
  final customerRepo = fakeCustomerRepository ?? FakeCustomerRepository();
  final gpsService = fakeGpsService ?? FakeGpsService();

  // Configure fake repository
  if (shouldCreateSucceed != null) {
    customerRepo.shouldCreateSucceed = shouldCreateSucceed;
  }
  if (shouldUpdateSucceed != null) {
    customerRepo.shouldUpdateSucceed = shouldUpdateSucceed;
  }
  if (errorMessage != null) {
    customerRepo.errorMessage = errorMessage;
  }

  // Set initial customers
  if (initialCustomers != null) {
    customerRepo.setCustomers(initialCustomers);
  }
  if (existingCustomer != null) {
    customerRepo.setCustomers([existingCustomer]);
  }

  // Master data
  final testProvinces = provinces ?? createTestProvinces();
  final testCities = cities ?? createTestCities();
  final testCompanyTypes = companyTypes ?? createTestCompanyTypes();
  final testOwnershipTypes = ownershipTypes ?? createTestOwnershipTypes();
  final testIndustries = industries ?? createTestIndustries();

  return ProviderScope(
    overrides: [
      // Customer repository
      customerRepositoryProvider.overrideWithValue(customerRepo),

      // Customer list stream
      customerListStreamProvider.overrideWith((ref) {
        return customerRepo.watchAllCustomers();
      }),

      // Customer search
      customerSearchProvider.overrideWith((ref, query) async {
        return customerRepo.searchCustomers(query);
      }),

      // Customer detail (for edit mode)
      customerDetailProvider.overrideWith((ref, id) {
        return customerRepo.watchCustomerById(id);
      }),

      // Customer form notifier
      customerFormNotifierProvider.overrideWith((ref) {
        return CustomerFormNotifier(customerRepo);
      }),

      // GPS service
      gpsServiceProvider.overrideWithValue(gpsService),

      // GPS position
      currentGpsPositionProvider.overrideWith((ref) async {
        return gpsService.getCurrentPosition();
      }),

      // Provinces
      provincesStreamProvider.overrideWith((ref) {
        return Stream.value(testProvinces);
      }),

      // Cities by province
      citiesByProvinceProvider.overrideWith((ref, provinceId) {
        if (provinceId == null || provinceId.isEmpty) {
          return Stream.value(<CityDto>[]);
        }
        return Stream.value(testCities.where((c) => c.provinceId == provinceId).toList());
      }),

      // Company types
      companyTypesStreamProvider.overrideWith((ref) {
        return Stream.value(testCompanyTypes);
      }),

      // Ownership types
      ownershipTypesStreamProvider.overrideWith((ref) {
        return Stream.value(testOwnershipTypes);
      }),

      // Industries
      industriesStreamProvider.overrideWith((ref) {
        return Stream.value(testIndustries);
      }),

      ...additionalOverrides,
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a test app with navigation support for testing navigation.
Widget createCustomerTestAppWithNavigation({
  required Widget child,
  FakeCustomerRepository? fakeCustomerRepository,
  FakeGpsService? fakeGpsService,
  List<Customer>? initialCustomers,
  List<Override> additionalOverrides = const [],
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final customerRepo = fakeCustomerRepository ?? FakeCustomerRepository();
  final gpsService = fakeGpsService ?? FakeGpsService();

  if (initialCustomers != null) {
    customerRepo.setCustomers(initialCustomers);
  }

  final testProvinces = createTestProvinces();
  final testCities = createTestCities();
  final testCompanyTypes = createTestCompanyTypes();
  final testOwnershipTypes = createTestOwnershipTypes();
  final testIndustries = createTestIndustries();

  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(customerRepo),
      customerListStreamProvider.overrideWith((ref) {
        return customerRepo.watchAllCustomers();
      }),
      customerSearchProvider.overrideWith((ref, query) async {
        return customerRepo.searchCustomers(query);
      }),
      customerDetailProvider.overrideWith((ref, id) {
        return customerRepo.watchCustomerById(id);
      }),
      customerFormNotifierProvider.overrideWith((ref) {
        return CustomerFormNotifier(customerRepo);
      }),
      gpsServiceProvider.overrideWithValue(gpsService),
      currentGpsPositionProvider.overrideWith((ref) async {
        return gpsService.getCurrentPosition();
      }),
      provincesStreamProvider.overrideWith((ref) {
        return Stream.value(testProvinces);
      }),
      citiesByProvinceProvider.overrideWith((ref, provinceId) {
        if (provinceId == null || provinceId.isEmpty) {
          return Stream.value(<CityDto>[]);
        }
        return Stream.value(testCities.where((c) => c.provinceId == provinceId).toList());
      }),
      companyTypesStreamProvider.overrideWith((ref) {
        return Stream.value(testCompanyTypes);
      }),
      ownershipTypesStreamProvider.overrideWith((ref) {
        return Stream.value(testOwnershipTypes);
      }),
      industriesStreamProvider.overrideWith((ref) {
        return Stream.value(testIndustries);
      }),
      ...additionalOverrides,
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      home: child,
      onGenerateRoute: (settings) {
        // Handle navigation for testing
        if (settings.name?.startsWith('/home/customers/') == true) {
          final id = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('Customer Detail: $id')),
              body: Center(child: Text('Customer ID: $id')),
            ),
          );
        }
        if (settings.name == '/customers/create') {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Create Customer Screen')),
            ),
          );
        }
        return null;
      },
    ),
  );
}
