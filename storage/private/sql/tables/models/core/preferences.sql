-- data model preferences
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_preferences_model;
DROP TABLE IF EXISTS c_preferences_model_defaults;
SET FOREIGN_KEY_CHECKS = 1;

-- data model preferences
CREATE TABLE IF NOT EXISTS c_preferences_model (
    preference_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    model_key VARCHAR(175) NOT NULL,
    preference_key VARCHAR(175) NOT NULL,
    preference_value LONGTEXT,
    PRIMARY KEY (preference_id),
    INDEX (model_key),
    INDEX (preference_key),
    UNIQUE KEY (model_key, preference_key)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- data model preferences defaults
CREATE TABLE IF NOT EXISTS c_preferences_model_defaults (
    default_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    model_key VARCHAR(175) NOT NULL,
    preference_key VARCHAR(175) NOT NULL,
    preference_value LONGTEXT,
    PRIMARY KEY (default_id),
    INDEX (model_key),
    INDEX (preference_key),
    UNIQUE KEY (model_key, preference_key)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;