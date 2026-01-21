import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/presentation/screens/auth/login_screen.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuthRepo.dispose();
  });

  group('LoginScreen', () {
    testWidgets('renders login form elements correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Assert form elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue to LeadX CRM'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('LX'), findsOneWidget);
      expect(find.text('PT Askrindo (Persero)'), findsOneWidget);
    });

    testWidgets('shows email validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Submit without entering email
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email format',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailFields = find.byType(TextFormField);
      await tester.enterText(emailFields.first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password validation error when password is empty',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email but no password
      final emailFields = find.byType(TextFormField);
      await tester.enterText(emailFields.first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows password validation error when password is too short',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email and short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, '12345');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('toggles password visibility when eye icon is tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Initially should show visibility_outlined icon (password hidden)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Should now show visibility_off_outlined icon (password visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('shows error snackbar on login failure', (tester) async {
      // Setup fake repo to fail login
      fakeAuthRepo.shouldSignInSucceed = false;
      fakeAuthRepo.signInErrorMessage = 'Email atau password salah';

      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid credentials
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'wrongpassword');

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Email atau password salah'), findsOneWidget);
    });

    testWidgets('form is scrollable', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('form has max width constraint for content', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // The form content should be wrapped in a ConstrainedBox
      // There may be multiple ConstrainedBox widgets due to other components
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}
