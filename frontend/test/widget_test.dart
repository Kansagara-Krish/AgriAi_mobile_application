import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/app_provider.dart';
import 'package:frontend/services/storage_service.dart';

void main() {
  testWidgets('AgriAI app initialization smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(storageService: storageService),
        child: const AgriAiApp(),
      ),
    );

    // Allow splash timer to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(AgriAiApp), findsOneWidget);
  });
}
