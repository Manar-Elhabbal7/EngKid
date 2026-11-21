import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engkids/main.dart';
import 'package:engkids/features/home/models/activity_room.dart';

void main() {
  // flutter_animate uses repeating timers; use pump() not pumpAndSettle().

  testWidgets('App builds and shows mansion header', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EngKidsApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Haunted Mansion'), findsOneWidget);
  });

  testWidgets('Home screen shows all 5 activity room labels', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EngKidsApp()));
    await tester.pump(const Duration(milliseconds: 600));

    for (final room in kActivityRooms) {
      expect(find.text(room.label), findsOneWidget);
    }
  });

  testWidgets('Home screen shows Boo mascot', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EngKidsApp()));
    await tester.pump(const Duration(milliseconds: 500));

    // Boo's speech bubble
    expect(find.text("Hi! I'm Boo! 👋"), findsOneWidget);
  });
}
