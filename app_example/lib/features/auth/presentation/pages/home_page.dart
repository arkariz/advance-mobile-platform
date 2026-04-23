import 'package:app_example/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_event.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_state.dart';
import 'package:app_example/features/auth/presentation/effect/auth_effect_registry.dart';
import 'package:app_example/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final EffectRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = buildAuthEffectRegistry(
      navigateRoutes: {
        'login': (_) => const LoginPage(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('Home'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return IconButton(
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
              );
            },
          ),
        ],
      ),
      body: EffectListener<AuthBloc, AuthState>(
        registry: _registry,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return switch (state) {
              AuthAuthenticated(:final user) => _UserProfile(user: user),
              AuthLoading(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message),
                      ],
                    ],
                  ),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${user.id}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
