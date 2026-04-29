<?php
/**
 * User Model
 * Handles all DB operations for the users table.
 */

require_once __DIR__ . '/../config/database.php';

class UserModel {

    /**
     * Find a user by email.
     */
    public static function findByEmail(string $email) {
        $db   = getDB();
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ? AND is_active = 1 LIMIT 1');
        $stmt->execute([strtolower(trim($email))]);
        return $stmt->fetch();
    }

    /**
     * Find a user by ID (Internal use — includes password).
     */
    public static function findByIdRaw(int $id) {
        $db   = getDB();
        $stmt = $db->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1 LIMIT 1');
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    /**
     * Find a user by ID.
     */
    public static function findById(int $id) {
        $db   = getDB();
        $stmt = $db->prepare('SELECT id, name, email, avatar, created_at FROM users WHERE id = ? AND is_active = 1 LIMIT 1');
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    /**
     * Create a new user. Returns the new user ID.
     */
    public static function create(string $name, string $email, string $password): int {
        $db   = getDB();
        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        $stmt = $db->prepare(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)'
        );
        $stmt->execute([trim($name), strtolower(trim($email)), $hash]);
        return (int) $db->lastInsertId();
    }

    /**
     * Create a new user from Google Login. Returns the new user ID.
     */
    public static function createGoogleUser(string $name, string $email, string $avatar): int {
        $db   = getDB();
        // Generate a random impossible password for google users (since they auth via token)
        $password = bin2hex(random_bytes(16));
        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
        $stmt = $db->prepare(
            'INSERT INTO users (name, email, password, avatar) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([trim($name), strtolower(trim($email)), $hash, $avatar]);
        return (int) $db->lastInsertId();
    }

    /**
     * Verify a plain-text password against a stored hash.
     */
    public static function verifyPassword(string $plain, string $hash): bool {
        return password_verify($plain, $hash);
    }

    /**
     * Update user profile fields.
     */
    public static function update(int $id, array $fields): bool {
        $allowed = ['name', 'avatar'];
        $set     = [];
        $values  = [];

        foreach ($allowed as $col) {
            if (isset($fields[$col])) {
                $set[]    = "$col = ?";
                $values[] = $fields[$col];
            }
        }

        if (empty($set)) return false;

        $values[] = $id;
        $db       = getDB();
        $stmt     = $db->prepare('UPDATE users SET ' . implode(', ', $set) . ' WHERE id = ?');
        $stmt->execute($values);
        return $stmt->rowCount() > 0;
    }

    /**
     * Change user password.
     */
    public static function changePassword(int $id, string $newPassword): bool {
        $db   = getDB();
        $hash = password_hash($newPassword, PASSWORD_BCRYPT, ['cost' => 12]);
        $stmt = $db->prepare('UPDATE users SET password = ? WHERE id = ?');
        $stmt->execute([$hash, $id]);
        return $stmt->rowCount() > 0;
    }
}
