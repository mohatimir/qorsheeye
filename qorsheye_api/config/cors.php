<?php
/**
 * CORS Configuration
 * Handles cross-origin requests for the Flutter app.
 */

// CORS handled by .htaccess for consistency and to avoid duplication.
// Only keep the logic if you are not using .htaccess mod_headers.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
