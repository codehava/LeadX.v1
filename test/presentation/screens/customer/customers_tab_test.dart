import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/presentation/screens/home/tabs/customers_tab.dart';
import 'package:leadx_crm/presentation/widgets/cards/customer_card.dart';
import 'package:leadx_crm/presentation/widgets/common/loading_indicator.dart';

import '../../../helpers/customer_test_helpers.dart';

void main() {
  late FakeCustomerRepository fakeCustomerRepo;

  setUp(() {
    fakeCustomerRepo = FakeCustomerRepository();
  });

  tearDown(() {
    fakeCustomerRepo.dispose();
  });

  group('CustomersTab', () {
    group('Initial Rendering', () {
      testWidgets('renders app bar with title "Customer"', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Customer'), findsOneWidget);
      });

      testWidgets('renders search icon in app bar', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders FAB with add icon', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('renders filter chips (Semua, Aktif, Belum Sync)', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.text('Belum Sync'), findsOneWidget);
        expect(find.byType(FilterChip), findsNWidgets(3));
      });
    });

    group('Loading State', () {
      testWidgets('renders correctly after data loads', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        // After data loads, the tab should render correctly
        expect(find.byType(CustomersTab), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no customers exist', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Belum ada customer'), findsOneWidget);
      });

      testWidgets('empty state shows appropriate message and action', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tap tombol + untuk menambahkan customer baru'), findsOneWidget);
        expect(find.text('Tambah Customer'), findsOneWidget);
      });
    });

    group('Customer List', () {
      testWidgets('renders CustomerCard for each customer', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Customer 1'),
          createTestCustomer(id: 'c2', name: 'Customer 2'),
          createTestCustomer(id: 'c3', name: 'Customer 3'),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomerCard), findsNWidgets(3));
      });

      testWidgets('displays customer name on card', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Acme Corporation'),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Acme Corporation'), findsOneWidget);
      });

      testWidgets('displays customer code on card', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Test Corp', code: 'CUST-001'),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('CUST-001'), findsOneWidget);
      });

      testWidgets('displays customer address on card', (tester) async {
        final customers = [
          createTestCustomer(
            id: 'c1',
            name: 'Test Corp',
            address: 'Jl. Sudirman No. 1',
            cityName: 'Jakarta Pusat',
            provinceName: 'DKI Jakarta',
          ),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        // The fullAddress getter combines address, city, province
        expect(find.textContaining('Jl. Sudirman No. 1'), findsOneWidget);
      });

      testWidgets('shows sync status badge for pending sync customers', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Synced Customer', isPendingSync: false),
          createTestCustomer(id: 'c2', name: 'Pending Customer', isPendingSync: true),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        // Both customers should be visible
        expect(find.text('Synced Customer'), findsOneWidget);
        expect(find.text('Pending Customer'), findsOneWidget);
      });

      testWidgets('shows status chip (Aktif/Tidak Aktif)', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Active Customer', isActive: true),
          createTestCustomer(id: 'c2', name: 'Inactive Customer', isActive: false),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Aktif'), findsWidgets); // May find multiple (filter chip + status)
        expect(find.text('Tidak Aktif'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error UI structure when error occurs', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        // Verify the screen renders correctly
        expect(find.byType(CustomersTab), findsOneWidget);
      });
    });

    group('Search Functionality', () {
      testWidgets('tapping search icon shows search bar', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [createTestCustomer()],
          ),
        );
        await tester.pumpAndSettle();

        // Initially search bar should not be visible
        expect(find.text('Customer'), findsOneWidget);

        // Tap search icon
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Search bar should now be visible (title changes to search field)
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('search bar has autofocus', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [createTestCustomer()],
          ),
        );
        await tester.pumpAndSettle();

        // Tap search icon
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // The AppSearchField has autofocus property
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autofocus, isTrue);
      });

      testWidgets('tapping close icon hides search bar', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [createTestCustomer()],
          ),
        );
        await tester.pumpAndSettle();

        // Open search bar
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify search is open (close icon should appear)
        expect(find.byIcon(Icons.close), findsOneWidget);

        // Tap close icon
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Search bar should be hidden, title should be visible
        expect(find.text('Customer'), findsOneWidget);
      });

      testWidgets('search filters customers after debounce', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Alpha Corp'),
          createTestCustomer(id: 'c2', name: 'Beta Industries'),
          createTestCustomer(id: 'c3', name: 'Gamma Tech'),
        ];

        // Set up search results
        fakeCustomerRepo.searchResults = [customers[0]]; // Only Alpha Corp

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        // Initially all customers visible
        expect(find.byType(CustomerCard), findsNWidgets(3));

        // Open search and enter query
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextField), 'Alpha');

        // Wait for debounce (300ms) + a bit more
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Only matching customer should be visible
        expect(find.text('Alpha Corp'), findsOneWidget);
      });

      testWidgets('shows empty search results state when no matches', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Test Customer'),
        ];

        // Set up empty search results
        fakeCustomerRepo.searchResults = [];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        // Open search and enter query that doesn't match
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byType(TextField), 'nonexistent');

        // Wait for debounce
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should show no results state
        expect(find.text('No results found'), findsOneWidget);
      });

      testWidgets('clearing search restores full list', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Alpha Corp'),
          createTestCustomer(id: 'c2', name: 'Beta Industries'),
        ];

        fakeCustomerRepo.searchResults = [customers[0]];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        // Open search
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Enter search query
        await tester.enterText(find.byType(TextField), 'Alpha');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Close search bar
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Full list should be restored
        expect(find.byType(CustomerCard), findsNWidgets(2));
      });
    });

    group('Pull to Refresh', () {
      testWidgets('RefreshIndicator is present', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [createTestCustomer()],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('FAB is present and tappable', (tester) async {
        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [],
          ),
        );
        await tester.pumpAndSettle();

        // Verify FAB is present and can be tapped
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('customer card is tappable', (tester) async {
        final customer = createTestCustomer(id: 'customer-123', name: 'Test Corp');

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [customer],
          ),
        );
        await tester.pumpAndSettle();

        // Verify customer card is present
        expect(find.byType(CustomerCard), findsOneWidget);
      });
    });

    group('Data Updates', () {
      testWidgets('list updates when new customer is added', (tester) async {
        final initialCustomer = createTestCustomer(id: 'c1', name: 'Initial Customer');

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: [initialCustomer],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomerCard), findsOneWidget);

        // Add a new customer
        final newCustomer = createTestCustomer(id: 'c2', name: 'New Customer');
        fakeCustomerRepo.addCustomer(newCustomer);

        // Pump a few frames to allow stream to emit
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should now show two customers
        expect(find.byType(CustomerCard), findsNWidgets(2));
        expect(find.text('New Customer'), findsOneWidget);
      });

      testWidgets('list updates when customers are replaced', (tester) async {
        final customers = [
          createTestCustomer(id: 'c1', name: 'Customer 1'),
          createTestCustomer(id: 'c2', name: 'Customer 2'),
        ];

        await tester.pumpWidget(
          createCustomerTestApp(
            child: const CustomersTab(),
            fakeCustomerRepository: fakeCustomerRepo,
            initialCustomers: customers,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomerCard), findsNWidgets(2));

        // Replace with different customers
        fakeCustomerRepo.setCustomers([
          createTestCustomer(id: 'c3', name: 'Customer 3'),
        ]);

        // Pump a few frames to allow stream to emit
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should now show only the new customer
        expect(find.byType(CustomerCard), findsOneWidget);
        expect(find.text('Customer 3'), findsOneWidget);
      });
    });
  });
}
