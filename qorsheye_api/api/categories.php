<?php
// --- START CORS & PREFLIGHT ---
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
// --- END CORS & PREFLIGHT ---

try {
    /**
     * Public API entry point — Categories
     * URL: /qorsheye_api/api/categories.php?action=...
     */
    require_once __DIR__ . '/../config/cors.php';
    header('Content-Type: application/json');
    require_once __DIR__ . '/../config/database.php';
    require_once __DIR__ . '/../helpers/response.php';
    require_once __DIR__ . '/../helpers/auth.php';
    require_once __DIR__ . '/../models/CategoryModel.php';
    require_once __DIR__ . '/../controllers/CategoryController.php';
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Critical Server Error',
        'detail' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    exit;
}
