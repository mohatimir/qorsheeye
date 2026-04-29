<?php
/**
 * Auth Controller
 * Handles register, login, logout, me.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../models/UserModel.php';

class AuthController {

    // ----------------------------------------------------------------
    // POST /api/auth.php?action=register
    // ----------------------------------------------------------------
    public static function register(): void {
        $data   = getBody();
        $errors = [];

        // --- Validation ---
        $missing = validateRequired($data, ['name', 'email', 'password']);
        if ($missing) {
            error('Missing required fields: ' . implode(', ', $missing), 422);
        }

        $name     = trim($data['name']);
        $email    = strtolower(trim($data['email']));
        $password = $data['password'];

        if (strlen($name) < 2 || strlen($name) > 100) {
            $errors['name'] = 'Name must be 2–100 characters.';
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Invalid email address.';
        }
        if (strlen($password) < 8) {
            $errors['password'] = 'Password must be at least 8 characters.';
        }
        if ($errors) {
            error('Validation failed.', 422, $errors);
        }

        // --- Duplicate check ---
        if (UserModel::findByEmail($email)) {
            error('This email is already registered.', 409);
        }

        // --- Create user ---
        $userId = UserModel::create($name, $email, $password);
        $token  = createAuthToken($userId);
        $user   = UserModel::findById($userId);

        success([
            'token' => $token,
            'user'  => $user,
        ], 'Account created successfully.', 201);
    }

    // ----------------------------------------------------------------
    // POST /api/auth.php?action=login
    // ----------------------------------------------------------------
    public static function login(): void {
        $data    = getBody();
        $missing = validateRequired($data, ['email', 'password']);
        if ($missing) {
            error('Email and password are required.', 422);
        }

        $email    = strtolower(trim($data['email']));
        $password = $data['password'];

        $user = UserModel::findByEmail($email);

        // Constant-time failure to prevent user enumeration
        if (!$user || !UserModel::verifyPassword($password, $user['password'])) {
            error('Invalid email or password.', 401);
        }

        $token = createAuthToken((int) $user['id']);

        // Strip password from response
        unset($user['password']);

        success([
            'token' => $token,
            'user'  => $user,
        ], 'Login successful.');
    }

    // ----------------------------------------------------------------
    // POST /api/auth.php?action=google_login
    // ----------------------------------------------------------------
    public static function googleLogin(): void {
        $data    = getBody();
        $missing = validateRequired($data, ['idToken']);
        if ($missing) {
            error('Google ID token is required.', 422);
        }

        $idToken = $data['idToken'];

        // Verify the token with Google
        $verifyUrl = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);
        $response  = @file_get_contents($verifyUrl);
        
        if ($response === false) {
            error('Invalid Google ID token.', 401);
        }

        $payload = json_decode($response, true);
        if (!$payload || !isset($payload['email'])) {
            error('Failed to parse Google ID token.', 401);
        }

        // Verify audience (client ID)
        $expectedClientId = '944056758435-iu3s8deivqj52gme62c1estg0bj23u5l.apps.googleusercontent.com';
        if ($payload['aud'] !== $expectedClientId) {
            error('Google token was not issued for this app.', 401);
        }

        $email  = strtolower(trim($payload['email']));
        $name   = $payload['name'] ?? 'Google User';
        $avatar = $payload['picture'] ?? null;

        $user = UserModel::findByEmail($email);

        if (!$user) {
            // Auto-register
            $userId = UserModel::createGoogleUser($name, $email, $avatar);
            $user   = UserModel::findById($userId);
        } else {
            $userId = (int) $user['id'];
            // Optionally update avatar if missing
            if (empty($user['avatar']) && $avatar) {
                UserModel::update($userId, ['avatar' => $avatar]);
                $user['avatar'] = $avatar;
            }
        }

        $token = createAuthToken($userId);
        unset($user['password']);

        success([
            'token' => $token,
            'user'  => $user,
        ], 'Google Login successful.');
    }

    // ----------------------------------------------------------------
    // POST /api/auth.php?action=logout
    // ----------------------------------------------------------------
    public static function logout(): void {
        $token = getBearerToken();
        if ($token) {
            revokeToken($token);
        }
        success(null, 'Logged out successfully.');
    }

    // ----------------------------------------------------------------
    // GET /api/auth.php?action=me
    // ----------------------------------------------------------------
    public static function me(): void {
        $userId = requireAuth();
        $user   = UserModel::findById($userId);
        if (!$user) {
            error('User not found.', 404);
        }
        success($user, 'User profile retrieved.');
    }

    // ----------------------------------------------------------------
    // PATCH /api/auth.php?action=update_profile
    // ----------------------------------------------------------------
    public static function updateProfile(): void {
        $userId = requireAuth();
        $data   = getBody();

        $allowed = array_intersect_key($data, ['name' => 1, 'avatar' => 1]);
        if (empty($allowed)) {
            error('No updatable fields provided.', 422);
        }

        if (isset($allowed['name']) && (strlen($allowed['name']) < 2 || strlen($allowed['name']) > 100)) {
            error('Name must be 2–100 characters.', 422);
        }

        UserModel::update($userId, $allowed);
        $user = UserModel::findById($userId);
        success($user, 'Profile updated.');
    }
    // ----------------------------------------------------------------
    // PATCH /api/auth.php?action=change_password
    // ----------------------------------------------------------------
    public static function changePassword(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['old_password', 'new_password']);
        
        if ($missing) {
            error('Current and new passwords are required.', 422);
        }

        $user = UserModel::findByIdRaw($userId); // Need raw with password
        if (!$user || !UserModel::verifyPassword($data['old_password'], $user['password'])) {
            error('Current password is incorrect.', 401);
        }

        if (strlen($data['new_password']) < 8) {
            error('New password must be at least 8 characters.', 422);
        }

        UserModel::changePassword($userId, $data['new_password']);
        success(null, 'Password changed successfully.');
    }
}

// ================================================================
// Route dispatcher
// ================================================================
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

switch (true) {
    case ($action === 'register'        && $method === 'POST'):  AuthController::register(); break;
    case ($action === 'login'           && $method === 'POST'):  AuthController::login(); break;
    case ($action === 'google_login'    && $method === 'POST'):  AuthController::googleLogin(); break;
    case ($action === 'logout'          && $method === 'POST'):  AuthController::logout(); break;
    case ($action === 'me'              && $method === 'GET'):   AuthController::me(); break;
    case ($action === 'update_profile'  && $method === 'PATCH'): AuthController::updateProfile(); break;
    case ($action === 'change_password' && $method === 'PATCH'): AuthController::changePassword(); break;
    default: error("Unknown action: $action", 404);
}
