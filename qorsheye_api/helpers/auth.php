<?php
/**
 * Authentication Helpers
 * Uses server-side opaque tokens stored in auth_tokens table.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/response.php';

/**
 * Generate a cryptographically secure token.
 */
function generateToken(): string {
    return bin2hex(random_bytes(32)); // 64-char hex string
}

/**
 * Create and persist a new token for a user.
 * Returns the token string.
 */
function createAuthToken(int $userId): string {
    $db    = getDB();
    $token = generateToken();
    $exp   = date('Y-m-d H:i:s', strtotime('+' . TOKEN_EXPIRY_HOURS . ' hours'));

    $stmt = $db->prepare(
        'INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
    );
    $stmt->execute([$userId, $token, $exp]);
    return $token;
}

/**
 * Extract the Bearer token from Authorization header.
 */
function getBearerToken(): ?string {
    $header = $_SERVER['HTTP_AUTHORIZATION']
           ?? apache_request_headers()['Authorization']
           ?? '';

    if (preg_match('/Bearer\s+(\S+)/i', $header, $m)) {
        return $m[1];
    }
    return null;
}

/**
 * Validate token and return the user_id.
 * Returns null if invalid / expired.
 */
function validateToken(string $token): ?int {
    $db   = getDB();
    $stmt = $db->prepare(
        'SELECT user_id, expires_at FROM auth_tokens WHERE token = ? LIMIT 1'
    );
    $stmt->execute([$token]);
    $row = $stmt->fetch();

    if (!$row) return null;
    if (strtotime($row['expires_at']) < time()) {
        // Clean up expired token
        $db->prepare('DELETE FROM auth_tokens WHERE token = ?')->execute([$token]);
        return null;
    }
    return (int) $row['user_id'];
}

/**
 * Middleware: require valid auth token.
 * Returns the authenticated user_id or exits with 401.
 */
function requireAuth(): int {
    $token = getBearerToken();
    if (!$token) {
        error('Authentication required. Provide a Bearer token.', 401);
    }
    $userId = validateToken($token);
    if (!$userId) {
        error('Invalid or expired token. Please login again.', 401);
    }
    return $userId;
}

/**
 * Revoke a specific token.
 */
function revokeToken(string $token): void {
    $db = getDB();
    $db->prepare('DELETE FROM auth_tokens WHERE token = ?')->execute([$token]);
}

/**
 * Revoke all tokens for a user (logout everywhere).
 */
function revokeAllTokens(int $userId): void {
    $db = getDB();
    $db->prepare('DELETE FROM auth_tokens WHERE user_id = ?')->execute([$userId]);
}
