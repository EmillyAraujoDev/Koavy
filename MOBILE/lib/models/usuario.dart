/// Representa um usuário do sistema para fins de autenticação.
class Usuario {
  final String _usuario;
  final String _senha;

  Usuario(this._usuario, this._senha);

  String get usuario => _usuario;
  String get senha => _senha;

  /// Autentica o usuário comparando com as credenciais digitadas.
  bool autenticar(String user, String pass) {
    return _usuario == user && _senha == pass;
  }
}
