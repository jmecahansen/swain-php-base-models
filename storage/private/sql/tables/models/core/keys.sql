-- data model (attribute, content element, reference attribute and/or reference content element) keys
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_model_keys_check_exclusions;
SET FOREIGN_KEY_CHECKS = 1;

-- model (attribute, content element, reference attribute and/or reference content element) key check exclusions
CREATE TABLE IF NOT EXISTS c_model_keys_check_exclusions (
    exclusion_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    excluded_key VARCHAR(175) NOT NULL,
    module_key VARCHAR(175),
    model_key VARCHAR(175) NOT NULL,
    model_type VARCHAR(175) NOT NULL,
    model_id BIGINT(64) UNSIGNED,
    PRIMARY KEY (exclusion_id),
    INDEX (excluded_key),
    INDEX (module_key),
    INDEX (model_key),
    INDEX (model_type),
    INDEX (model_id),
    UNIQUE KEY (excluded_key, module_key, model_key, model_type, model_id)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;