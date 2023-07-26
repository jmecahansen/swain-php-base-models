-- model upgrade (base -> base + contents)
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS m_%MODEL%_cnts;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_evnt_updt;
DROP TABLE IF EXISTS m_%MODEL%_cnts_elem;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_evnt_updt;
DROP TABLE IF EXISTS m_%MODEL%_cnts_elem_revs;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_evnt_updt;
SET FOREIGN_KEY_CHECKS = 1;

-- model contents
CREATE TABLE IF NOT EXISTS m_%MODEL%_cnts (
    content_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    %KEY%_id BIGINT(64) UNSIGNED NOT NULL,
    content_language CHAR(2) NOT NULL DEFAULT 'es',
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (content_id),
    INDEX (%KEY%_id),
    INDEX (content_language),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    FOREIGN KEY (%KEY%_id) REFERENCES m_%MODEL% (%KEY%_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_cnts_evnt_delt AFTER DELETE ON m_%MODEL%_cnts FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_cnts'
    AND model_id = OLD.content_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_evnt_updt AFTER UPDATE ON m_%MODEL%_cnts FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.content_id
    WHERE model_key = 'm_%MODEL%_cnts'
    AND model_id = OLD.content_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_insr AFTER INSERT ON m_%MODEL%_cnts FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE %KEY%_id = NEW.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_updt AFTER UPDATE ON m_%MODEL%_cnts FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE %KEY%_id = OLD.%KEY%_id;
END;

-- model content elements
CREATE TABLE IF NOT EXISTS m_%MODEL%_cnts_elem (
    element_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    content_id BIGINT(64) UNSIGNED NOT NULL,
    element_key VARCHAR(175) NOT NULL,
    element_value LONGTEXT,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (element_id),
    INDEX (content_id),
    INDEX (element_key),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    UNIQUE KEY (content_id, element_key),
    FOREIGN KEY (content_id) REFERENCES m_%MODEL%_cnts (content_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_cnts_elem_evnt_delt AFTER DELETE ON m_%MODEL%_cnts_elem FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_cnts_elem'
    AND model_id = OLD.element_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_evnt_updt AFTER UPDATE ON m_%MODEL%_cnts_elem FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.element_id
    WHERE model_key = 'm_%MODEL%_cnts_elem'
    AND model_id = OLD.element_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_insr AFTER INSERT ON m_%MODEL%_cnts_elem FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE content_id = NEW.content_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_updt AFTER UPDATE ON m_%MODEL%_cnts_elem FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE content_id = OLD.content_id;
END;

-- model content element revisions
CREATE TABLE IF NOT EXISTS m_%MODEL%_cnts_elem_revs (
    revision_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    element_id BIGINT(64) UNSIGNED NOT NULL,
    element_key VARCHAR(175) NOT NULL,
    element_value LONGTEXT,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (revision_id),
    INDEX (element_id),
    INDEX (element_key),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    UNIQUE KEY (element_id, element_key),
    FOREIGN KEY (element_id) REFERENCES m_%MODEL%_cnts_elem (element_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_cnts_elem_revs_evnt_delt AFTER DELETE ON m_%MODEL%_cnts_elem_revs FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_cnts_elem_revs'
    AND model_id = OLD.revision_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_revs_evnt_updt AFTER UPDATE ON m_%MODEL%_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.revision_id
    WHERE model_key = 'm_%MODEL%_cnts_elem_revs'
    AND model_id = OLD.revision_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_revs_insr AFTER INSERT ON m_%MODEL%_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts_elem
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE element_id = NEW.element_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_revs_updt AFTER UPDATE ON m_%MODEL%_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts_elem
    SET date_modified = CURRENT_DATE(), date_modified_timezone = @@session.time_zone
    WHERE element_id = OLD.element_id;
END;