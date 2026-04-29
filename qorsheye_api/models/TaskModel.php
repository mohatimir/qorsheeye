<?php
/**
 * Task Model
 * Handles all DB operations for the tasks table.
 * All queries are scoped to a specific user_id.
 */

require_once __DIR__ . '/../config/database.php';

class TaskModel {

    /**
     * Fetch all tasks for a user with optional filters.
     *
     * @param int    $userId
     * @param array  $filters  [status, priority, category_id, search, page, per_page, sort]
     */
    public static function getAllForUser(int $userId, array $filters = []) {
        $db     = getDB();
        $where  = ['t.user_id = ?'];
        $params = [$userId];

        // Filter by status
        if (!empty($filters['status'])) {
            $where[]  = 't.status = ?';
            $params[] = $filters['status'];
        }
        // Filter by priority
        if (!empty($filters['priority'])) {
            $where[]  = 't.priority = ?';
            $params[] = $filters['priority'];
        }
        // Filter by category
        if (!empty($filters['category_id'])) {
            $where[]  = 't.category_id = ?';
            $params[] = (int) $filters['category_id'];
        }
        // Full-text search on title + description
        if (!empty($filters['search'])) {
            $where[]  = '(t.title LIKE ? OR t.description LIKE ?)';
            $like     = '%' . $filters['search'] . '%';
            $params[] = $like;
            $params[] = $like;
        }

        $whereSQL = 'WHERE ' . implode(' AND ', $where);

        // Sorting
        $sortMap = [
            'due_date'   => 't.due_date ASC',
            'created_at' => 't.created_at DESC',
            'priority'   => "FIELD(t.priority,'High','Medium','Low')",
            'title'      => 't.title ASC',
        ];
        $sort    = $sortMap[$filters['sort'] ?? ''] ?? 't.due_date ASC';

        // Count total (for pagination)
        $countSQL  = "SELECT COUNT(*) FROM tasks t $whereSQL";
        $countStmt = $db->prepare($countSQL);
        $countStmt->execute($params);
        $total = (int) $countStmt->fetchColumn();

        // Pagination
        $perPage = max(1, min(100, (int)($filters['per_page'] ?? 20)));
        $page    = max(1, (int)($filters['page'] ?? 1));
        $offset  = ($page - 1) * $perPage;

        $sql = "SELECT t.*,
                       c.name  AS category_name,
                       c.color AS category_color,
                       c.icon_code AS category_icon_code
                FROM tasks t
                LEFT JOIN categories c ON t.category_id = c.id
                $whereSQL
                ORDER BY $sort
                LIMIT ? OFFSET ?";

        $params[] = $perPage;
        $params[] = $offset;

        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $tasks = $stmt->fetchAll();

        return [
            'tasks'      => $tasks,
            'total'      => $total,
            'page'       => $page,
            'per_page'   => $perPage,
            'last_page'  => (int) ceil($total / $perPage),
        ];
    }

    /**
     * Find a single task belonging to a user.
     */
    public static function findByIdAndUser(int $id, int $userId) {
        $db   = getDB();
        $stmt = $db->prepare(
            'SELECT t.*, c.name AS category_name, c.color AS category_color
             FROM tasks t
             LEFT JOIN categories c ON t.category_id = c.id
             WHERE t.id = ? AND t.user_id = ?
             LIMIT 1'
        );
        $stmt->execute([$id, $userId]);
        return $stmt->fetch();
    }

    /**
     * Create a new task.
     */
    public static function create(int $userId, array $data) {
        $db   = getDB();
        $stmt = $db->prepare(
            'INSERT INTO tasks (user_id, category_id, title, description, priority, status, `repeat`, due_date)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $userId,
            $data['category_id']  ?: null,
            $data['title'],
            $data['description']  ?? '',
            $data['priority']     ?? 'Medium',
            $data['status']       ?? 'Pending',
            $data['repeat']       ?? 'None',
            $data['due_date']     ?: null,
        ]);
        return (int) $db->lastInsertId();
    }

    /**
     * Update an existing task (must belong to user).
     */
    public static function update(int $id, int $userId, array $data) {
        $db   = getDB();
        $stmt = $db->prepare(
            'UPDATE tasks SET
                category_id  = ?,
                title        = ?,
                description  = ?,
                priority     = ?,
                status       = ?,
                `repeat`     = ?,
                due_date     = ?
             WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([
            $data['category_id']  ?: null,
            $data['title'],
            $data['description']  ?? '',
            $data['priority']     ?? 'Medium',
            $data['status']       ?? 'Pending',
            $data['repeat']       ?? 'None',
            $data['due_date']     ?: null,
            $id,
            $userId,
        ]);
        return $stmt->rowCount() > 0;
    }

    /**
     * Update only the status of a task.
     */
    public static function updateStatus(int $id, int $userId, string $status) {
        $db   = getDB();
        $stmt = $db->prepare(
            'UPDATE tasks SET status = ? WHERE id = ? AND user_id = ?'
        );
        $stmt->execute([$status, $id, $userId]);
        return $stmt->rowCount() > 0;
    }

    /**
     * Delete a task.
     */
    public static function delete(int $id, int $userId) {
        $db   = getDB();
        $stmt = $db->prepare('DELETE FROM tasks WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);
        return $stmt->rowCount() > 0;
    }

    /**
     * Get per-status counts for dashboard stats.
     */
    public static function getStatsByUser(int $userId) {
        $db   = getDB();
        $stmt = $db->prepare(
            "SELECT status, COUNT(*) AS cnt
             FROM tasks WHERE user_id = ?
             GROUP BY status"
        );
        $stmt->execute([$userId]);
        $rows   = $stmt->fetchAll();
        $stats  = ['Pending' => 0, 'In Progress' => 0, 'Completed' => 0, 'Overdue' => 0, 'total' => 0];
        foreach ($rows as $row) {
            $stats[$row['status']] = (int) $row['cnt'];
            $stats['total'] += (int) $row['cnt'];
        }
        return $stats;
    }
}
