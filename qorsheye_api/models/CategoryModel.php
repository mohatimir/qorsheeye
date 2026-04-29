<?php
/**
 * Category Model
 * All operations are scoped to user_id.
 */

require_once __DIR__ . '/../config/database.php';

class CategoryModel {

    public static function getAllForUser(int $userId): array {
        $db   = getDB();
        $stmt = $db->prepare(
            'SELECT * FROM categories WHERE user_id = ? ORDER BY name ASC'
        );
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }

    public static function findByIdAndUser(int $id, int $userId): array|false {
        $db   = getDB();
        $stmt = $db->prepare(
            'SELECT * FROM categories WHERE id = ? AND user_id = ? LIMIT 1'
        );
        $stmt->execute([$id, $userId]);
        return $stmt->fetch();
    }

    public static function create(int $userId, array $data): int {
        $db   = getDB();
        $stmt = $db->prepare(
            'INSERT INTO categories (user_id, name, color, icon_code) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([
            $userId,
            $data['name'],
            $data['color']     ?? '#2196F3',
            $data['icon_code'] ?? 57672,
        ]);
        return (int) $db->lastInsertId();
    }

    public static function update(int $id, int $userId, array $data): bool {
        $db   = getDB();
        $stmt = $db->prepare(
            'UPDATE categories SET name = ?, color = ?, icon_code = ?
             WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['name'],
            $data['color']     ?? '#2196F3',
            $data['icon_code'] ?? 57672,
            $id,
            $userId,
        ]);
        return $stmt->rowCount() > 0;
    }

    public static function delete(int $id, int $userId): bool {
        $db   = getDB();
        $stmt = $db->prepare(
            'DELETE FROM categories WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([$id, $userId]);
        return $stmt->rowCount() > 0;
    }
}
