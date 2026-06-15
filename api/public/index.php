<?php
// api/public/index.php

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
<<<<<<< HEAD
require_once __DIR__ . '/../src/Controllers/TutorController.php';
require_once __DIR__ . '/../src/Controllers/RelatorioController.php';
=======
require_once __DIR__ . '/../src/Controllers/VinculoController.php';
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f

use App\Controllers\UsuarioController;
use App\Controllers\BatimentoController;
use App\Controllers\EmergenciaController;
<<<<<<< HEAD
use App\Controllers\TutorController;
use App\Controllers\RelatorioController;
=======
use App\Controllers\VinculoController;
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
use App\JWTHelper;

// Roteador dinâmico relativo à pasta de instalação do script
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
<<<<<<< HEAD
$uri_parts = explode('/', trim($uri, '/'));

/**
 * Lógica de Roteamento Aprimorada
 * Busca os componentes do endpoint de trás para frente para maior flexibilidade
 * Padrão esperado: .../{resource}/{action}/{id} ou .../{resource}
 */
$resource = null;
$action = null;
$id = null;

// Reverte para facilitar a captura do final da URL
$reversed = array_reverse($uri_parts);

if (count($reversed) >= 1) {
    if (is_numeric($reversed[0])) {
        $id = $reversed[0];
        $action = $reversed[1] ?? null;
        $resource = $reversed[2] ?? null;
    } else {
        // Se o último for 'usuario', 'login', etc.
        if (in_array($reversed[0], ['login', 'cadastro', 'batimentos', 'emergencias', 'usuarios', 'vinculos'])) {
            $resource = $reversed[0];
        } else if (isset($reversed[1]) && in_array($reversed[1], ['batimentos', 'emergencias', 'usuarios', 'vinculos'])) {
            $resource = $reversed[1];
            $action = $reversed[0];
        } else if (isset($reversed[2]) && in_array($reversed[2], ['batimentos', 'emergencias', 'usuarios', 'vinculos'])) {
            $resource = $reversed[2];
            $action = $reversed[1];
            $id = $reversed[0];
        }
    }
}

// Fallback para o modo anterior se não detectado
if (!$resource && count($uri_parts) >= 1) {
    $resource = end($uri_parts);
=======
$scriptName = $_SERVER['SCRIPT_NAME'];
$basePath = dirname($scriptName);
$basePath = rtrim($basePath, '/\\');

if ($basePath !== '' && strpos($uri, $basePath) === 0) {
    $routePath = substr($uri, strlen($basePath));
} else {
    $routePath = $uri;
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
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
<<<<<<< HEAD
$tutorController = new TutorController();
$relatorioController = new RelatorioController();
=======
$vinculoController = new VinculoController();
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f

// Middleware de Autenticação
$auth = null;
<<<<<<< HEAD
if (!in_array($resource, ['login', 'cadastro', 'google-login', 'recuperar-senha', 'vinculos', 'vinculo'])) {
    $headers = getallheaders();
    $token = $headers['Authorization'] ?? $headers['authorization'] ?? null;
    if ($token) {
        $token = str_replace('Bearer ', '', $token);
        $auth = JWTHelper::validate($token);
    }

    // Se o recurso não for 'public' e não houver auth, barra o acesso
    if (!$auth && $resource !== 'public' && $_SERVER['REQUEST_METHOD'] !== 'OPTIONS') {
        http_response_code(401);
        echo json_encode(["message" => "Não autorizado. Token inválido ou expirado."]);
        exit;
    }
=======
$isPublicRoute = in_array($resource, ['login', 'cadastro']);
$headers = getallheaders();
$token = $headers['Authorization'] ?? $headers['authorization'] ?? null;

if ($token) {
    $token = str_replace('Bearer ', '', $token);
    $auth = JWTHelper::validate($token);
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
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
        break;

    case 'cadastro':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(["message" => "Método não permitido"]);
            break;
        }
        $res = $usuarioController->cadastrar($input);
        break;

    case 'google-login':
        $res = $usuarioController->googleLogin($input);
        break;

    case 'recuperar-senha':
        $res = $usuarioController->solicitarRecuperacao($input['email'] ?? '');
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
<<<<<<< HEAD
            $res = $batimentoController->registrar($input, $auth['id']);
        } else {
            // Suporta /batimentos/usuario/123 ou apenas /batimentos
            $targetId = ($action === 'usuario' && $id) ? $id : $auth['id'];
            $res = $batimentoController->getHistorico($targetId);
        }
        break;

    case 'emergencias':
    case 'emergencia':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $emergenciaController->registrar($input, $auth['id']);
        } else {
            $targetId = ($action === 'usuario' && $id) ? $id : $auth['id'];
            $res = $emergenciaController->getHistorico($targetId);
        }
        break;

    case 'vinculos':
    case 'vinculo':
        $res = $tutorController->vincular($input);
        break;

    case 'usuarios':
    case 'usuario':
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            if ($id) {
                $res = $usuarioController->buscarPorId($id);
            } else {
                $res = $usuarioController->listar();
            }
        } else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
            $res = $usuarioController->atualizar($id, $input);
        }
        break;

    case 'relatorios':
    case 'relatorio':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $relatorioController->gerar($auth['id'], $input['tipo'] ?? 'DIARIO');
        } else {
            $res = $relatorioController->getLista($auth['id']);
=======
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
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
        }
        break;

    default:
        $res = ["status" => 404, "data" => ["message" => "Endpoint '$resource' não encontrado"]];
        break;
}

http_response_code($res['status']);
echo json_encode($res['data']);
