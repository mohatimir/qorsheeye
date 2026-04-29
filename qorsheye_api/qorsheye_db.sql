-- ============================================================
-- Qorsheye Todo App - Full Production Database Schema
-- Version: 2.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS qorsheye_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE qorsheye_db;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id          INT(11)      UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(191) NOT NULL,
    password    VARCHAR(255) NOT NULL,              -- bcrypt hash
    avatar      VARCHAR(255) DEFAULT NULL,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_is_active (is_active)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: auth_tokens  (server-side session tokens)
-- ============================================================
CREATE TABLE IF NOT EXISTS auth_tokens (
    id          INT(11)   UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT(11)   UNSIGNED NOT NULL,
    token       VARCHAR(64) NOT NULL,
    expires_at  DATETIME  NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_token (token),
    INDEX idx_token_user (user_id),
    CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: categories
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id          INT(11)      UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT(11)      UNSIGNED NOT NULL,
    name        VARCHAR(100) NOT NULL,
    color       VARCHAR(50)  NOT NULL DEFAULT '#2196F3',
    icon_code   INT(11)      NOT NULL DEFAULT 57672,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_cat_user (user_id),
    CONSTRAINT fk_cat_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: tasks
-- ============================================================
CREATE TABLE IF NOT EXISTS tasks (
    id          INT(11)      UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT(11)      UNSIGNED NOT NULL,
    category_id INT(11)      UNSIGNED DEFAULT NULL,
    title       VARCHAR(255) NOT NULL,
    description TEXT         DEFAULT NULL,
    priority    ENUM('Low','Medium','High')                              NOT NULL DEFAULT 'Medium',
    status      ENUM('Pending','In Progress','Completed','Overdue')     NOT NULL DEFAULT 'Pending',
    `repeat`    ENUM('None','Daily','Weekly','Monthly','Yearly')        NOT NULL DEFAULT 'None',
    due_date    DATETIME     DEFAULT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_task_user   (user_id),
    INDEX idx_task_status (status),
    INDEX idx_task_due    (due_date),
    INDEX idx_task_cat    (category_id),
    FULLTEXT INDEX ft_task_search (title, description),

    CONSTRAINT fk_task_user FOREIGN KEY (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_task_cat  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;
