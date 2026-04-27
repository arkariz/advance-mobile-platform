import 'package:app_example/features/home/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EffectListener<HomeBloc, HomeState>(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: () => context.read<HomeBloc>().add(const HomeLogoutRequested()),
          ),
        ),
      ),
    );
  }
}
