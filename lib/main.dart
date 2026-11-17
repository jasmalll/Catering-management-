import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/catering_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_dashboard_page.dart';
import 'screens/works_page.dart';
import 'screens/expenses_page.dart';
import 'screens/summary_page.dart';
import 'screens/calendar_page.dart';
import 'theme/caterpro_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('works_box');
  await Hive.openBox('expenses_box');
  await Hive.openBox('settings_box');
  try {
    await NotificationService.init();
  } catch (error) {
    debugPrint('Notification init error: $error');
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CateringProvider()..loadDataFromStorage()),
      ChangeNotifierProvider(create: (_) => CaterProThemeController()..load()),
    ],
    child: const CaterProApp(),
  ));
}

class CaterProApp extends StatelessWidget {
  const CaterProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaterProThemeController>(
      builder: (context, controller, _) => MaterialApp(
        title: 'CaterPro',
        debugShowCheckedModeBanner: false,
        themeMode: controller.themeMode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const MainNavigationScreen(),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    const forest = Color(0xFF075E43);
    const mint = Color(0xFFB8F2CF);
    final background = dark ? const Color(0xFF0C1512) : const Color(0xFFF4F7F3);
    final surface = dark ? const Color(0xFF17231E) : Colors.white;
    final foreground = dark ? const Color(0xFFF1F7F2) : const Color(0xFF17251E);
    final border = dark ? const Color(0xFF2B3B33) : const Color(0xFFE3EAE4);
    final scheme = ColorScheme.fromSeed(seedColor: forest, brightness: brightness, surface: surface).copyWith(
      primary: dark ? mint : forest,
      secondary: const Color(0xFFE8AE58),
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(bodyColor: foreground, displayColor: foreground),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: foreground, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.65),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: dark ? 0 : 1,
        shadowColor: Colors.black.withOpacity(dark ? 0 : .045),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: border)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1D2B24) : const Color(0xFFF7F9F6),
        hintStyle: TextStyle(color: dark ? const Color(0xFF9BAAA1) : const Color(0xFF89968D), fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: scheme.primary, foregroundColor: dark ? const Color(0xFF102219) : Colors.white, elevation: 4),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: dark ? const Color(0xFF102219) : Colors.white,
        minimumSize: const Size(0, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      )),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [HomeDashboardPage(), WorksPage(), ExpensesPage(), SummaryPage(), CalendarPage()];
  static const _items = <({IconData icon, IconData active, String label})>[
    (icon: Icons.space_dashboard_outlined, active: Icons.space_dashboard_rounded, label: 'Home'),
    (icon: Icons.event_note_outlined, active: Icons.event_note_rounded, label: 'Works'),
    (icon: Icons.receipt_long_outlined, active: Icons.receipt_long_rounded, label: 'Expenses'),
    (icon: Icons.insights_outlined, active: Icons.insights_rounded, label: 'Reports'),
    (icon: Icons.calendar_month_outlined, active: Icons.calendar_month_rounded, label: 'Calendar'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? .22 : .075), blurRadius: 30, offset: const Offset(0, 9))],
          ),
          child: Row(children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == _currentIndex;
            final activeColor = theme.colorScheme.primary;
            return Expanded(child: Semantics(
              button: true,
              selected: selected,
              label: item.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(21),
                onTap: () => setState(() => _currentIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: selected ? activeColor.withOpacity(dark ? .18 : .09) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedScale(scale: selected ? 1.13 : 1, duration: const Duration(milliseconds: 260), curve: Curves.easeOutBack,
                      child: Icon(selected ? item.active : item.icon, size: 22, color: selected ? activeColor : theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 5),
                    AnimatedDefaultTextStyle(duration: const Duration(milliseconds: 220), style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w900 : FontWeight.w600, color: selected ? activeColor : theme.colorScheme.onSurfaceVariant), child: Text(item.label)),
                  ]),
                ),
              ),
            ));
          })),
        ),
      ),
    );
  }
}
