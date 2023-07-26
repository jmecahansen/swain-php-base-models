-- MySQL model routines
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
DROP PROCEDURE IF EXISTS P_DELETE_MODEL_REFERENCES;

-- P_DELETE_MODEL_REFERENCES
-- delete the references to a given model
DELIMITER //
CREATE PROCEDURE P_DELETE_MODEL_REFERENCES(m VARCHAR(175) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci, i BIGINT(64) UNSIGNED)
BEGIN
    DECLARE v TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL;
    DECLARE d TINYINT DEFAULT FALSE;
    DECLARE c CURSOR FOR (
        SELECT
        DISTINCT(CONCAT('DELETE FROM ', table_name, ' WHERE reference_source = \'', m, '\' AND reference_source_id = ', i, ';'))
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
        AND table_name <> CONCAT(m, '_refs')
        AND table_name LIKE '%_refs'
    );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET d = TRUE;
    OPEN c;
    x:
    LOOP
        FETCH c INTO v;
        IF d THEN
            LEAVE x;
        ELSE
            SET @q = v;
            PREPARE s FROM @q;
            EXECUTE s;
            DEALLOCATE PREPARE s;
        END IF;
    END LOOP;
    CLOSE c;
END//
DELIMITER ;