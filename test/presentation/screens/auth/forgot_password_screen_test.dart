import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/presentation/screens/auth/forgot_password_screen.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuthRepo.dispose();
  });

  group('ForgotPasswordScreen', () {
    testWidgets('renders forgot password form elements correctly',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows email validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email format',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows success state after successful password reset request',
        (tester) async {
      fakeAuthRepo.shouldPasswordResetSucceed = true;

      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Should show success state
      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Return to Login'), findsOneWidget);
    });

    testWidgets('shows error snackbar on password reset failure',
        (tester) async {
      fakeAuthRepo.shouldPasswordResetSucceed = false;

      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Password reset failed'), findsOneWidget);
    });

    testWidgets('can try again after success state', (tester) async {
      fakeAuthRepo.shouldPasswordResetSucceed = true;

      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      // First request
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Verify success state
      expect(find.text('Check Your Email'), findsOneWidget);

      // Tap try again
      await tester.tap(find.text("Didn't receive email? Try again"));
      await tester.pumpAndSettle();

      // Should be back to form
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('has app bar with title', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('form is scrollable', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ForgotPasswordScreen(),
          fakeAuthRepository: fakeAuthRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
