-- MySQL extended date & time routines
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
DROP FUNCTION IF EXISTS F_ADD_DURATION;
DROP FUNCTION IF EXISTS F_CENTURY;
DROP FUNCTION IF EXISTS F_DECADE;
DROP FUNCTION IF EXISTS F_FORTNIGHT;
DROP FUNCTION IF EXISTS F_LUSTRUM;
DROP FUNCTION IF EXISTS F_MILLENNIUM;
DROP FUNCTION IF EXISTS F_QUADMESTER;
DROP FUNCTION IF EXISTS F_SEMESTER;
DROP FUNCTION IF EXISTS F_SUBTRACT_DURATION;

-- F_ADD_DURATION
-- adds a given duration (in ISO 8601 format) to a given DATETIME value
CREATE FUNCTION F_ADD_DURATION(d DATETIME, p VARCHAR(45), t VARCHAR(45)) RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE ts VARCHAR(45) DEFAULT '';
    DECLARE x INTEGER;

    IF d IS NULL OR p IS NULL OR LENGTH(p) = 0 THEN
        RETURN d;
    END IF;

    IF t IS NOT NULL THEN SET d = CONVERT_TZ(d, 'UTC', t); END IF;

    IF p REGEXP '^P[0-9]+W$' THEN
        SET d = DATE_ADD(d, INTERVAL SUBSTR(p, 2, LENGTH(p) - 2) WEEK);
        RETURN IF(t IS NULL, d, CONVERT_TZ(d, t, 'UTC'));
    END IF;

    IF p NOT REGEXP '^P([0-9]+Y)?([0-9]+M)?([0-9]+D)?(T([0-9]+H)?([0-9]+M)?([0-9]+S)?)?$' THEN
        RETURN NULL;
    END IF;

    SET x = LOCATE('T', p);
    IF x <> 0 THEN
        SET ts = SUBSTR(p, x + 1);
        SET p = SUBSTR(p, 2, x);
    ELSE
        SET p = SUBSTR(p, 2);
    END IF ;

    SET x = LOCATE('Y', p);
    IF x <> 0 THEN
        SET d = DATE_ADD(d, INTERVAL SUBSTR(p, 1, x - 1) YEAR);
        SET p = SUBSTR(p, x + 1);
    END IF;

    SET x = LOCATE('M', p);
    IF x <> 0 THEN
        SET d = DATE_ADD(d, INTERVAL SUBSTR(p, 1, x - 1) MONTH);
        SET p = SUBSTR(p, x + 1);
    END IF;

    SET x = LOCATE('D', p);
    IF x <> 0 THEN
        SET d = DATE_ADD(d, INTERVAL SUBSTR(p, 1, x - 1) DAY);
    END IF;

    IF LENGTH(ts) <> 0 THEN
        SET x = LOCATE('H', ts);
        IF x <> 0 THEN
            SET d = DATE_ADD(d, INTERVAL SUBSTR(ts, 1, x - 1) HOUR);
            SET ts = SUBSTR(ts, x + 1);
        END IF;

        SET x = LOCATE('M', ts);
        IF x <> 0 THEN
            SET d = DATE_ADD(d, INTERVAL SUBSTR(ts, 1, x - 1) MINUTE);
            SET ts = SUBSTR(ts, x + 1);
        END IF;

        SET x = LOCATE('S', ts);
        IF x <> 0 THEN
            SET d = DATE_ADD(d, INTERVAL SUBSTR(ts, 1, x - 1) SECOND);
            SET ts = SUBSTR(ts, x + 1);
        END IF;
    END IF ;

    RETURN IF(t IS NULL, d, CONVERT_TZ(d, t, 'UTC'));
END;

-- F_CENTURY
-- calculate the absolute (from year 0) century number
CREATE FUNCTION F_CENTURY(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN (YEAR(d) / 100) + 1;

-- F_DECADE
-- calculate the absolute (from year 0) decade number
CREATE FUNCTION F_DECADE(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN FLOOR(YEAR(d) / 10) + 1;

-- F_FORTNIGHT
-- calculate the absolute (from year 0) fortnight
CREATE FUNCTION F_FORTNIGHT(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN (YEAR(d) << 4) + (YEAR(d) << 3) + (MONTH(d) << 1) - CASE WHEN DAY(d) > 15 THEN 0 ELSE 1 END;

-- F_LUSTRUM
-- calculate the absolute (from year 0) lustrum number
CREATE FUNCTION F_LUSTRUM(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN FLOOR(YEAR(d) / 5) + 1;

-- F_MILLENNIUM
-- calculate the absolute (from year 0) millennium number
CREATE FUNCTION F_MILLENNIUM(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN FLOOR(YEAR(d) / 1000) + 1;

-- F_QUADMESTER
-- calculate the absolute (from year 0) quadmester (academic term) number
CREATE FUNCTION F_QUADMESTER(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN (YEAR(d) << 1) + YEAR(d) + CASE WHEN MONTH(d) > 8 THEN 3 ELSE CASE WHEN MONTH(d) > 4 THEN 2 ELSE 1 END END;

-- F_SEMESTER
-- calculate the absolute (from year 0) semester number
CREATE FUNCTION F_SEMESTER(d DATETIME) RETURNS INT(11)
DETERMINISTIC
RETURN (YEAR(d) << 1) + CASE WHEN MONTH(d) > 6 THEN 2 ELSE 1 END;

-- F_SUBTRACT_DURATION
-- subtracts a given duration (in ISO 8601 format) to a given DATETIME value
CREATE FUNCTION F_SUBTRACT_DURATION(d DATETIME, p VARCHAR(45), t VARCHAR(45)) RETURNS DATETIME
    DETERMINISTIC
BEGIN
    DECLARE ts VARCHAR(45) DEFAULT '';
    DECLARE x INTEGER;

    IF d IS NULL OR p IS NULL OR LENGTH(p) = 0 THEN
        RETURN d;
    END IF;

    IF t IS NOT NULL THEN SET d = CONVERT_TZ(d, 'UTC', t); END IF;

    IF p REGEXP '^P[0-9]+W$' THEN
        SET d = DATE_SUB(d, INTERVAL SUBSTR(p, 2, LENGTH(p) - 2) WEEK);
        RETURN IF(t IS NULL, d, CONVERT_TZ(d, t, 'UTC'));
    END IF;

    IF p NOT REGEXP '^P([0-9]+Y)?([0-9]+M)?([0-9]+D)?(T([0-9]+H)?([0-9]+M)?([0-9]+S)?)?$' THEN
        RETURN NULL;
    END IF;

    SET x = LOCATE('T', p);
    IF x <> 0 THEN
        SET ts = SUBSTR(p, x + 1);
        SET p = SUBSTR(p, 2, x);
    ELSE
        SET p = SUBSTR(p, 2);
    END IF ;

    SET x = LOCATE('Y', p);
    IF x <> 0 THEN
        SET d = DATE_SUB(d, INTERVAL SUBSTR(p, 1, x - 1) YEAR);
        SET p = SUBSTR(p, x + 1);
    END IF;

    SET x = LOCATE('M', p);
    IF x <> 0 THEN
        SET d = DATE_SUB(d, INTERVAL SUBSTR(p, 1, x - 1) MONTH);
        SET p = SUBSTR(p, x + 1);
    END IF;

    SET x = LOCATE('D', p);
    IF x <> 0 THEN
        SET d = DATE_SUB(d, INTERVAL SUBSTR(p, 1, x - 1) DAY);
    END IF;

    IF LENGTH(ts) <> 0 THEN
        SET x = LOCATE('H', ts);
        IF x <> 0 THEN
            SET d = DATE_SUB(d, INTERVAL SUBSTR(ts, 1, x - 1) HOUR);
            SET ts = SUBSTR(ts, x + 1);
        END IF;

        SET x = LOCATE('M', ts);
        IF x <> 0 THEN
            SET d = DATE_SUB(d, INTERVAL SUBSTR(ts, 1, x - 1) MINUTE);
            SET ts = SUBSTR(ts, x + 1);
        END IF;

        SET x = LOCATE('S', ts);
        IF x <> 0 THEN
            SET d = DATE_SUB(d, INTERVAL SUBSTR(ts, 1, x - 1) SECOND);
            SET ts = SUBSTR(ts, x + 1);
        END IF;
    END IF ;

    RETURN IF(t IS NULL, d, CONVERT_TZ(d, t, 'UTC'));
END;