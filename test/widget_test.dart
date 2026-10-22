import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:attendance_tuonghoangthien/services/app_state.dart';
import 'package:attendance_tuonghoangthien/screens/app.dart';

void main() {
  testWidgets('Kiểm tra khởi tạo ứng dụng chấm công', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const AttendanceApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Kiểm tra tiêu đề hoặc nút trên màn hình Đăng nhập
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
