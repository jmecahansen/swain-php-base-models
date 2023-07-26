-- model with reference contents (base + contents + reference contents)
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS m_%MODEL%;
DROP TRIGGER IF EXISTS t_%MODEL%_delt_keys_chck_excl;
DROP TRIGGER IF EXISTS t_%MODEL%_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_evnt_updt;
DROP TABLE IF EXISTS m_%MODEL%_attr;
DROP TRIGGER IF EXISTS t_%MODEL%_attr_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_attr_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_attr_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_attr_updt;
DROP TABLE IF EXISTS m_%MODEL%_cnts;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_updt;
DROP TABLE IF EXISTS m_%MODEL%_cnts_elem;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_updt;
DROP TABLE IF EXISTS m_%MODEL%_cnts_elem_revs;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_cnts_elem_revs_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_attr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_attr_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_attr_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_attr_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_attr_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts_elem;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts_elem_revs;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_evnt_updt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_insr;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_updt;
SET FOREIGN_KEY_CHECKS = 1;

-- model
CREATE TABLE IF NOT EXISTS m_%MODEL% (
    %KEY%_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (%KEY%_id),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_delt_keys_chck_excl AFTER DELETE ON m_%MODEL% FOR EACH ROW
BEGIN
    DELETE FROM c_model_keys_check_exclusions
    WHERE model_key = 'm_%MODEL%'
    AND model_id = OLD.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_evnt_delt AFTER DELETE ON m_%MODEL% FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%'
    AND model_id = OLD.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_evnt_updt AFTER UPDATE ON m_%MODEL% FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.%KEY%_id
    WHERE model_key = 'm_%MODEL%'
    AND model_id = OLD.%KEY%_id;
END;

-- model attributes
CREATE TABLE IF NOT EXISTS m_%MODEL%_attr (
    attribute_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    %KEY%_id BIGINT(64) UNSIGNED NOT NULL,
    attribute_key VARCHAR(175) NOT NULL,
    attribute_value LONGTEXT,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (attribute_id),
    INDEX (%KEY%_id),
    INDEX (attribute_key),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    UNIQUE KEY (%KEY%_id, attribute_key),
    FOREIGN KEY (%KEY%_id) REFERENCES m_%MODEL% (%KEY%_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_attr_evnt_delt AFTER DELETE ON m_%MODEL%_attr FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_attr'
    AND model_id = OLD.attribute_id;
END;

CREATE TRIGGER t_%MODEL%_attr_evnt_updt AFTER UPDATE ON m_%MODEL%_attr FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.attribute_id
    WHERE model_key = 'm_%MODEL%_attr'
    AND model_id = OLD.attribute_id;
END;

CREATE TRIGGER t_%MODEL%_attr_insr AFTER INSERT ON m_%MODEL%_attr FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE %KEY%_id = NEW.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_attr_updt AFTER UPDATE ON m_%MODEL%_attr FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE %KEY%_id = OLD.%KEY%_id;
END;

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
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE %KEY%_id = NEW.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_updt AFTER UPDATE ON m_%MODEL%_cnts FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
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
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE content_id = NEW.content_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_updt AFTER UPDATE ON m_%MODEL%_cnts_elem FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE content_id = OLD.content_id;
END;

-- model content element revisions
CREATE TABLE IF NOT EXISTS m_%MODEL%_cnts_elem_revs (
    revision_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    element_id BIGINT(64) UNSIGNED NOT NULL,
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
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
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
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE element_id = NEW.element_id;
END;

CREATE TRIGGER t_%MODEL%_cnts_elem_revs_updt AFTER UPDATE ON m_%MODEL%_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_cnts_elem
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE element_id = OLD.element_id;
END;

-- model references
CREATE TABLE IF NOT EXISTS m_%MODEL%_refs (
    reference_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    %KEY%_id BIGINT(64) UNSIGNED NOT NULL,
    reference_source VARCHAR(175) NOT NULL,
    reference_source_id BIGINT(64) UNSIGNED,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (reference_id),
    INDEX (%KEY%_id),
    INDEX (reference_source),
    INDEX (reference_source_id),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    UNIQUE KEY (%KEY%_id, reference_source, reference_source_id),
    FOREIGN KEY (%KEY%_id) REFERENCES m_%MODEL% (%KEY%_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_refs_evnt_delt AFTER DELETE ON m_%MODEL%_refs FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_refs'
    AND model_id = OLD.reference_id;
END;

CREATE TRIGGER t_%MODEL%_refs_evnt_updt AFTER UPDATE ON m_%MODEL%_refs FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.reference_id
    WHERE model_key = 'm_%MODEL%_refs'
    AND model_id = OLD.reference_id;
END;

CREATE TRIGGER t_%MODEL%_refs_insr AFTER INSERT ON m_%MODEL%_refs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE %KEY%_id = NEW.%KEY%_id;
END;

CREATE TRIGGER t_%MODEL%_refs_updt AFTER UPDATE ON m_%MODEL%_refs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE %KEY%_id = OLD.%KEY%_id;
END;

-- model reference attributes
CREATE TABLE IF NOT EXISTS m_%MODEL%_refs_attr (
    attribute_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    reference_id BIGINT(64) UNSIGNED NOT NULL,
    attribute_key VARCHAR(175) NOT NULL,
    attribute_value LONGTEXT,
    date_added DATETIME NOT NULL,
    date_added_source VARCHAR(175),
    date_added_source_id BIGINT(64) UNSIGNED,
    date_added_timezone SMALLINT NOT NULL,
    date_modified DATETIME,
    date_modified_source VARCHAR(175),
    date_modified_source_id BIGINT(64) UNSIGNED,
    date_modified_timezone SMALLINT,
    PRIMARY KEY (attribute_id),
    INDEX (reference_id),
    INDEX (attribute_key),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    UNIQUE KEY (reference_id, attribute_key),
    FOREIGN KEY (reference_id) REFERENCES m_%MODEL%_refs (reference_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_refs_attr_evnt_delt AFTER DELETE ON m_%MODEL%_refs_attr FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_refs_attr'
    AND model_id = OLD.attribute_id;
END;

CREATE TRIGGER t_%MODEL%_refs_attr_evnt_updt AFTER UPDATE ON m_%MODEL%_refs_attr FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.attribute_id
    WHERE model_key = 'm_%MODEL%_refs_attr'
    AND model_id = OLD.attribute_id;
END;

CREATE TRIGGER t_%MODEL%_refs_attr_insr AFTER INSERT ON m_%MODEL%_refs_attr FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE reference_id = NEW.reference_id;
END;

CREATE TRIGGER t_%MODEL%_refs_attr_updt AFTER UPDATE ON m_%MODEL%_refs_attr FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE reference_id = OLD.reference_id;
END;

-- model reference contents
CREATE TABLE IF NOT EXISTS m_%MODEL%_refs_cnts (
    content_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    reference_id BIGINT(64) UNSIGNED NOT NULL,
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
    INDEX (reference_id),
    INDEX (content_language),
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    FOREIGN KEY (reference_id) REFERENCES m_%MODEL%_refs (reference_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_refs_cnts_evnt_delt AFTER DELETE ON m_%MODEL%_refs_cnts FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_refs_cnts'
    AND model_id = OLD.content_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_evnt_updt AFTER UPDATE ON m_%MODEL%_refs_cnts FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.content_id
    WHERE model_key = 'm_%MODEL%_refs_cnts'
    AND model_id = OLD.content_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_insr AFTER INSERT ON m_%MODEL%_refs_cnts FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE reference_id = NEW.reference_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_updt AFTER UPDATE ON m_%MODEL%_refs_cnts FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE reference_id = OLD.reference_id;
END;

-- model reference content elements
CREATE TABLE IF NOT EXISTS m_%MODEL%_refs_cnts_elem (
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
    FOREIGN KEY (content_id) REFERENCES m_%MODEL%_refs_cnts (content_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_evnt_delt AFTER DELETE ON m_%MODEL%_refs_cnts_elem FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_refs_cnts_elem'
    AND model_id = OLD.element_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_evnt_updt AFTER UPDATE ON m_%MODEL%_refs_cnts_elem FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.element_id
    WHERE model_key = 'm_%MODEL%_refs_cnts_elem'
    AND model_id = OLD.element_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_insr AFTER INSERT ON m_%MODEL%_refs_cnts_elem FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs_cnts
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE content_id = NEW.content_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_updt AFTER UPDATE ON m_%MODEL%_refs_cnts_elem FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs_cnts
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE content_id = OLD.content_id;
END;

-- model reference content element revisions
CREATE TABLE IF NOT EXISTS m_%MODEL%_refs_cnts_elem_revs (
    revision_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    element_id BIGINT(64) UNSIGNED NOT NULL,
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
    INDEX (date_added),
    INDEX (date_added_source),
    INDEX (date_added_source_id),
    INDEX (date_added_timezone),
    INDEX (date_modified),
    INDEX (date_modified_source),
    INDEX (date_modified_source_id),
    INDEX (date_modified_timezone),
    FOREIGN KEY (element_id) REFERENCES m_%MODEL%_refs_cnts_elem (element_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_revs_evnt_delt AFTER DELETE ON m_%MODEL%_refs_cnts_elem_revs FOR EACH ROW
BEGIN
    DELETE FROM c_events
    WHERE model_key = 'm_%MODEL%_refs_cnts_elem_revs'
    AND model_id = OLD.revision_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_revs_evnt_updt AFTER UPDATE ON m_%MODEL%_refs_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE c_events
    SET model_id = NEW.revision_id
    WHERE model_key = 'm_%MODEL%_refs_cnts_elem_revs'
    AND model_id = OLD.revision_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_revs_insr AFTER INSERT ON m_%MODEL%_refs_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs_cnts_elem
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE element_id = NEW.element_id;
END;

CREATE TRIGGER t_%MODEL%_refs_cnts_elem_revs_updt AFTER UPDATE ON m_%MODEL%_refs_cnts_elem_revs FOR EACH ROW
BEGIN
    UPDATE m_%MODEL%_refs_cnts_elem
    SET date_modified = CURRENT_TIMESTAMP, date_modified_timezone = @bigengine.time_zone_name
    WHERE element_id = OLD.element_id;
END;