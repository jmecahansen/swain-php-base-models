-- application database
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_database_history;
DROP TABLE IF EXISTS c_database_locks;
DROP TABLE IF EXISTS c_database_sessions;
SET FOREIGN_KEY_CHECKS = 1;

-- database history
CREATE TABLE IF NOT EXISTS c_database_history (
    entry_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    parent_id BIGINT(64) UNSIGNED,
    entry_date DATETIME NOT NULL,
    entry_key VARCHAR(175) NOT NULL,
    entry_type INT(11) UNSIGNED NOT NULL,
    entry_data LONGBLOB NOT NULL,
    PRIMARY KEY (entry_id),
    INDEX (parent_id),
    INDEX (entry_date),
    INDEX (entry_key),
    INDEX (entry_type),
    UNIQUE KEY (entry_key),
    FOREIGN KEY (parent_id) REFERENCES c_database_history (entry_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- database locks
CREATE TABLE IF NOT EXISTS c_database_locks (
    lock_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    lock_date DATETIME NOT NULL, 
    lock_source VARCHAR(175),
    lock_table VARCHAR(175) NOT NULL,
    lock_row INT(11) NOT NULL,
    PRIMARY KEY (lock_id),
    INDEX (lock_date),
    INDEX (lock_source),
    INDEX (lock_table),
    INDEX (lock_row),
    UNIQUE KEY (lock_table, lock_row)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- database sessions
CREATE TABLE IF NOT EXISTS c_database_sessions (
    session_id VARCHAR(255) NOT NULL,
    session_access INT(11) NOT NULL, 
    session_data LONGTEXT NOT NULL,
    PRIMARY KEY (session_id),
    INDEX (session_access)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;