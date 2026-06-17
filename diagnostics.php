<?php
// diagnostics.php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "--- KOAVY API DIAGNOSTICS ---\n";

echo "1. Checking config file...\n";
if (!file_exists(__DIR__ . '/api/config/database.php')) {
    die("ERROR: api/config/database.php not found\n");
}
$config = require __DIR__ . '/api/config/database.php';
echo "SUCCESS: Config loaded.\n";

echo "2. Testing Database connection...\n";
require_once __DIR__ . '/api/src/Database.php';
try {
    $db = \App\Database::getInstance();
    echo "SUCCESS: Database connected.\n";
} catch (\Exception $e) {
    echo "ERROR: Database connection failed: " . $e->getMessage() . "\n";
}

echo "3. Loading JWTHelper...\n";
require_once __DIR__ . '/api/src/JWTHelper.php';
echo "SUCCESS: JWTHelper loaded.\n";

echo "4. Loading Controllers...\n";
try {
    require_once __DIR__ . '/api/src/Controllers/UsuarioController.php';
    require_once __DIR__ . '/api/src/Controllers/BatimentoController.php';
    require_once __DIR__ . '/api/src/Controllers/EmergenciaController.php';
    require_once __DIR__ . '/api/src/Controllers/TutorController.php';
    require_once __DIR__ . '/api/src/Controllers/RelatorioController.php';
    require_once __DIR__ . '/api/src/Controllers/VinculoController.php';
    echo "SUCCESS: All controllers loaded.\n";
} catch (\Exception $e) {
    echo "ERROR: Controller loading failed: " . $e->getMessage() . "\n";
}

echo "5. Testing instantiation...\n";
try {
    $uc = new \App\Controllers\UsuarioController();
    echo "SUCCESS: UsuarioController instantiated.\n";
} catch (\Exception $e) {
    echo "ERROR: Instantiation failed: " . $e->getMessage() . "\n";
}

echo "--- DIAGNOSTICS COMPLETE ---\n";
