-- data model events
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_events;
DROP TABLE IF EXISTS c_events_defaults;
SET FOREIGN_KEY_CHECKS = 1;

-- data model events
CREATE TABLE IF NOT EXISTS c_events (
    event_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    status_id BIGINT(64) UNSIGNED NOT NULL DEFAULT 1,
    event_type VARCHAR(10) NOT NULL,
    model_key VARCHAR(175) NOT NULL,
    model_id BIGINT(64) UNSIGNED NOT NULL,
    event_name VARCHAR(175) NOT NULL,
    event_function LONGTEXT,
    event_function_hash VARCHAR(255) NOT NULL,
    PRIMARY KEY (event_id),
    INDEX (status_id),
    INDEX (event_type),
    INDEX (model_key),
    INDEX (model_id),
    INDEX (event_name),
    UNIQUE KEY (model_key, model_id, event_type, event_name, event_function_hash)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- data model event defaults
CREATE TABLE IF NOT EXISTS c_events_defaults (
    default_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    status_id BIGINT(64) UNSIGNED NOT NULL DEFAULT 1,
    event_type VARCHAR(10) NOT NULL,
    model_key VARCHAR(175) NOT NULL,
    event_name VARCHAR(175) NOT NULL,
    event_function LONGTEXT,
    event_function_hash VARCHAR(255) NOT NULL,
    PRIMARY KEY (default_id),
    INDEX (status_id),
    INDEX (event_type),
    INDEX (model_key),
    INDEX (event_name),
    UNIQUE KEY (model_key, event_type, event_name, event_function_hash)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;