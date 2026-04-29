<?php
/**
 * Response Helpers
 */

/**
 * Send a success JSON response.
 */
function success(array|null $data = null, string $message = 'OK', int $code = 200): void {
    http_response_code($code);
    $payload = ['status' => 'success', 'message' => $message];
    if ($data !== null) {
        $payload['data'] = $data;
    }
    echo json_encode($payload);
    exit;
}

/**
 * Send an error JSON response.
 */
function error(string $message, int $code = 200, array $errors = []): void {
    http_response_code($code);
    $payload = ['status' => 'error', 'message' => $message];
    if (!empty($errors)) {
        $payload['errors'] = $errors;
    }
    echo json_encode($payload);
    exit;
}

/**
 * Parse and return JSON body from php://input.
 */
function getBody(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

/**
 * Validate required fields in an array.
 * Returns array of missing field names.
 */
function validateRequired(array $data, array $fields): array {
    $missing = [];
    foreach ($fields as $field) {
        if (!isset($data[$field]) || trim((string)$data[$field]) === '') {
            $missing[] = $field;
        }
    }
    return $missing;
}
