# Qorsheye - Smart Task Management System
## Technical Documentation & Thesis Guide

This document serves as the comprehensive technical foundation for the **Qorsheye** application. It is specifically structured to provide all the necessary architectural, functional, and technological details required to write a university thesis or final year project book.

---

## 1. Introduction
**Qorsheye** is a modern, cross-platform Smart Task Management System designed to help users efficiently organize their daily routines, deadlines, and projects. It bridges the gap between simple to-do lists and complex project management tools by introducing intelligent features like automated priority suggestions and robust background notification scheduling.

## 2. System Architecture
The system operates on a **Client-Server (2-Tier) Architecture** utilizing a RESTful API communication approach.

### 2.1. Frontend (Client-Side)
*   **Framework:** Flutter (Dart)
*   **Platform Targets:** Android, iOS, Web, and Windows.
*   **State Management:** `Provider` pattern (ViewModel approach).
*   **Key Packages & Libraries:**
    *   `provider`: For reactive state management (`TaskProvider`, `AuthProvider`, `SettingsProvider`).
    *   `http`: For making RESTful API calls to the PHP backend.
    *   `flutter_local_notifications`: For background alarms and scheduled push notifications.
    *   `google_sign_in`: For OAuth 2.0 social authentication.
    *   `fl_chart`: For rendering dynamic dashboard analytics (Pie charts, Bar charts).
    *   `google_fonts`: For consistent typography (Inter font).
    *   `shared_preferences`: For persistent local storage of auth tokens and user settings.

### 2.2. Backend (Server-Side)
*   **Language:** PHP 8.x
*   **Architecture Pattern:** MVC (Model-View-Controller) structure optimized for API endpoints.
*   **Database:** MySQL (Relational Database Management System).
*   **Security:** 
    *   Custom Token-based Authentication.
    *   `password_hash()` utilizing the bcrypt algorithm for secure password storage.
    *   Google OAuth Token Verification (validating JWTs server-side via `oauth2.googleapis.com`).

---

## 3. Core Features & Functionality

### 3.1. Authentication Module
*   **Standard Login/Register:** Traditional email and encrypted password authentication.
*   **Google OAuth 2.0:** Users can bypass manual registration using a "Continue with Google" flow. The backend intercepts the Google ID token, verifies its authenticity, and automatically generates a secure database record.

### 3.2. Smart Priority Engine (AI-Inspired)
*   An intelligent text-parsing algorithm integrated directly into the `AddTaskScreen`.
*   As the user types a task title or description, the system analyzes the text for specific keywords.
*   *Mechanism:*
    *   **High Priority:** Triggered by words like "urgent", "deadline", "emergency", "doctor".
    *   **Medium Priority:** Triggered by words like "meeting", "call", "tomorrow".
    *   **Low Priority:** Default fallback for non-urgent phrases.

### 3.3. Advanced Notification System
*   **Background Scheduling:** Tasks with a set `due_date` are calculated in real-time, and a background alarm (`zonedSchedule`) is registered within the OS.
*   **Heads-Up Alerts:** High-priority system popup notifications appear precisely at the task deadline.
*   **Overdue Catch-up:** If the user reboots the device or misses a notification, the system calculates tasks that are `< 24 hours overdue` and issues an immediate catch-up alert (`show`).
*   **Permissions:** Integrates Android 14+ `USE_EXACT_ALARM`, `POST_NOTIFICATIONS`, and `WAKE_LOCK`.

### 3.4. Analytics Dashboard
*   A visually appealing dashboard summarizing user productivity.
*   Displays real-time metric cards (Total Tasks, Completed, Pending, Overdue).
*   Visualizes data using interactive pie-charts based on task categories.

---

## 4. Database Schema (MySQL)

The database `qorsheye_db` consists of three primary interconnected tables:

### 4.1. `users` Table
Stores user credentials and profile data.
*   `id` (PK, INT, Auto Increment)
*   `name` (VARCHAR)
*   `email` (VARCHAR, Unique)
*   `password_hash` (VARCHAR) - Stores bcrypt encrypted passwords.
*   `avatar_url` (VARCHAR) - URL for profile images (often fetched from Google).
*   `created_at`, `updated_at` (TIMESTAMP)

### 4.2. `categories` Table
Allows users to group tasks into custom folders with unique colors.
*   `id` (PK, INT, Auto Increment)
*   `user_id` (FK, INT) - Links to `users.id` (ON DELETE CASCADE)
*   `name` (VARCHAR)
*   `color` (VARCHAR) - Stores hex codes (e.g., "#FF0000").
*   `icon` (VARCHAR) - Stores Flutter icon string references.

### 4.3. `tasks` Table
The central data structure for user tasks.
*   `id` (PK, INT, Auto Increment)
*   `user_id` (FK, INT)
*   `category_id` (FK, INT) - (ON DELETE SET NULL)
*   `title` (VARCHAR)
*   `description` (TEXT)
*   `priority` (ENUM: 'Low', 'Medium', 'High')
*   `status` (ENUM: 'Pending', 'In Progress', 'Completed', 'Overdue')
*   `repeat` (ENUM: 'None', 'Daily', 'Weekly', 'Monthly', 'Yearly')
*   `due_date` (DATETIME) - Triggers the local notification engine.

---

## 5. UI / UX Design Philosophy
*   **Glassmorphism & Modern UI:** Utilizes translucent panels, drop shadows, and blurred backgrounds to create a premium, state-of-the-art aesthetic.
*   **Dark / Light Mode:** Fully dynamic theming controlled by `SettingsProvider`.
*   **Responsive Layout:** Adapts flawlessly to mobile screens, maintaining high visibility and touch-friendly targets.

## 6. Security Considerations (For Thesis Chapter)
*   **Data integrity:** Prepared SQL statements in PHP prevent SQL Injection attacks.
*   **Session Management:** Token-based stateless communication ensures that API endpoints cannot be accessed without an active, valid Bearer token.
*   **OAuth Safety:** Google tokens are verified server-side to prevent client-side token spoofing.

---
*Created for Academic Thesis Preparation. All technologies listed represent the actual production-ready implementation of the Qorsheye Application.*
