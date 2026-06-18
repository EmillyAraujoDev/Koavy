<?php
// api/public/index.php

$isDebug = filter_var(getenv('KOAVY_DEBUG') ?: false, FILTER_VALIDATE_BOOLEAN);
ini_set('display_errors', $isDebug ? '1' : '0');
ini_set('display_startup_errors', $isDebug ? '1' : '0');
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// Carregar Autoloader do Composer (Bibliotecas PHPMailer e Google API)
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

require_once __DIR__ . '/../src/Database.php';
require_once __DIR__ . '/../src/JWTHelper.php';
require_once __DIR__ . '/../src/Controllers/UsuarioController.php';
require_once __DIR__ . '/../src/Controllers/BatimentoController.php';
require_once __DIR__ . '/../src/Controllers/EmergenciaController.php';
require_once __DIR__ . '/../src/Controllers/TutorController.php';
require_once __DIR__ . '/../src/Controllers/RelatorioController.php';
require_once __DIR__ . '/../src/Controllers/VinculoController.php';

use App\Controllers\UsuarioController;
use App\Controllers\BatimentoController;
use App\Controllers\EmergenciaController;
use App\Controllers\TutorController;
use App\Controllers\RelatorioController;
use App\Controllers\VinculoController;
use App\JWTHelper;

// Roteador dinâmico
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$scriptName = $_SERVER['SCRIPT_NAME'];
$basePath = dirname($scriptName);
$basePath = rtrim($basePath, '/\\');

if ($basePath !== '' && strpos($uri, $basePath) === 0) {
    $routePath = substr($uri, strlen($basePath));
} else {
    $routePath = $uri;
}

// Remover index.php e limpar barras das extremidades
$routePath = str_replace('index.php', '', $routePath);
$routePath = trim($routePath, '/');

// Limpar prefixo api/ se presente
if (strpos($routePath, 'api/') === 0) {
    $routePath = substr($routePath, 4);
} elseif ($routePath === 'api') {
    $routePath = '';
}

$segments = explode('/', $routePath);
$resource = $segments[0] ?? null;
$action = $segments[1] ?? null;
$id = $segments[1] ?? null; // /{recurso}/{id}

$input = json_decode(file_get_contents("php://input"), true) ?? [];

$usuarioController = new UsuarioController();
$batimentoController = new BatimentoController();
$emergenciaController = new EmergenciaController();
$tutorController = new TutorController();
$relatorioController = new RelatorioController();
$vinculoController = new VinculoController();

// Middleware de Autenticação
$auth = null;
$isPublicRoute = in_array($resource, ['login', 'cadastro', 'google-login', 'recuperar-senha', 'redefinir-senha']);
$headers = getallheaders();
$token = $headers['Authorization'] ?? $headers['authorization'] ?? null;

if ($token) {
    $token = str_replace('Bearer ', '', $token);
    $auth = JWTHelper::validate($token);
}

// Vinculos pode ser acessado publicamente no POST para novos tutores
if (!$auth && !$isPublicRoute && !($resource === 'vinculos' && $_SERVER['REQUEST_METHOD'] === 'POST')) {
    http_response_code(401);
    echo json_encode(["message" => "Não autorizado. Token inválido ou expirado."]);
    exit;
}

// Função auxiliar de controle de acesso (RBAC + Propriedade)
function checkAccessToPatient($auth, $patientId) {
    if (!$auth) return false;
    
    // O próprio usuário tem acesso
    if ($auth['id'] == $patientId) {
        return true;
    }
    
    // Admin tem acesso a todos
    $perfil = $auth['perfilId'] ?? null;
    if ($perfil == 3) {
        return true;
    }
    
    // Tutor tem acesso aos seus pacientes vinculados
    if ($perfil == 2) {
        $db = \App\Database::getInstance();
        $stmt = $db->prepare("SELECT 1 FROM tutor_paciente WHERE tutor_id = :tutor_id AND paciente_id = :paciente_id");
        $stmt->execute(['tutor_id' => $auth['id'], 'paciente_id' => $patientId]);
        if ($stmt->fetch()) {
            return true;
        }
    }
    
    return false;
}

// Roteamento dos Recursos
$res = ["status" => 404, "data" => ["message" => "Endpoint '$resource' não encontrado"]];

switch ($resource) {
    case 'login':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $usuarioController->login($input);
        }
        break;

    case 'cadastro':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $usuarioController->cadastrar($input);
        }
        break;

    case 'google-login':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $usuarioController->googleLogin($input);
        }
        break;

    case 'recuperar-senha':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $usuarioController->solicitarRecuperacao($input['email'] ?? '');
        }
        break;

    case 'redefinir-senha':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $usuarioController->redefinirSenha($input);
        }
        break;

    case 'usuarios':
        if ($_SERVER['REQUEST_METHOD'] === 'GET' && empty($id)) {
            $perfil = $auth['perfilId'] ?? null;
            if ($perfil != 3) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $usuarioController->getTodos();
            }
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && !empty($id)) {
            if (!checkAccessToPatient($auth, $id)) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $usuarioController->getPorId($id);
            }
        } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT' && !empty($id)) {
            if ($auth['id'] != $id && ($auth['perfilId'] ?? null) != 3) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $usuarioController->atualizar($id, $input);
            }
        }
        break;

    case 'batimentos':
        if ($_SERVER['REQUEST_METHOD'] === 'GET' && empty($action)) {
            $res = $batimentoController->getHistorico($auth['id']);
        } elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && empty($action)) {
            $res = $batimentoController->registrar($input, $auth['id']);
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'resumo') {
            $res = $batimentoController->getResumo($auth['id']);
        } elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && $action === 'simular') {
            $res = $batimentoController->simular($input['tipo'] ?? 'normal', $auth['id']);
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'usuario' && isset($segments[2])) {
            $patientId = $segments[2];
            if (!checkAccessToPatient($auth, $patientId)) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $batimentoController->getHistorico($patientId);
            }
        }
        break;

    case 'emergencias':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $userId = $input['usuarioId'] ?? $input['usuario_id'] ?? $auth['id'];
            if ($auth['id'] != $userId && ($auth['perfilId'] ?? null) != 3) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $emergenciaController->registrar($input, $userId);
            }
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'usuario' && isset($segments[2])) {
            $patientId = $segments[2];
            if (!checkAccessToPatient($auth, $patientId)) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $emergenciaController->getHistoricoUsuario($patientId);
            }
        }
        break;

    case 'vinculos':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $vinculoController->vincular($input, $auth ? $auth['id'] : null);
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'pacientes') {
            if (($auth['perfilId'] ?? null) != 2) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido. Apenas tutores."]];
            } else {
                $res = $vinculoController->getPacientesTutor($auth['id']);
            }
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'paciente' && isset($segments[2])) {
            $patientId = $segments[2];
            if (!checkAccessToPatient($auth, $patientId)) {
                $res = ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            } else {
                $res = $vinculoController->getTutoresPaciente($patientId);
            }
        } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE' && !empty($id)) {
            $res = $vinculoController->remover($id, $auth);
        }
        break;

    case 'relatorios':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $relatorioController->gerar($auth['id'], $input['tipo'] ?? 'DIARIO');
        } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
            $res = $relatorioController->getLista($auth['id']);
        }
        break;
}

http_response_code($res['status']);
echo json_encode($res['data']);
