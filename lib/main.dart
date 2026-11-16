import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'data/app_controller.dart';
import 'features/alerts/alert_screens.dart';
import 'features/consent/consent_screen.dart';
import 'features/dashboards/dashboard_screens.dart';
import 'features/indicators/indicator_detail_screen.dart';
import 'features/overview/overview_screen.dart';
import 'features/report/report_screen.dart';
import 'features/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(preferences)],
    child: const TerritorioVivoApp(),
  ));
}

final routerProvider = Provider<GoRouter>((ref) {
  final consent = ref.watch(appProvider.select((state) => state.consent));
  final router = GoRouter(
    redirect: (context, state) {
      final onConsentPage = state.matchedLocation == '/consent';
      if (!consent) return onConsentPage ? null : '/consent';
      return onConsentPage ? '/overview' : null;
    },
    initialLocation: '/overview',
    routes: [
      GoRoute(path: '/consent', name: 'consent', builder: (context, state) => const ConsentScreen()),
      ShellRoute(builder: (context, state, child) => AppShell(child: child), routes: [
        GoRoute(path: '/overview', name: 'overview', builder: (context, state) => const OverviewScreen()),
        GoRoute(path: '/climate', name: 'climate', builder: (context, state) => const ClimateScreen()),
        GoRoute(path: '/resources', name: 'resources', builder: (context, state) => const ResourcesScreen()),
        GoRoute(path: '/services', name: 'services', builder: (context, state) => const ServicesScreen()),
        GoRoute(path: '/alerts', name: 'alerts', builder: (context, state) => const AlertsScreen()),
        GoRoute(path: '/alerts/:id', name: 'alert-detail', builder: (context, state) => AlertDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/indicators/:category/:metric', name: 'indicator-detail', builder: (context, state) => IndicatorDetailScreen(
          category: state.pathParameters['category']!, metric: state.pathParameters['metric']!,
        )),
        GoRoute(path: '/report', name: 'report', builder: (context, state) => const ReportScreen()),
        GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
      ]),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class TerritorioVivoApp extends ConsumerWidget {
  const TerritorioVivoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    return MaterialApp.router(
      title: 'Território Vivo',
      debugShowCheckedModeBanner: false,
      theme: appTheme(dark: state.darkMode, highContrast: state.highContrast),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  static const destinations = [
    ('/overview', 'Início', Icons.dashboard_outlined, Icons.dashboard_rounded),
    ('/climate', 'Clima', Icons.thermostat_outlined, Icons.thermostat_rounded),
    ('/resources', 'Recursos', Icons.water_drop_outlined, Icons.water_drop_rounded),
    ('/services', 'Serviços', Icons.apartment_outlined, Icons.apartment_rounded),
    ('/alerts', 'Alertas', Icons.notifications_outlined, Icons.notifications_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = path.startsWith('/climate') ? 1 : path.startsWith('/resources') ? 2 :
      path.startsWith('/services') || path.startsWith('/report') ? 3 :
      path.startsWith('/alerts') ? 4 : 0;
    final showBack = path.startsWith('/indicators/') || path.startsWith('/alerts/') ||
        path == '/settings' || path == '/report';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack ? IconButton(
          tooltip: 'Voltar', icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/overview'),
        ) : const Padding(padding: EdgeInsets.only(left: 14), child: Icon(Icons.hub_outlined, color: AppPalette.teal)),
        title: Text(showBack ? (path == '/report' ? 'Nova ocorrência' : path == '/settings' ? 'Configurações' : 'Detalhamento') : 'Território Vivo'),
        actions: [
          IconButton(
            tooltip: 'Registrar ocorrência', onPressed: () => context.pushNamed('report'),
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
          IconButton(
            tooltip: 'Configurações', onPressed: () => context.pushNamed('settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (next) => context.go(destinations[next].$1),
        destinations: [
          for (final item in destinations)
            NavigationDestination(
              icon: Icon(item.$3, semanticLabel: item.$2),
              selectedIcon: Icon(item.$4), label: item.$2,
            ),
        ],
      ),
    );
  }
}
