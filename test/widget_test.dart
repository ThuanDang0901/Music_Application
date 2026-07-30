import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/module/data/repositories/music_repositories_impl.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_music.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';
import 'package:flutter_application_1/module/data/services/jamendo_api_service.dart';

void main() {
  final apiservice = JamendoApiService();


  testWidgets('App loads and shows LoginPage when not authenticated',
      (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final repository = MusicRepositoriesImpl(apiService: apiservice);
    final getMusicUseCase = GetMusicUseCase(repository);

    await tester.pumpWidget(
      ToastificationWrapper(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  MusicCubit(getMusicUseCase: getMusicUseCase),
            ),
            BlocProvider(create: (context) => ThemeCubit()),
          ],
          child: const MyApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsAtLeastNWidgets(1));
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
