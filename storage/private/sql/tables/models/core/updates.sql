-- data model updates
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_model_updates;
SET FOREIGN_KEY_CHECKS = 1;

-- model updates
CREATE TABLE IF NOT EXISTS c_model_updates (
    update_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    model_key VARCHAR(175) NOT NULL,
    model_id BIGINT(64) UNSIGNED NOT NULL,
    date_added DATETIME NOT NULL,
    date_added_timezone SMALLINT NOT NULL,
    PRIMARY KEY (update_id),
    INDEX (model_key),
    INDEX (model_id),
    INDEX (date_added),
    INDEX (date_added_timezone),
    UNIQUE KEY (model_key, model_id, date_added, date_added_timezone)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;