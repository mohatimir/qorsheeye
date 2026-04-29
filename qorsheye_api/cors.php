<?php
// Clear any output buffers
if (ob_get_level()) ob_end_clean();

// Set CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE, PUT, PATCH");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Max-Age: 86400");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Ensure subsequent output is JSON
header("Content-Type: application/json");
?>
