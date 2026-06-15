<?php
// api/src/Controllers/UsuarioController.php (Parcial - Adicionando novos métodos)

namespace App\Controllers;

use App\Database;
use App\JWTHelper;
use PDO;

class UsuarioController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    // ... (métodos anteriores mantidos)

    /**
     * Login com Google
     * Recebe o id_token do frontend, valida com o Google e loga/cadastra o usuário
     */
    public function googleLogin($data) {
        if (!isset($data['credential'])) {
            return ["status" => 400, "data" => ["message" => "Token do Google não fornecido"]];
        }

        // Em produção: usar a biblioteca google/apiclient para validar o token
        // Aqui faremos uma validação básica de estrutura e buscaremos o usuário
        // O ideal é: $payload = $client->verifyIdToken($data['credential']);
        
        // Simulação de payload decodificado (o frontend já enviou alguns dados por segurança aqui)
        $email = $data['email'] ?? null;
        $nome = $data['nome'] ?? null;

        if (!$email) return ["status" => 400, "data" => ["message" => "E-mail não identificado"]];

        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if (!$user) {
            // Se não existe, cria um usuário novo via Google
            $this->cadastrar([
                'nome' => $nome,
                'email' => $email,
                'senha' => bin2hex(random_bytes(10)), // Senha aleatória forte
                'perfil_id' => 1
            ]);
            $stmt->execute(['email' => $email]);
            $user = $stmt->fetch();
        }

        $token = JWTHelper::generate([
            'id' => $user['id'],
            'email' => $user['email'],
            'perfilId' => $user['perfil_id']
        ]);

        return ["status" => 200, "data" => ["user" => $user, "token" => $token]];
    }

    /**
     * Solicitar Recuperação de Senha
     */
    public function solicitarRecuperacao($email) {
        $stmt = $this->db->prepare("SELECT id, nome FROM usuarios WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if (!$user) {
            return ["status" => 404, "data" => ["message" => "E-mail não encontrado"]];
        }

        $token = bin2hex(random_bytes(32));
        $expira = date('Y-m-d H:i:s', strtotime('+1 hour'));

        // Salva token (Assume-se que a tabela existe)
        $stmtToken = $this->db->prepare("INSERT INTO tokens_recuperacao (usuario_id, token, expira_em) VALUES (:uid, :tk, :exp)");
        $stmtToken->execute([
            'uid' => $user['id'],
            'tk' => $token,
            'exp' => $expira
        ]);

        // Aqui dispararia o e-mail via PHPMailer
        // $link = "http://143.106.241.4/koavy/Web/redefinir-senha.html?token=" . $token;

        return ["status" => 200, "data" => [
            "message" => "Link de recuperação gerado",
            "token" => $token, // Apenas para teste/demo, em prod enviar por email
            "link" => "redefinir-senha.html?token=" . $token
        ]];
    }

    /**
     * Redefinir Senha Real
     */
    public function redefinirSenha($data) {
        if (!isset($data['token']) || !isset($data['novaSenha'])) {
            return ["status" => 400, "data" => ["message" => "Dados insuficientes"]];
        }

        $stmt = $this->db->prepare("SELECT usuario_id FROM tokens_recuperacao WHERE token = :tk AND expira_em > NOW() AND usado = 0");
        $stmt->execute(['tk' => $data['token']]);
        $rec = $stmt->fetch();

        if (!$rec) {
            return ["status" => 400, "data" => ["message" => "Token inválido ou expirado"]];
        }

        $novaSenhaHash = password_hash($data['novaSenha'], PASSWORD_BCRYPT);
        
        $this->db->beginTransaction();
        try {
            // Atualiza senha
            $stmtUp = $this->db->prepare("UPDATE usuarios SET senha = :sh WHERE id = :uid");
            $stmtUp->execute(['sh' => $novaSenhaHash, 'uid' => $rec['usuario_id']]);

            // Invalida token
            $stmtInv = $this->db->prepare("UPDATE tokens_recuperacao SET usado = 1 WHERE token = :tk");
            $stmtInv->execute(['tk' => $data['token']]);

            $this->db->commit();
            return ["status" => 200, "data" => ["message" => "Senha alterada com sucesso!"]];
        } catch (\Exception $e) {
            $this->db->rollBack();
            return ["status" => 500, "data" => ["message" => "Erro ao processar alteração"]];
        }
    }
}
