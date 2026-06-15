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
require_once __DIR__ . '/../src/Controllers/TutorController.php';
require_once __DIR__ . '/../src/Controllers/RelatorioController.php';

use App\Controllers\UsuarioController;
use App\Controllers\BatimentoController;
use App\Controllers\EmergenciaController;
use App\Controllers\TutorController;
use App\Controllers\RelatorioController;
use App\JWTHelper;

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
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
}

$input = json_decode(file_get_contents("php://input"), true);

$usuarioController = new UsuarioController();
$batimentoController = new BatimentoController();
$emergenciaController = new EmergenciaController();
$tutorController = new TutorController();
$relatorioController = new RelatorioController();

// Middleware de Autenticação
$auth = null;
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
}

// Rotas
switch ($resource) {
    case 'login':
        $res = $usuarioController->login($input);
        break;

    case 'cadastro':
        $res = $usuarioController->cadastrar($input);
        break;

    case 'google-login':
        $res = $usuarioController->googleLogin($input);
        break;

    case 'recuperar-senha':
        $res = $usuarioController->solicitarRecuperacao($input['email'] ?? '');
        break;

    case 'batimentos':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
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
        }
        break;

    default:
        $res = ["status" => 404, "data" => ["message" => "Endpoint '$resource' não encontrado"]];
        break;
}

http_response_code($res['status']);
echo json_encode($res['data']);
