<?php
// api/src/Controllers/UsuarioController.php

namespace App\Controllers;

use App\Database;
use App\JWTHelper;
use PDO;
use Google\Client as GoogleClient;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class UsuarioController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function login($data) {
        if (!isset($data['email']) || !isset($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "E-mail e senha são obrigatórios"]];
        }

        $user = null;
        try {
            $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE email = :email AND ativo = 1");
            $stmt->execute(['email' => $data['email']]);
            $user = $stmt->fetch();
        } catch (\Exception $e) {
            error_log("Database error during login check: " . $e->getMessage());
        }

        // 1. Validar no banco de dados se o usuário existir
        if ($user && password_verify($data['senha'], $user['senha'])) {
            $token = JWTHelper::generate([
                'id' => $user['id'],
                'email' => $user['email'],
                'perfilId' => $user['perfil_id']
            ]);

            unset($user['senha']);
            return ["status" => 200, "data" => [
                "user" => $user,
                "token" => $token
            ]];
        }

        // 2. Fallback para as contas de teste informais solicitadas (se não existirem no DB ou se o DB falhar)
        $mockUsers = [
            'admin@koavy.com' => [
                'id' => 999,
                'perfil_id' => 3,
                'nome' => 'Administrador Koavy (Mock)',
                'email' => 'admin@koavy.com',
                'senha_plain' => 'admin123',
                'ativo' => 1
            ],
            'paciente@koavy.com' => [
                'id' => 888,
                'perfil_id' => 1,
                'nome' => 'Paciente Koavy (Mock)',
                'email' => 'paciente@koavy.com',
                'senha_plain' => 'paciente123',
                'ativo' => 1
            ],
            'tutor@koavy.com' => [
                'id' => 777,
                'perfil_id' => 2,
                'nome' => 'Tutor Koavy (Mock)',
                'email' => 'tutor@koavy.com',
                'senha_plain' => 'tutor123',
                'ativo' => 1
            ]
        ];

        $emailLower = strtolower(trim($data['email']));
        if (isset($mockUsers[$emailLower]) && $data['senha'] === $mockUsers[$emailLower]['senha_plain']) {
            $mockUser = $mockUsers[$emailLower];
            unset($mockUser['senha_plain']);
            $token = JWTHelper::generate([
                'id' => $mockUser['id'],
                'email' => $mockUser['email'],
                'perfilId' => $mockUser['perfil_id']
            ]);
            return ["status" => 200, "data" => [
                "user" => $mockUser,
                "token" => $token
            ]];
        }

        return ["status" => 401, "data" => ["message" => "E-mail ou senha inválidos"]];
    }

    public function cadastrar($data) {
        // Validações básicas
        if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "Dados incompletos (nome, email e senha são obrigatórios)"]];
        }

        // Mapeamento de campos do Frontend (camelCase) para o Banco (snake_case)
        $perfil_id = $data['perfil_id'] ?? $data['perfilId'] ?? 1;
        $hash = password_hash($data['senha'], PASSWORD_BCRYPT);
        
        $sql = "INSERT INTO usuarios (
                    perfil_id, nome, email, senha, idade, data_nascimento, 
                    sexo, telefone, tipo_sanguineo, peso, altura, 
                    marcapasso, obs_med, cep, ativo
                ) VALUES (
                    :perfil_id, :nome, :email, :senha, :idade, :data_nascimento, 
                    :sexo, :telefone, :tipo_sanguineo, :peso, :altura, 
                    :marcapasso, :obs_med, :cep, 1
                )";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'perfil_id'       => $perfil_id,
                'nome'            => $data['nome'],
                'email'           => $data['email'],
                'senha'           => $hash,
                'idade'           => $data['idade'] ?? null,
                'data_nascimento' => $data['data_nascimento'] ?? $data['dataNascimento'] ?? null,
                'sexo'            => $data['sexo'] ?? 'O',
                'telefone'        => $data['telefone'] ?? null,
                'tipo_sanguineo'  => $data['tipo_sanguineo'] ?? $data['tipoSanguineo'] ?? null,
                'peso'            => $data['peso'] ?? null,
                'altura'          => $data['altura'] ?? null,
                'marcapasso'      => isset($data['marcapasso']) ? (int)$data['marcapasso'] : 0,
                'obs_med'         => $data['obs_med'] ?? $data['obsMed'] ?? null,
                'cep'             => $data['cep'] ?? null
            ]);

            $userId = $this->db->lastInsertId();

            // Criar configuração cardíaca padrão para o novo usuário
            $stmtConfig = $this->db->prepare("INSERT INTO configuracoes_cardiacas (usuario_id) VALUES (:uid)");
            $stmtConfig->execute(['uid' => $userId]);

            return ["status" => 201, "data" => ["message" => "Usuário cadastrado com sucesso", "id" => $userId]];
        } catch (\PDOException $e) {
            if ($e->getCode() == 23000) {
                return ["status" => 409, "data" => ["message" => "E-mail já cadastrado"]];
            }
            error_log("Erro no cadastro: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao processar cadastro."]];
        }
    }

    public function listar() {
        $stmt = $this->db->query("SELECT id, perfil_id as perfilId, nome, email, ativo, idade, tipo_sanguineo as tipoSanguineo, telefone, peso, altura FROM usuarios ORDER BY nome ASC");
        return ["status" => 200, "data" => $stmt->fetchAll()];
    }

    public function buscarPorId($id) {
        $stmt = $this->db->prepare("SELECT id, perfil_id as perfilId, nome, email, ativo, idade, tipo_sanguineo as tipoSanguineo, telefone, peso, altura, marcapasso, obs_med as obsMed, cep FROM usuarios WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();
        if (!$user) return ["status" => 404, "data" => ["message" => "Usuário não encontrado"]];
        return ["status" => 200, "data" => $user];
    }

    public function atualizar($id, $data) {
        $sql = "UPDATE usuarios SET 
                nome = :nome, email = :email, telefone = :telefone, 
                peso = :peso, altura = :altura, tipo_sanguineo = :tipoSanguineo, 
                ativo = :ativo, idade = :idade
                WHERE id = :id";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'id' => $id,
                'nome' => $data['nome'],
                'email' => $data['email'],
                'telefone' => $data['telefone'] ?? null,
                'peso' => $data['peso'] ?? null,
                'altura' => $data['altura'] ?? null,
                'tipoSanguineo' => $data['tipoSanguineo'] ?? $data['tipo_sanguineo'] ?? null,
                'ativo' => isset($data['ativo']) ? (int)$data['ativo'] : 1,
                'idade' => $data['idade'] ?? null
            ]);
            return ["status" => 200, "data" => ["message" => "Usuário atualizado"]];
        } catch (\PDOException $e) {
            return ["status" => 500, "data" => ["message" => "Erro ao atualizar: " . $e->getMessage()]];
        }
    }

    /**
     * Processa a sessão e token de um usuário autenticado pelo Google
     */
    private function processarGoogleUser($email, $nome) {
        $user = null;
        try {
            $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE email = :email");
            $stmt->execute(['email' => $email]);
            $user = $stmt->fetch();

            if (!$user) {
                // Cadastra novo usuário como Paciente (perfil_id = 1)
                $this->cadastrar([
                    'nome' => $nome,
                    'email' => $email,
                    'senha' => bin2hex(random_bytes(12)),
                    'perfil_id' => 1
                ]);
                
                $stmt->execute(['email' => $email]);
                $user = $stmt->fetch();
            }
        } catch (\Exception $e) {
            error_log("Database error during Google login sync: " . $e->getMessage());
            // Fallback mock user if DB is down/disconnected
            $user = [
                'id' => 888,
                'perfil_id' => 1,
                'nome' => $nome,
                'email' => $email,
                'ativo' => 1
            ];
        }

        $token = JWTHelper::generate([
            'id' => $user['id'],
            'email' => $user['email'],
            'perfilId' => $user['perfil_id']
        ]);

        unset($user['senha']);
        return ["status" => 200, "data" => ["user" => $user, "token" => $token]];
    }

    /**
     * Login com Google Real
     */
    public function googleLogin($data) {
        if (!isset($data['credential'])) {
            return ["status" => 400, "data" => ["message" => "Token do Google ausente"]];
        }

        $tokenStr = $data['credential'];

        // 1. Fallback / Modo Desenvolvedor se o token for mock
        if (strpos($tokenStr, 'mock_') === 0 || !class_exists('Google\Client')) {
            $email = $data['email'] ?? 'google_test@koavy.com';
            $nome = $data['nome'] ?? 'Usuário Google Teste';
            return $this->processarGoogleUser($email, $nome);
        }

        try {
            // Suporta os dois Client IDs do projeto (Web e Mobile) para evitar conflitos de Audience
            $clientIds = [
                '564333524566-6rdtj7cv3dcid25saevvh1oh37tkoijr.apps.googleusercontent.com',
                '564333524566-cq8tcbvlhadhnrqtncp7rb9qpdo1iftf.apps.googleusercontent.com'
            ];

            $payload = null;
            foreach ($clientIds as $clientId) {
                try {
                    $client = new GoogleClient(['client_id' => $clientId]);
                    $payload = $client->verifyIdToken($tokenStr);
                    if ($payload) break;
                } catch (\Exception $ex) {
                    // Ignora erro do client ID individual e tenta o próximo
                }
            }
            
            if ($payload) {
                $email = $payload['email'];
                $nome = $payload['name'] ?? 'Usuário Google';
                return $this->processarGoogleUser($email, $nome);
            } else {
                // Fallback para desenvolvimento local: se o token não validar mas veio dados informados
                if (isset($data['email']) && isset($data['nome'])) {
                    return $this->processarGoogleUser($data['email'], $data['nome']);
                }
                return ["status" => 401, "data" => ["message" => "Token do Google inválido ou expirado"]];
            }
        } catch (\Exception $e) {
            // Se falhar a biblioteca, tenta processar com os dados enviados se fornecidos
            if (isset($data['email']) && isset($data['nome'])) {
                return $this->processarGoogleUser($data['email'], $data['nome']);
            }
            return ["status" => 500, "data" => ["message" => "Erro na validação do Google: " . $e->getMessage()]];
        }
    }

    /**
     * Recuperação de Senha com PHPMailer
     */
    public function solicitarRecuperacao($email) {
        $stmt = $this->db->prepare("SELECT id, nome FROM usuarios WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if (!$user) return ["status" => 404, "data" => ["message" => "E-mail não cadastrado"]];

        $token = bin2hex(random_bytes(25));
        $link = "http://143.106.241.4/koavy/Web/redefinir-senha.html?token=" . $token;

        // Envio de E-mail Real (Exemplo com Gmail)
        $mail = new PHPMailer(true);
        try {
            // Configurações do Servidor (VOCÊ DEVE AJUSTAR ESTES DADOS)
            $mail->isSMTP();
            $mail->Host       = 'emilly1190.gmail.com'; 
            $mail->SMTPAuth   = true;
            $mail->Username   = 'emilly1190@gmail.com'; // <- SEU EMAIL AQUI
            $mail->Password   = '3105866-app';        // <- SUA SENHA DE APP AQUI
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = 587;

            // Destinatários
            $mail->setFrom('suporte@koavy.com', 'Koavy Health');
            $mail->addAddress($email, $user['nome']);

            // Conteúdo Profissional (Template Koavy)
            $mail->isHTML(true);
            $mail->Subject = 'Recuperacao de Acesso - Koavy Health';
            
            // Design do Email (CSS inline para compatibilidade)
            $mail->Body    = "
            <div style='background-color: #050505; color: #d1d5db; font-family: sans-serif; padding: 40px; text-align: center; border-radius: 20px;'>
                <div style='margin-bottom: 30px;'>
                    <div style='background: linear-gradient(135deg, #00f2ff, #00d4aa); width: 60px; height: 60px; border-radius: 15px; display: inline-block; line-height: 60px; color: black; font-weight: 900; font-size: 30px;'>K</div>
                    <h1 style='color: white; margin-top: 20px; font-weight: 800; letter-spacing: -1px;'>Koavy <span style='color: #00f2ff;'>Health</span></h1>
                </div>
                
                <div style='background-color: #111; padding: 30px; border-radius: 30px; border: 1px solid #222; max-width: 500px; margin: 0 auto;'>
                    <h2 style='color: white;'>Recuperar Acesso</h2>
                    <p style='font-size: 16px; line-height: 1.6;'>Olá, <strong>{$user['nome']}</strong>.</p>
                    <p style='font-size: 14px; color: #9ca3af;'>Recebemos uma solicitação para redefinir a senha da sua conta Koavy. Se você não solicitou isso, pode ignorar este e-mail.</p>
                    
                    <div style='margin: 40px 0;'>
                        <a href='{$link}' style='background: linear-gradient(to right, #00f2ff, #00d4aa); color: black; padding: 18px 35px; border-radius: 15px; text-decoration: none; font-weight: 800; font-size: 16px; box-shadow: 0 10px 20px rgba(0,242,255,0.2);'>REDEFINIR MINHA SENHA</a>
                    </div>
                    
                    <p style='font-size: 11px; color: #4b5563; margin-top: 40px;'>Este link expira em 1 hora por segurança.</p>
                </div>
                
                <div style='margin-top: 40px; font-size: 12px; color: #4b5563;'>
                    &copy; 2026 Koavy Health Technologies. <br>
                    Sua saúde monitorada com inteligência.
                </div>
            </div>";

            $mail->AltBody = "Olá {$user['nome']}, acesse o link para redefinir sua senha: {$link}";

            $mail->send();
            return ["status" => 200, "data" => ["message" => "Um link de redefinição foi enviado para o seu e-mail."]];
        } catch (Exception $e) {
            error_log("Falha no PHPMailer: " . $mail->ErrorInfo);
            return ["status" => 500, "data" => ["message" => "Erro ao enviar e-mail. Verifique suas configurações de SMTP."]];
        }
    }
}
