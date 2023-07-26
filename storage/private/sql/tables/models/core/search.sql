-- data model search
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_search_history;
DROP TABLE IF EXISTS c_search_weight_entries;
DROP TABLE IF EXISTS c_search_weight_history;
DROP TRIGGER IF EXISTS t_search_weight_entries_insert;
SET FOREIGN_KEY_CHECKS = 1;

-- search history
CREATE TABLE IF NOT EXISTS c_search_history (
    entry_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    entry_date_added DATETIME NOT NULL,
    entry_language CHAR(2) NOT NULL DEFAULT 'es',
    entry_query TEXT NOT NULL,
    PRIMARY KEY (entry_id),
    INDEX (entry_date_added),
    INDEX (entry_language)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- search weight entries
CREATE TABLE IF NOT EXISTS c_search_weight_entries (
    entry_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    entry_date DATETIME NOT NULL,
    entry_model VARCHAR(175) NOT NULL,
    entry_model_id BIGINT(64) UNSIGNED NOT NULL,
    entry_value DOUBLE NOT NULL,
    PRIMARY KEY (entry_id),
    INDEX (entry_date),
    INDEX (entry_model),
    INDEX (entry_model_id),
    INDEX (entry_value)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- search weight entry history
CREATE TABLE IF NOT EXISTS c_search_weight_entries_history (
    entry_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    entry_date DATETIME NOT NULL,
    entry_model VARCHAR(175) NOT NULL,
    entry_model_id BIGINT(64) UNSIGNED,
    entry_value DOUBLE NOT NULL,
    PRIMARY KEY (entry_id),
    INDEX (entry_date),
    INDEX (entry_model),
    INDEX (entry_model_id),
    INDEX (entry_value)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_search_weight_entries_insert AFTER INSERT ON c_search_weight_entries FOR EACH ROW
BEGIN
    INSERT INTO c_search_weight_entries_history (entry_date, entry_model, entry_model_id, entry_value) VALUES (NOW(), NEW.entry_model, NEW.entry_model_id, NEW.entry_value);
END;