import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_manager/view/widgets/app_shimmer_loader.dart';

void main() {
  testWidgets('AppCircularLoaderScreen renders properly with white shimmer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppShimmerLoader(),
      ),
    );

    expect(find.byType(AppShimmerLoader), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);
    expect(find.byType(ShimmerCircle), findsWidgets);
  });

  testWidgets('AppCircularLoader renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCircularLoader(
            size: 200,
            showPercentage: true,
          ),
        ),
      ),
    );

    expect(find.byType(AppCircularLoader), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('ShimmerListLoading renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShimmerListLoading(itemCount: 3),
        ),
      ),
    );

    expect(find.byType(ShimmerListLoading), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);
  });
}
