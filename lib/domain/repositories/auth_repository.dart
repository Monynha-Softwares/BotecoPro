abstract class AuthRepository<TUser> {
  Future<TUser?> getCurrentUser();
  Future<TUser> signIn({required String email, required String password});
  Future<TUser> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
