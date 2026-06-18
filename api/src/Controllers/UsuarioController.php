<?php
// api/src/Controllers/UsuarioController.php

namespace App\Controllers;

use App\Database;
use App\JWTHelper;
use PDO;
use Throwable;

class UsuarioController {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    private function sanitizeString($value): ?string {
        if ($value === null) return null;
        $value = trim((string)$value);
        if ($value === '') return null;
        return htmlspecialchars(strip_tags($value), ENT_QUOTES, 'UTF-8');
    }

    private function boolToInt($value): int {
        if (is_bool($value)) return $value ? 1 : 0;
        return in_array(strtolower((string)$value), ['1', 'true', 'sim', 'yes'], true) ? 1 : 0;
    }

    private function normalizeUser(array $row): array {
        unset($row['senha']);

        $row['id'] = (int)$row['id'];
        $row['perfil_id'] = (int)$row['perfil_id'];
        $row['perfilId'] = (int)$row['perfil_id'];
        $row['ativo'] = (int)($row['ativo'] ?? 1);

        if (isset($row['idade'])) $row['idade'] = $row['idade'] !== null ? (int)$row['idade'] : null;
        if (isset($row['peso'])) $row['peso'] = $row['peso'] !== null ? (float)$row['peso'] : null;
        if (isset($row['altura'])) $row['altura'] = $row['altura'] !== null ? (float)$row['altura'] : null;
        if (isset($row['marcapasso'])) $row['marcapasso'] = (bool)$row['marcapasso'];

        $row['dataNascimento'] = $row['data_nascimento'] ?? null;
        $row['tipoSanguineo'] = $row['tipo_sanguineo'] ?? null;
        $row['obsMed'] = $row['obs_med'] ?? null;
        $row['avatarUrl'] = $row['avatar_url'] ?? null;
        $row['fcmToken'] = $row['fcm_token'] ?? null;
        $row['ultimoLogin'] = $row['ultimo_login'] ?? null;

        return $row;
    }

    private function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE lower(email) = lower(:email) LIMIT 1");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    private function generateAuthResponse(array $user): array {
        $publicUser = $this->normalizeUser($user);
        $token = JWTHelper::generate([
            'id' => $publicUser['id'],
            'email' => $publicUser['email'],
            'perfilId' => $publicUser['perfil_id'],
            'perfil_id' => $publicUser['perfil_id'],
            'nome' => $publicUser['nome'],
        ]);

        return [
            'token' => $token,
            'user' => $publicUser,
            'usuario' => $publicUser,
        ];
    }

    public function login(array $data): array {
        $email = strtolower(trim((string)($data['email'] ?? '')));
        $senha = (string)($data['senha'] ?? '');

        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $senha === '') {
            return ["status" => 400, "data" => ["message" => "Informe e-mail e senha para entrar."]];
        }

        $user = $this->findByEmail($email);
        if (!$user || (int)($user['ativo'] ?? 1) !== 1 || !password_verify($senha, $user['senha'])) {
            return ["status" => 401, "data" => ["message" => "E-mail ou senha incorretos."]];
        }

        $stmt = $this->db->prepare("UPDATE usuarios SET ultimo_login = CURRENT_TIMESTAMP WHERE id = :id");
        $stmt->execute(['id' => $user['id']]);
        $user['ultimo_login'] = date('Y-m-d H:i:s');

        return ["status" => 200, "data" => $this->generateAuthResponse($user)];
    }

    public function cadastrar(array $data): array {
        $nome = $this->sanitizeString($data['nome'] ?? null);
        $email = strtolower(trim((string)($data['email'] ?? '')));
        $senha = (string)($data['senha'] ?? '');
        $perfilId = (int)($data['perfilId'] ?? $data['perfil_id'] ?? 1);

        if (!in_array($perfilId, [1, 2, 3], true)) {
            return ["status" => 400, "data" => ["message" => "Perfil informado é inválido."]];
        }

        if (!$nome || mb_strlen($nome) < 3) {
            return ["status" => 400, "data" => ["message" => "Informe um nome válido."]];
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return ["status" => 400, "data" => ["message" => "Informe um e-mail válido."]];
        }

        if (strlen($senha) < 8) {
            return ["status" => 400, "data" => ["message" => "A senha deve ter pelo menos 8 caracteres."]];
        }

        if ($this->findByEmail($email)) {
            return ["status" => 409, "data" => ["message" => "Este e-mail já está cadastrado."]];
        }

        try {
            $this->db->beginTransaction();
            $stmt = $this->db->prepare("
                INSERT INTO usuarios (
                    perfil_id, nome, email, senha, idade, data_nascimento, sexo, telefone,
                    tipo_sanguineo, peso, altura, marcapasso, obs_med, cep, ativo
                ) VALUES (
                    :perfil_id, :nome, :email, :senha, :idade, :data_nascimento, :sexo, :telefone,
                    :tipo_sanguineo, :peso, :altura, :marcapasso, :obs_med, :cep, 1
                )
            ");

            $stmt->execute([
                'perfil_id' => $perfilId,
                'nome' => $nome,
                'email' => $email,
                'senha' => password_hash($senha, PASSWORD_BCRYPT),
                'idade' => isset($data['idade']) && $data['idade'] !== '' ? (int)$data['idade'] : null,
                'data_nascimento' => $this->sanitizeString($data['dataNascimento'] ?? $data['data_nascimento'] ?? null),
                'sexo' => $this->sanitizeString($data['sexo'] ?? null),
                'telefone' => $this->sanitizeString($data['telefone'] ?? null),
                'tipo_sanguineo' => $this->sanitizeString($data['tipoSanguineo'] ?? $data['tipo_sanguineo'] ?? null),
                'peso' => isset($data['peso']) && $data['peso'] !== '' ? (float)$data['peso'] : null,
                'altura' => isset($data['altura']) && $data['altura'] !== '' ? (float)$data['altura'] : null,
                'marcapasso' => $this->boolToInt($data['marcapasso'] ?? false),
                'obs_med' => $this->sanitizeString($data['obsMed'] ?? $data['obs_med'] ?? null),
                'cep' => $this->sanitizeString($data['cep'] ?? null),
            ]);

            $userId = (int)$this->db->lastInsertId();
            $config = $this->db->prepare("INSERT OR IGNORE INTO configuracoes_cardiacas (usuario_id) VALUES (:uid)");
            $config->execute(['uid' => $userId]);
            $this->db->commit();

            return ["status" => 201, "data" => [
                "message" => "Cadastro realizado com sucesso.",
                "id" => $userId,
                "usuario" => $this->normalizeUser($this->getUserRow($userId)),
            ]];
        } catch (Throwable $e) {
            if ($this->db->inTransaction()) $this->db->rollBack();
            error_log("Erro ao cadastrar usuário: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Não foi possível concluir o cadastro agora."]];
        }
    }

    private function getUserRow($id): ?array {
        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    public function getTodos(): array {
        $stmt = $this->db->query("SELECT * FROM usuarios ORDER BY cadastro DESC");
        return ["status" => 200, "data" => array_map([$this, 'normalizeUser'], $stmt->fetchAll())];
    }

    public function getPorId($id): array {
        $user = $this->getUserRow($id);
        if (!$user) {
            return ["status" => 404, "data" => ["message" => "Usuário não encontrado."]];
        }
        return ["status" => 200, "data" => $this->normalizeUser($user)];
    }

    public function atualizar($id, array $data): array {
        if (!$this->getUserRow($id)) {
            return ["status" => 404, "data" => ["message" => "Usuário não encontrado."]];
        }

        $allowed = [
            'nome' => 'nome',
            'telefone' => 'telefone',
            'dataNascimento' => 'data_nascimento',
            'data_nascimento' => 'data_nascimento',
            'sexo' => 'sexo',
            'tipoSanguineo' => 'tipo_sanguineo',
            'tipo_sanguineo' => 'tipo_sanguineo',
            'peso' => 'peso',
            'altura' => 'altura',
            'marcapasso' => 'marcapasso',
            'obsMed' => 'obs_med',
            'obs_med' => 'obs_med',
            'cep' => 'cep',
            'avatarUrl' => 'avatar_url',
            'avatar_url' => 'avatar_url',
            'fcmToken' => 'fcm_token',
            'fcm_token' => 'fcm_token',
            'idade' => 'idade',
        ];

        $sets = [];
        $params = ['id' => $id];
        foreach ($allowed as $inputKey => $column) {
            if (!array_key_exists($inputKey, $data)) continue;
            $param = $column;
            $sets[$column] = "$column = :$param";
            if ($column === 'marcapasso') {
                $params[$param] = $this->boolToInt($data[$inputKey]);
            } elseif (in_array($column, ['peso', 'altura'], true)) {
                $params[$param] = $data[$inputKey] !== '' ? (float)$data[$inputKey] : null;
            } elseif ($column === 'idade') {
                $params[$param] = $data[$inputKey] !== '' ? (int)$data[$inputKey] : null;
            } else {
                $params[$param] = $this->sanitizeString($data[$inputKey]);
            }
        }

        if (!$sets) {
            return ["status" => 400, "data" => ["message" => "Nenhum dado válido enviado para atualização."]];
        }

        $sql = "UPDATE usuarios SET " . implode(', ', array_values($sets)) . " WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return ["status" => 200, "data" => [
            "message" => "Perfil atualizado com sucesso.",
            "usuario" => $this->normalizeUser($this->getUserRow($id)),
        ]];
    }

    public function solicitarRecuperacao(string $email): array {
        $email = strtolower(trim($email));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return ["status" => 400, "data" => ["message" => "Informe um e-mail válido."]];
        }

        $user = $this->findByEmail($email);
        $genericMessage = "Se o e-mail estiver cadastrado, enviaremos as instruções de recuperação.";
        if (!$user) {
            return ["status" => 200, "data" => ["message" => $genericMessage]];
        }

        $token = bin2hex(random_bytes(32));
        $tokenHash = hash('sha256', $token);
        $expiresAt = date('Y-m-d H:i:s', time() + 3600);

        $invalidate = $this->db->prepare("UPDATE recuperacoes_senha SET usado = 1 WHERE lower(email) = lower(:email) AND usado = 0");
        $invalidate->execute(['email' => $email]);

        $stmt = $this->db->prepare("
            INSERT INTO recuperacoes_senha (email, token, expiracao, usado)
            VALUES (:email, :token, :expiracao, 0)
        ");
        $stmt->execute([
            'email' => $email,
            'token' => $tokenHash,
            'expiracao' => $expiresAt,
        ]);

        $link = $this->buildResetLink($token);
        $this->sendPasswordResetEmail($email, $link);

        return ["status" => 200, "data" => [
            "message" => $genericMessage,
            "expiresAt" => $expiresAt,
            "link" => $link,
        ]];
    }

    private function buildResetLink(string $token): string {
        $origin = getenv('KOAVY_WEB_URL') ?: '';
        if ($origin) {
            return rtrim($origin, '/') . '/redefinir-senha.html?token=' . urlencode($token);
        }

        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $script = $_SERVER['SCRIPT_NAME'] ?? '/api/public/index.php';
        $webPath = preg_replace('#/api/public/?.*$#', '/Web', $script);
        if ($webPath === $script) $webPath = '/Web';
        return $scheme . '://' . $host . rtrim($webPath, '/') . '/redefinir-senha.html?token=' . urlencode($token);
    }

    private function sendPasswordResetEmail(string $email, string $link): void {
        $host = getenv('KOAVY_SMTP_HOST');
        $user = getenv('KOAVY_SMTP_USER');
        $pass = getenv('KOAVY_SMTP_PASS');

        if (!$host || !$user || !$pass || !class_exists('\PHPMailer\PHPMailer\PHPMailer')) {
            error_log("KOAVY reset link for $email: $link");
            return;
        }

        try {
            $mail = new \PHPMailer\PHPMailer\PHPMailer(true);
            $mail->isSMTP();
            $mail->Host = $host;
            $mail->SMTPAuth = true;
            $mail->Username = $user;
            $mail->Password = $pass;
            $mail->SMTPSecure = getenv('KOAVY_SMTP_SECURE') ?: \PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = (int)(getenv('KOAVY_SMTP_PORT') ?: 587);
            $mail->CharSet = 'UTF-8';
            $mail->setFrom($user, 'Koavy');
            $mail->addAddress($email);
            $mail->isHTML(true);
            $mail->Subject = 'Redefinição de senha Koavy';
            $mail->Body = "<p>Recebemos uma solicitação para redefinir sua senha.</p><p><a href=\"$link\">Clique aqui para criar uma nova senha</a>.</p><p>O link expira em 1 hora.</p>";
            $mail->AltBody = "Acesse este link para redefinir sua senha: $link";
            $mail->send();
        } catch (Throwable $e) {
            error_log("Falha ao enviar e-mail de recuperação: " . $e->getMessage());
        }
    }

    public function redefinirSenha(array $data): array {
        $token = trim((string)($data['token'] ?? ''));
        $senha = (string)($data['senha'] ?? '');

        if ($token === '' || strlen($senha) < 8) {
            return ["status" => 400, "data" => ["message" => "Token ou senha inválidos."]];
        }

        $tokenHash = hash('sha256', $token);
        $stmt = $this->db->prepare("
            SELECT * FROM recuperacoes_senha
            WHERE token = :token AND usado = 0 AND expiracao > CURRENT_TIMESTAMP
            ORDER BY id DESC LIMIT 1
        ");
        $stmt->execute(['token' => $tokenHash]);
        $reset = $stmt->fetch();

        if (!$reset) {
            return ["status" => 400, "data" => ["message" => "Token expirado ou inválido. Solicite um novo link."]];
        }

        $user = $this->findByEmail($reset['email']);
        if (!$user) {
            return ["status" => 404, "data" => ["message" => "Usuário não encontrado."]];
        }

        $update = $this->db->prepare("UPDATE usuarios SET senha = :senha WHERE id = :id");
        $update->execute([
            'senha' => password_hash($senha, PASSWORD_BCRYPT),
            'id' => $user['id'],
        ]);

        $used = $this->db->prepare("UPDATE recuperacoes_senha SET usado = 1 WHERE id = :id");
        $used->execute(['id' => $reset['id']]);

        return ["status" => 200, "data" => ["message" => "Senha atualizada com sucesso."]];
    }

    public function googleLogin(array $data): array {
        $credential = (string)($data['credential'] ?? '');
        $email = strtolower(trim((string)($data['email'] ?? '')));
        $nome = $this->sanitizeString($data['nome'] ?? $data['name'] ?? null) ?: 'Usuário Koavy';

        if (!$email && substr_count($credential, '.') === 2) {
            $parts = explode('.', $credential);
            $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
            $email = strtolower(trim((string)($payload['email'] ?? '')));
            $nome = $this->sanitizeString($payload['name'] ?? $nome) ?: $nome;
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return ["status" => 400, "data" => ["message" => "Não foi possível validar o e-mail da conta Google."]];
        }

        $user = $this->findByEmail($email);
        if (!$user) {
            $senhaTemporaria = bin2hex(random_bytes(16));
            $perfilId = str_contains($email, 'tutor') ? 2 : 1;
            $created = $this->cadastrar([
                'perfilId' => $perfilId,
                'nome' => $nome,
                'email' => $email,
                'senha' => $senhaTemporaria,
            ]);
            if ($created['status'] >= 400) return $created;
            $user = $this->findByEmail($email);
        }

        if ((int)($user['ativo'] ?? 1) !== 1) {
            return ["status" => 403, "data" => ["message" => "Conta desativada."]];
        }

        return ["status" => 200, "data" => $this->generateAuthResponse($user)];
    }
}
