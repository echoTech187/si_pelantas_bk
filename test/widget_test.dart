import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simonpel_bk_sekolah_mojokerto/main.dart';

void main() {
  testWidgets('SiMonpelBkSekolahApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SiMonpelBkSekolahApp()));
    expect(find.byType(SiMonpelBkSekolahApp), findsOneWidget);
  });
}
