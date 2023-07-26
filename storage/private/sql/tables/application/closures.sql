-- application closures
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_closures;
SET FOREIGN_KEY_CHECKS = 1;

-- closures
CREATE TABLE IF NOT EXISTS c_closures (
    closure_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    closure_key VARCHAR(175) NOT NULL,
    closure_hash VARCHAR(255) NOT NULL,
    closure_string LONGTEXT NOT NULL,
    PRIMARY KEY (closure_id),
    INDEX (closure_key),
    UNIQUE KEY (closure_key, closure_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;