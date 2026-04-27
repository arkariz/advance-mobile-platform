import 'package:state_management/state_management.dart';

class AuthContext extends BlocContext<AuthContext> {
  const AuthContext({
    this.pendingEmail = '',
    this.retryCount = 0,
  });

  final String pendingEmail;
  final int retryCount;

  //==== Computed Getter ====
  bool get isLockedOut => retryCount > 3;

  //==== Setter ====
  AuthContext setPendingEmail(String email) => copyWith(pendingEmail: email);
  AuthContext incrementRetryCount() => copyWith(retryCount: retryCount + 1);

  @override
  AuthContext copyWith({
    String? pendingEmail,
    int? retryCount,
  }) => AuthContext(
    pendingEmail: pendingEmail ?? this.pendingEmail,
    retryCount: retryCount ?? this.retryCount,
  );
      
  @override
  List<Object?> get props => [pendingEmail, retryCount];
}
