<?php
// api/public/index.php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once __DIR__ . '/../src/Database.php';
require_once __DIR__ . '/../src/JWTHelper.php';
require_once __DIR__ . '/../src/Controllers/UsuarioController.php';
require_once __DIR__ . '/../src/Controllers/BatimentoController.php';
require_once __DIR__ . '/../src/Controllers/EmergenciaController.php';
require_once __DIR__ . '/../src/Controllers/VinculoController.php';

use App\Controllers\UsuarioController;
use App\Controllers\BatimentoController;
use App\Controllers\EmergenciaController;
use App\Controllers\VinculoController;
use App\JWTHelper;

// Roteador dinâmico relativo à pasta de instalação do script
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
$id = $segments[1] ?? null; // Mapeia padrão /{recurso}/{id}

$input = json_decode(file_get_contents("php://input"), true) ?? [];

$usuarioController = new UsuarioController();
$batimentoController = new BatimentoController();
$emergenciaController = new EmergenciaController();
$vinculoController = new VinculoController();

// Middleware de Autenticação para rotas protegidas
$auth = null;
$isPublicRoute = in_array($resource, ['login', 'cadastro']);
$headers = getallheaders();
$token = $headers['Authorization'] ?? $headers['authorization'] ?? null;

if ($token) {
    $token = str_replace('Bearer ', '', $token);
    $auth = JWTHelper::validate($token);
}

// vinculos pode ser acessado publicamente no POST para novos tutores
if (!$auth && !$isPublicRoute && !($resource === 'vinculos' && $_SERVER['REQUEST_METHOD'] === 'POST')) {
    http_response_code(401);
    echo json_encode(["message" => "Não autorizado"]);
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
switch ($resource) {
    case 'login':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
            break;
        }
        $res = $usuarioController->login($input);
        http_response_code($res['status']);
        echo json_encode($res['data']);
        break;

    case 'cadastro':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
            break;
        }
        $res = $usuarioController->cadastrar($input);
        http_response_code($res['status']);
        echo json_encode($res['data']);
        break;

    case 'usuarios':
        // GET /usuarios (restrito a admin)
        if ($_SERVER['REQUEST_METHOD'] === 'GET' && empty($id)) {
            $perfil = $auth['perfilId'] ?? null;
            if ($perfil != 3) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $usuarioController->getTodos();
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        // GET /usuarios/{id} (self ou admin)
        elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && !empty($id)) {
            if (!checkAccessToPatient($auth, $id)) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $usuarioController->getPorId($id);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        // PUT /usuarios/{id} (self ou admin)
        elseif ($_SERVER['REQUEST_METHOD'] === 'PUT' && !empty($id)) {
            $perfil = $auth['perfilId'] ?? null;
            if ($auth['id'] != $id && $perfil != 3) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $usuarioController->atualizar($id, $input);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        else {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
        }
        break;

    case 'batimentos':
        // GET /batimentos (retorna histórico do usuário logado)
        if ($_SERVER['REQUEST_METHOD'] === 'GET' && empty($action)) {
            $res = $batimentoController->getHistorico($auth['id']);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        // POST /batimentos (registra batimento para o próprio usuário)
        elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && empty($action)) {
            $res = $batimentoController->registrar($input, $auth['id']);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        // GET /batimentos/usuario/{id}
        elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'usuario' && isset($segments[2])) {
            $patientId = $segments[2];
            if (!checkAccessToPatient($auth, $patientId)) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $batimentoController->getHistorico($patientId);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        else {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
        }
        break;

    case 'emergencias':
        // POST /emergencias (registra emergência)
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $userId = $input['usuarioId'] ?? $input['usuario_id'] ?? $auth['id'];
            if ($auth['id'] != $userId && ($auth['perfilId'] ?? null) != 3) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $emergenciaController->registrar($input, $userId);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        // GET /emergencias/usuario/{id}
        elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'usuario' && isset($segments[2])) {
            $patientId = $segments[2];
            if (!checkAccessToPatient($auth, $patientId)) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido"]);
                break;
            }
            $res = $emergenciaController->getHistoricoUsuario($patientId);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        else {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
        }
        break;

    case 'vinculos':
        // POST /vinculos
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $vinculoController->vincular($input, $auth ? $auth['id'] : null);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        else {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
        }
        break;

    case 'tutor':
        // GET /tutor/pacientes
        if ($_SERVER['REQUEST_METHOD'] === 'GET' && $action === 'pacientes') {
            $perfil = $auth['perfilId'] ?? null;
            if ($perfil != 2) {
                http_response_code(403);
                echo json_encode(["message" => "Acesso proibido. Apenas tutores."]);
                break;
            }
            $res = $vinculoController->getPacientesTutor($auth['id']);
            http_response_code($res['status']);
            echo json_encode($res['data']);
        }
        else {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
        }
        break;

    default:
        http_response_code(404);
        echo json_encode(["message" => "Endpoint não encontrado"]);
        break;
}
