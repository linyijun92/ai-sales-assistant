import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'speech_input_screen.dart';
import 'customer_list_screen.dart';
import 'reports_screen.dart';

part 'home_screen.g.dart';

@riverpod
class HomeScreen extends _$HomeScreen {
  int _selectedIndex = 0;

  @override
  int build() => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    state = index;
  }
}

class HomeScreenWidget extends ConsumerWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeScreenProvider);

    final List<Widget> pages = const [
      VoiceInputScreen(),
      CustomerListScreen(),
      ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助销助手'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(homeScreenProvider.notifier).selectIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic),
            selectedIcon: Icon(Icons.mic_rounded),
            label: '语音输入',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            selectedIcon: Icon(Icons.people_rounded),
            label: '客户列表',
          ),
          NavigationDestination(
            icon: Icon(Icons.description),
            selectedIcon: Icon(Icons.description_rounded),
            label: '报告',
          ),
        ],
      ),
    );
  }
}
