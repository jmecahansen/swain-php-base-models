-- MySQL extended strings routines
-- Author: Julio María Meca Hansen <julio@meca-innotech.com>

-- bootstrapping
DROP FUNCTION IF EXISTS F_DOUBLE_METAPHONE;
DROP FUNCTION IF EXISTS F_JARO_WINKLER;
DROP FUNCTION IF EXISTS F_LEVENSHTEIN;
DROP FUNCTION IF EXISTS F_LEVENSHTEIN_RATIO;
DROP FUNCTION IF EXISTS F_NORMALIZE_STRING;
DROP FUNCTION IF EXISTS F_STRIP_TAGS;
DROP FUNCTION IF EXISTS F_UNACCENT;

-- F_DOUBLE_METAPHONE
-- returns the phonetic index of a given string for comparison (A sounds like B)
DELIMITER //
CREATE FUNCTION F_DOUBLE_METAPHONE(st VARCHAR(55) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS VARCHAR(128) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci
NO SQL
BEGIN
    DECLARE length, first, last, pos, prevpos, is_slavo_germanic SMALLINT;
    DECLARE pri, sec VARCHAR(45) DEFAULT '';
    DECLARE ch CHAR(1);
    SET first = 3;
    SET length = CHAR_LENGTH(st);
    SET last = first + length -1;
    SET st = CONCAT(REPEAT('-', first -1), UCASE(st), REPEAT(' ', 5));
    SET is_slavo_germanic = (st LIKE '%W%' OR st LIKE '%K%' OR st LIKE '%CZ%');
    SET pos = first;
    IF SUBSTRING(st, first, 2) IN ('GN', 'KN', 'PN', 'WR', 'PS') THEN
        SET pos = pos + 1;
    END IF;
    IF SUBSTRING(st, first, 1) = 'X' THEN
        SET pri = 'S', sec = 'S', pos = pos + 1;
    END IF;
    WHILE pos <= last DO
        SET prevpos = pos;
        SET ch = SUBSTRING(st, pos, 1);
        CASE
            WHEN ch IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
            IF pos = first THEN
                SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'A'), pos = pos + 1;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'B' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'B' THEN
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos + 1;
            END IF;
            WHEN ch = 'C' THEN
            IF (pos > (first + 1) AND SUBSTRING(st, pos - 2, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y') AND SUBSTRING(st, pos - 1, 3) = 'ACH' AND (SUBSTRING(st, pos + 2, 1) NOT IN ('I', 'E') OR SUBSTRING(st, pos - 2, 6) IN ('BACHER', 'MACHER'))) THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSEIF pos = first AND SUBSTRING(st, first, 6) = 'CAESAR' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos, 4) = 'CHIA' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos, 2) = 'CH' THEN
                IF pos > first AND SUBSTRING(st, pos, 4) = 'CHAE' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'X'), pos = pos + 2;
                ELSEIF pos = first AND (SUBSTRING(st, pos + 1, 5) IN ('HARAC', 'HARIS') OR SUBSTRING(st, pos + 1, 3) IN ('HOR', 'HYM', 'HIA', 'HEM')) AND SUBSTRING(st, first, 5) <> 'CHORE' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                ELSEIF SUBSTRING(st, first, 4) IN ('VAN ', 'VON ') OR SUBSTRING(st, first, 3) = 'SCH' OR SUBSTRING(st, pos - 2, 6) IN ('ORCHES', 'ARCHIT', 'ORCHID') OR SUBSTRING(st, pos + 2, 1) IN ('T', 'S') OR ((SUBSTRING(st, pos - 1, 1) IN ('A', 'O', 'U', 'E') OR pos = first) AND SUBSTRING(st, pos + 2, 1) IN ('L', 'R', 'N', 'M', 'B', 'H', 'F', 'V', 'W', ' ')) THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                ELSE
                    IF pos > first THEN
                        IF SUBSTRING(st, first, 2) = 'MC' THEN
                            SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                        ELSE
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                        END IF;
                    ELSE
                        SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 2;
                    END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos, 2) = 'CZ' AND SUBSTRING(st, pos - 2, 4) <> 'WICZ' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos + 1, 3) = 'CIA' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 3;
            ELSEIF SUBSTRING(st, pos, 2) = 'CC' AND NOT (pos = (first +1) AND SUBSTRING(st, first, 1) = 'M') THEN
                IF SUBSTRING(st, pos + 2, 1) IN ('I', 'E', 'H') AND SUBSTRING(st, pos + 2, 2) <> 'HU' THEN
                    IF (pos = first +1 AND SUBSTRING(st, first) = 'A') OR SUBSTRING(st, pos - 1, 5) IN ('UCCEE', 'UCCES') THEN
                        SET pri = CONCAT(pri, 'KS'), sec = CONCAT(sec, 'KS'), pos = pos + 3;
                    ELSE
                        SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 3;
                    END IF;
                ELSE
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                END IF;
            ELSEIF SUBSTRING(st, pos, 2) IN ('CK', 'CG', 'CQ') THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos, 2) IN ('CI', 'CE', 'CY') THEN
                IF SUBSTRING(st, pos, 3) IN ('CIO', 'CIE', 'CIA') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos + 2;
                ELSE
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos + 2;
                END IF;
            ELSE
                IF SUBSTRING(st, pos + 1, 2) IN (' C', ' Q', ' G') THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 3;
                ELSE
                    IF SUBSTRING(st, pos + 1, 1) IN ('C', 'K', 'Q') AND SUBSTRING(st, pos + 1, 2) NOT IN ('CE', 'CI') THEN
                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                    ELSE
                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 1;
                    END IF;
                END IF;
            END IF;
            WHEN ch = 'D' THEN
            IF SUBSTRING(st, pos, 2) = 'DG' THEN
                IF SUBSTRING(st, pos + 2, 1) IN ('I', 'E', 'Y') THEN
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos + 3;
                ELSE
                    SET pri = CONCAT(pri, 'TK'), sec = CONCAT(sec, 'TK'), pos = pos + 2;
                END IF;
            ELSEIF SUBSTRING(st, pos, 2) IN ('DT', 'DD') THEN
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos + 1;
            END IF;
            WHEN ch = 'F' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'F' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 1;
            END IF;
            WHEN ch = 'G' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'H' THEN
                IF (pos > first AND SUBSTRING(st, pos - 1, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y')) OR ( pos = first AND SUBSTRING(st, pos + 2, 1) <> 'I') THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                ELSEIF pos = first AND SUBSTRING(st, pos + 2, 1) = 'I' THEN
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos + 2;
                ELSEIF (pos > (first + 1) AND SUBSTRING(st, pos - 2, 1) IN ('B', 'H', 'D')) OR (pos > (first + 2) AND SUBSTRING(st, pos - 3, 1) IN ('B', 'H', 'D')) OR (pos > (first + 3) AND SUBSTRING(st, pos - 4, 1) IN ('B', 'H')) THEN
                    SET pos = pos + 2;
                ELSE
                    IF pos > (first + 2) AND SUBSTRING(st, pos - 1, 1) = 'U' AND SUBSTRING(st, pos - 3, 1) IN ('C', 'G', 'L', 'R', 'T') THEN
                        SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 2;
                    ELSEIF pos > first AND SUBSTRING(st, pos - 1, 1) <> 'I' THEN
                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                    ELSE
                        SET pos = pos + 1;
                    END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos + 1, 1) = 'N' THEN
                IF pos = (first +1) AND SUBSTRING(st, first, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') AND NOT is_slavo_germanic THEN
                    SET pri = CONCAT(pri, 'KN'), sec = CONCAT(sec, 'N'), pos = pos + 2;
                ELSE
                    IF SUBSTRING(st, pos + 2, 2) <> 'EY' AND SUBSTRING(st, pos + 1, 1) <> 'Y'
                       AND NOT is_slavo_germanic THEN
                        SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'KN'), pos = pos + 2;
                    ELSE
                        SET pri = CONCAT(pri, 'KN'), sec = CONCAT(sec, 'KN'), pos = pos + 2;
                    END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos + 1, 2) = 'LI' AND NOT is_slavo_germanic THEN
                SET pri = CONCAT(pri, 'KL'), sec = CONCAT(sec, 'L'), pos = pos + 2;
            ELSEIF pos = first AND (SUBSTRING(st, pos + 1, 1) = 'Y' OR SUBSTRING(st, pos + 1, 2) IN ('ES', 'EP', 'EB', 'EL', 'EY', 'IB', 'IL', 'IN', 'IE', 'EI', 'ER')) THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'J'), pos = pos + 2;
            ELSEIF (SUBSTRING(st, pos + 1, 2) = 'ER' OR SUBSTRING(st, pos + 1, 1) = 'Y') AND SUBSTRING(st, first, 6) NOT IN ('DANGER', 'RANGER', 'MANGER') AND SUBSTRING(st, pos - 1, 1) NOT IN ('E', 'I') AND SUBSTRING(st, pos - 1, 3) NOT IN ('RGY', 'OGY') THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'J'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos + 1, 1) IN ('E', 'I', 'Y') OR SUBSTRING(st, pos - 1, 4) IN ('AGGI', 'OGGI') THEN
                IF SUBSTRING(st, first, 4) IN ('VON ', 'VAN ') OR SUBSTRING(st, first, 3) = 'SCH' OR SUBSTRING(st, pos + 1, 2) = 'ET' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                ELSE
                    IF SUBSTRING(st, pos + 1, 4) = 'IER ' THEN
                        SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos + 2;
                    ELSE
                        SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'K'), pos = pos + 2;
                    END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos + 1, 1) = 'G' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 1;
            END IF;
            WHEN ch = 'H' THEN
            IF (pos = first OR SUBSTRING(st, pos - 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y')) AND SUBSTRING(st, pos + 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
                SET pri = CONCAT(pri, 'H'), sec = CONCAT(sec, 'H'), pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'J' THEN
            IF SUBSTRING(st, pos, 4) = 'JOSE' OR SUBSTRING(st, first, 4) = 'SAN ' THEN
                IF (pos = first AND SUBSTRING(st, pos + 4, 1) = ' ') OR SUBSTRING(st, first, 4) = 'SAN ' THEN
                    SET pri = CONCAT(pri, 'H'), sec = CONCAT(sec, 'H');
                ELSE
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'H');
                END IF;
            ELSEIF pos = first AND SUBSTRING(st, pos, 4) <> 'JOSE' THEN
                SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'A');
            ELSE
                IF SUBSTRING(st, pos - 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') AND NOT is_slavo_germanic AND SUBSTRING(st, pos + 1, 1) IN ('A', 'O') THEN
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'H');
                ELSE
                    IF pos = last THEN
                        SET pri = CONCAT(pri, 'J');
                    ELSE
                        IF SUBSTRING(st, pos + 1, 1) NOT IN ('L', 'T', 'K', 'S', 'N', 'M', 'B', 'Z') AND SUBSTRING(st, pos - 1, 1) NOT IN ('S', 'K', 'L') THEN
                            SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J');
                        END IF;
                    END IF;
                END IF;
            END IF;
            IF SUBSTRING(st, pos + 1, 1) = 'J' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'K' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'K' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 1;
            END IF;
            WHEN ch = 'L' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'L' THEN
                IF (pos = (last - 2) AND SUBSTRING(st, pos - 1, 4) IN ('ILLO', 'ILLA', 'ALLE')) OR ((SUBSTRING(st, last-1, 2) IN ('AS', 'OS') OR SUBSTRING(st, last) IN ('A', 'O')) AND SUBSTRING(st, pos - 1, 4) = 'ALLE') THEN
                    SET pri = CONCAT(pri, 'L'), pos = pos + 2;
                ELSE
                    SET pri = CONCAT(pri, 'L'), sec = CONCAT(sec, 'L'), pos = pos + 2;
                END IF;
            ELSE
                SET pri = CONCAT(pri, 'L'), sec = CONCAT(sec, 'L'), pos = pos + 1;
            END IF;
            WHEN ch = 'M' THEN
            IF SUBSTRING(st, pos - 1, 3) = 'UMB' AND (pos + 1 = last OR SUBSTRING(st, pos + 2, 2) = 'ER') OR SUBSTRING(st, pos + 1, 1) = 'M' THEN
                SET pri = CONCAT(pri, 'M'), sec = CONCAT(sec, 'M'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'M'), sec = CONCAT(sec, 'M'), pos = pos + 1;
            END IF;
            WHEN ch = 'N' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'N' THEN
                SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'N'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'N'), pos = pos + 1;
            END IF;
            WHEN ch = 'P' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'H' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 2;
            ELSEIF SUBSTRING(st, pos + 1, 1) IN ('P', 'B') THEN
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos + 1;
            END IF;
            WHEN ch = 'Q' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'Q' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos + 1;
            END IF;
            WHEN ch = 'R' THEN
            IF pos = last AND NOT is_slavo_germanic AND SUBSTRING(st, pos - 2, 2) = 'IE' AND SUBSTRING(st, pos - 4, 2) NOT IN ('ME', 'MA') THEN
                SET sec = CONCAT(sec, 'R');
            ELSE
                SET pri = CONCAT(pri, 'R'), sec = CONCAT(sec, 'R');
            END IF;
            IF SUBSTRING(st, pos + 1, 1) = 'R' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'S' THEN
            IF SUBSTRING(st, pos - 1, 3) IN ('ISL', 'YSL') THEN
                SET pos = pos + 1;
            ELSEIF pos = first AND SUBSTRING(st, first, 5) = 'SUGAR' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'S'), pos = pos + 1;
            ELSEIF SUBSTRING(st, pos, 2) = 'SH' THEN
                IF SUBSTRING(st, pos + 1, 4) IN ('HEIM', 'HOEK', 'HOLM', 'HOLZ') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos + 2;
                ELSE
                    SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 2;
                END IF;
            ELSEIF SUBSTRING(st, pos, 3) IN ('SIO', 'SIA') OR SUBSTRING(st, pos, 4) = 'SIAN' THEN
                IF NOT is_slavo_germanic THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos + 3;
                ELSE
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos + 3;
                END IF;
            ELSEIF (pos = first AND SUBSTRING(st, pos + 1, 1) IN ('M', 'N', 'L', 'W')) OR SUBSTRING(st, pos + 1, 1) = 'Z' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X');
                IF SUBSTRING(st, pos + 1, 1) = 'Z' THEN
                    SET pos = pos + 2;
                ELSE
                    SET pos = pos + 1;
                END IF;
            ELSEIF SUBSTRING(st, pos, 2) = 'SC' THEN
                IF SUBSTRING(st, pos + 2, 1) = 'H' THEN
                    IF SUBSTRING(st, pos + 3, 2) IN ('OO', 'ER', 'EN', 'UY', 'ED', 'EM') THEN
                        IF SUBSTRING(st, pos + 3, 2) IN ('ER', 'EN') THEN
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'SK'), pos = pos + 3;
                        ELSE
                            SET pri = CONCAT(pri, 'SK'), sec = CONCAT(sec, 'SK'), pos = pos + 3;
                        END IF;
                    ELSE
                        IF pos = first AND SUBSTRING(st, first+3, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y') AND SUBSTRING(st, first+3, 1) <> 'W' THEN
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'S'), pos = pos + 3;
                        ELSE
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 3;
                        END IF;
                    END IF;
                ELSEIF SUBSTRING(st, pos + 2, 1) IN ('I', 'E', 'Y') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos + 3;
                ELSE
                    SET pri = CONCAT(pri, 'SK'), sec = CONCAT(sec, 'SK'), pos = pos + 3;
                END IF;
            ELSEIF pos = last AND SUBSTRING(st, pos - 2, 2) IN ('AI', 'OI') THEN
                SET sec = CONCAT(sec, 'S'), pos = pos + 1;
            ELSE
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S');
                IF SUBSTRING(st, pos + 1, 1) IN ('S', 'Z') THEN
                    SET pos = pos + 2;
                ELSE
                    SET pos = pos + 1;
                END IF;
            END IF;
            WHEN ch = 'T' THEN
            IF SUBSTRING(st, pos, 4) = 'TION' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 3;
            ELSEIF SUBSTRING(st, pos, 3) IN ('TIA', 'TCH') THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos + 3;
            ELSEIF SUBSTRING(st, pos, 2) = 'TH' OR SUBSTRING(st, pos, 3) = 'TTH' THEN
                IF SUBSTRING(st, pos + 2, 2) IN ('OM', 'AM') OR SUBSTRING(st, first, 4) IN ('VON ', 'VAN ') OR SUBSTRING(st, first, 3) = 'SCH' THEN
                    SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos + 2;
                ELSE
                    SET pri = CONCAT(pri, '0'), sec = CONCAT(sec, 'T'), pos = pos + 2;
                END IF;
            ELSEIF SUBSTRING(st, pos + 1, 1) IN ('T', 'D') THEN
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos + 1;
            END IF;
            WHEN ch = 'V' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'V' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 2;
            ELSE
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos + 1;
            END IF;
            WHEN ch = 'W' THEN
            IF SUBSTRING(st, pos, 2) = 'WR' THEN
                SET pri = CONCAT(pri, 'R'), sec = CONCAT(sec, 'R'), pos = pos + 2;
            ELSEIF pos = first AND (SUBSTRING(st, pos + 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') OR SUBSTRING(st, pos, 2) = 'WH') THEN
                IF SUBSTRING(st, pos + 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
                    SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'F'), pos = pos + 1;
                ELSE
                    SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'A'), pos = pos + 1;
                END IF;
            ELSEIF (pos = last AND SUBSTRING(st, pos - 1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y')) OR SUBSTRING(st, pos - 1, 5) IN ('EWSKI', 'EWSKY', 'OWSKI', 'OWSKY') OR SUBSTRING(st, first, 3) = 'SCH' THEN
                SET sec = CONCAT(sec, 'F'), pos = pos + 1;
            ELSEIF SUBSTRING(st, pos, 4) IN ('WICZ', 'WITZ') THEN
                SET pri = CONCAT(pri, 'TS'), sec = CONCAT(sec, 'FX'), pos = pos + 4;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'X' THEN
            IF NOT(pos = last AND (SUBSTRING(st, pos - 3, 3) IN ('IAU', 'EAU') OR SUBSTRING(st, pos - 2, 2) IN ('AU', 'OU'))) THEN
                SET pri = CONCAT(pri, 'KS'), sec = CONCAT(sec, 'KS');
            END IF;
            IF SUBSTRING(st, pos + 1, 1) IN ('C', 'X') THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
            WHEN ch = 'Z' THEN
            IF SUBSTRING(st, pos + 1, 1) = 'H' THEN
                SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos + 1;
            ELSEIF SUBSTRING(st, pos + 1, 3) IN ('ZO', 'ZI', 'ZA') OR (is_slavo_germanic AND pos > first AND SUBSTRING(st, pos - 1, 1) <> 'T') THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'TS');
            ELSE
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S');
            END IF;
            IF SUBSTRING(st, pos + 1, 1) = 'Z' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
        ELSE
            SET pos = pos + 1;
        END CASE;
        IF pos = prevpos THEN
            SET pos = pos +1;
            SET pri = CONCAT(pri, '<didnt incr>');
        END IF;
    END WHILE;
    IF pri <> sec THEN
        SET pri = CONCAT(pri, ';', sec);
    END IF;
    RETURN (pri);
END//
DELIMITER ;

-- F_JARO_WINKLER
-- returns the jaro-winkler similarity between two given strings
DELIMITER //
CREATE FUNCTION F_JARO_WINKLER(s1 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci, s2 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE finestra, curString, curSub, maxSub, trasposizioni, prefixlen, maxPrefix INT;
    DECLARE common1, common2, old1, old2 VARCHAR(255);
    DECLARE trovato BOOLEAN;
    DECLARE jaro FLOAT;
    SET maxPrefix = 6;
    SET common1 = '';
    SET common2 = '';
    SET finestra = (LENGTH(s1) + LENGTH(s2) - abs(LENGTH(s1) - LENGTH(s2))) DIV 4 + ((LENGTH(s1) + LENGTH(s2) - abs(LENGTH(s1) - LENGTH(s2))) / 2) MOD 2;
    SET old1 = s1;
    SET old2 = s2;
    SET curString = 1;
    WHILE curString <= LENGTH(s1) AND (curString <= (LENGTH(s2) + finestra)) DO
        SET curSub = curstring - finestra;
        IF (curSub) < 1 THEN
            SET curSub = 1;
        END IF;
        SET maxSub = curstring + finestra;
        IF (maxSub) > LENGTH(s2) THEN
            SET maxSub = LENGTH(s2);
        END IF;
        SET trovato = FALSE;
        WHILE curSub <= maxSub AND trovato = FALSE DO
            IF substr(s1, curString, 1) = substr(s2, curSub, 1) THEN
                SET common1 = concat(common1, substr(s1, curString, 1));
                SET s2 = concat(substr(s2, 1, curSub - 1), concat('0', substr(s2, curSub + 1, LENGTH(s2) - curSub + 1)));
                SET trovato = TRUE;
            END IF;
            SET curSub = curSub + 1;
        END WHILE;
        SET curString = curString + 1;
    END WHILE;
    SET s2 = old2;
    SET curString = 1;
    WHILE curString <= LENGTH(s2) AND (curString <= (LENGTH(s1) + finestra)) DO
        SET curSub = curstring - finestra;
        IF (curSub) < 1 THEN
            SET curSub = 1;
        END IF;
        SET maxSub = curstring + finestra;
        IF (maxSub) > LENGTH(s1) THEN
            SET maxSub = LENGTH(s1);
        END IF;
        SET trovato = FALSE;
        WHILE curSub <= maxSub AND trovato = FALSE DO
            IF substr(s2, curString, 1) = substr(s1, curSub, 1) THEN
                SET common2 = concat(common2, substr(s2, curString, 1));
                SET s1 = concat(substr(s1, 1, curSub - 1), concat('0', substr(s1, curSub + 1, LENGTH(s1) - curSub + 1)));
                SET trovato = TRUE;
            END IF;
            SET curSub = curSub + 1;
        END WHILE;
        SET curString = curString + 1;
    END WHILE;
    SET s1 = old1;
    IF LENGTH(common1) <> LENGTH(common2) THEN
        SET jaro = 0;
    ELSEIF LENGTH(common1) = 0 OR LENGTH(common2) = 0
        THEN SET jaro = 0;
    ELSE
        SET trasposizioni = 0;
        SET curString = 1;
        WHILE curString <= LENGTH(common1) DO
            IF (substr(common1, curString, 1) <> substr(common2, curString, 1)) THEN
                SET trasposizioni = trasposizioni + 1;
            END IF;
            SET curString = curString + 1;
        END WHILE;
        SET jaro = (LENGTH(common1) / LENGTH(s1) + LENGTH(common2) / LENGTH(s2) + (LENGTH(common1) - trasposizioni / 2) / LENGTH(common1)) / 3;
    END IF;
    SET prefixlen = 0;
    WHILE (SUBSTRING(s1, prefixlen + 1, 1) = SUBSTRING(s2, prefixlen + 1, 1)) AND (prefixlen < 6) DO
        SET prefixlen = prefixlen + 1;
    END WHILE;
    RETURN jaro + (prefixlen * 0.1 * (1 - jaro));
END//
DELIMITER ;

-- F_LEVENSHTEIN
-- returns the levenshtein distance between two given strings
DELIMITER //
CREATE FUNCTION F_LEVENSHTEIN(s1 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci, s2 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
    DECLARE s1_char CHAR CHARSET utf8mb4;
    DECLARE cv0, cv1 VARBINARY(256);
    SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;
    IF (s1 = s2) THEN
        RETURN (0);
    ELSEIF (s1_len = 0) THEN
        RETURN (s2_len);
    ELSEIF (s2_len = 0) THEN
        RETURN (s1_len);
    END IF;
    WHILE (j <= s2_len) DO
        SET cv1 = CONCAT(cv1, CHAR(j)), j = j + 1;
    END WHILE;
    WHILE (i <= s1_len) DO
        SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = CHAR(i), j = 1;
        WHILE (j <= s2_len) DO
            SET c = c + 1, cost = IF(s1_char = SUBSTRING(s2, j, 1), 0, 1);
            SET c_temp = ORD(SUBSTRING(cv1, j, 1)) + cost;
            IF (c > c_temp) THEN
                SET c = c_temp;
            END IF;
            SET c_temp = ORD(SUBSTRING(cv1, j + 1, 1)) + 1;
            IF (c > c_temp) THEN
                SET c = c_temp;
            END IF;
            SET cv0 = CONCAT(cv0, CHAR(c)), j = j + 1;
        END WHILE;
        SET cv1 = cv0, i = i + 1;
    END WHILE;
    RETURN (c);
END//
DELIMITER ;

-- F_LEVENSHTEIN_RATIO
-- returns the levenshtein distance ratio between two given strings
DELIMITER //
CREATE FUNCTION F_LEVENSHTEIN_RATIO(s1 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci, s2 VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE s1_len, s2_len, max_len INT;
    SET s1_len = LENGTH(s1), s2_len = LENGTH(s2);
    IF s1_len > s2_len THEN
        SET max_len = s1_len;
    ELSE
        SET max_len = s2_len;
    END IF;
    RETURN ROUND((1 - F_LEVENSHTEIN(s1, s2) / max_len) * 100);
END//
DELIMITER ;

-- F_NORMALIZE_STRING
-- normalize (remove accents and lowercase) a given text field
CREATE FUNCTION F_NORMALIZE_STRING(s TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci
DETERMINISTIC
RETURN LOWER(F_UNACCENT(s));

-- F_STRIP_TAGS
-- strip HTML tags from a given text field
DELIMITER //
CREATE FUNCTION F_STRIP_TAGS(s TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci
NOT DETERMINISTIC NO SQL
SQL SECURITY DEFINER
BEGIN
    DECLARE start, end INT(11) DEFAULT 1;
    LOOP
        SET start = LOCATE('<', s, start);
        IF (!start) THEN RETURN s; END IF;
        SET end = LOCATE('>', s, start);
        IF (!end) THEN SET end = start; END IF;
        SET s = INSERT(s, start, end - start + 1, '');
    END LOOP;
END//
DELIMITER ;

-- F_UNACCENT
-- remove accents from a given text field
DELIMITER //
CREATE FUNCTION F_UNACCENT(s TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci
DETERMINISTIC NO SQL
BEGIN
    SET s = REPLACE(s, 'Š', 'S');
    SET s = REPLACE(s, 'š', 's');
    SET s = REPLACE(s, 'Ð', 'Dj');
    SET s = REPLACE(s, 'Ž', 'Z');
    SET s = REPLACE(s, 'ž', 'z');
    SET s = REPLACE(s, 'À', 'A');
    SET s = REPLACE(s, 'Á', 'A');
    SET s = REPLACE(s, 'Â', 'A');
    SET s = REPLACE(s, 'Ã', 'A');
    SET s = REPLACE(s, 'Ä', 'A');
    SET s = REPLACE(s, 'Å', 'A');
    SET s = REPLACE(s, 'Æ', 'A');
    SET s = REPLACE(s, 'Ç', 'C');
    SET s = REPLACE(s, 'È', 'E');
    SET s = REPLACE(s, 'É', 'E');
    SET s = REPLACE(s, 'Ê', 'E');
    SET s = REPLACE(s, 'Ë', 'E');
    SET s = REPLACE(s, 'Ì', 'I');
    SET s = REPLACE(s, 'Í', 'I');
    SET s = REPLACE(s, 'Î', 'I');
    SET s = REPLACE(s, 'Ï', 'I');
    SET s = REPLACE(s, 'Ñ', 'N');
    SET s = REPLACE(s, 'Ò', 'O');
    SET s = REPLACE(s, 'Ó', 'O');
    SET s = REPLACE(s, 'Ô', 'O');
    SET s = REPLACE(s, 'Õ', 'O');
    SET s = REPLACE(s, 'Ö', 'O');
    SET s = REPLACE(s, 'Ø', 'O');
    SET s = REPLACE(s, 'Ù', 'U');
    SET s = REPLACE(s, 'Ú', 'U');
    SET s = REPLACE(s, 'Û', 'U');
    SET s = REPLACE(s, 'Ü', 'U');
    SET s = REPLACE(s, 'Ý', 'Y');
    SET s = REPLACE(s, 'Þ', 'B');
    SET s = REPLACE(s, 'ß', 'Ss');
    SET s = REPLACE(s, 'à', 'a');
    SET s = REPLACE(s, 'á', 'a');
    SET s = REPLACE(s, 'â', 'a');
    SET s = REPLACE(s, 'ã', 'a');
    SET s = REPLACE(s, 'ä', 'a');
    SET s = REPLACE(s, 'å', 'a');
    SET s = REPLACE(s, 'æ', 'a');
    SET s = REPLACE(s, 'ç', 'c');
    SET s = REPLACE(s, 'è', 'e');
    SET s = REPLACE(s, 'é', 'e');
    SET s = REPLACE(s, 'ê', 'e');
    SET s = REPLACE(s, 'ë', 'e');
    SET s = REPLACE(s, 'ì', 'i');
    SET s = REPLACE(s, 'í', 'i');
    SET s = REPLACE(s, 'î', 'i');
    SET s = REPLACE(s, 'ï', 'i');
    SET s = REPLACE(s, 'ð', 'o');
    SET s = REPLACE(s, 'ñ', 'n');
    SET s = REPLACE(s, 'ò', 'o');
    SET s = REPLACE(s, 'ó', 'o');
    SET s = REPLACE(s, 'ô', 'o');
    SET s = REPLACE(s, 'õ', 'o');
    SET s = REPLACE(s, 'ö', 'o');
    SET s = REPLACE(s, 'ø', 'o');
    SET s = REPLACE(s, 'ù', 'u');
    SET s = REPLACE(s, 'ú', 'u');
    SET s = REPLACE(s, 'û', 'u');
    SET s = REPLACE(s, 'ý', 'y');
    SET s = REPLACE(s, 'ý', 'y');
    SET s = REPLACE(s, 'þ', 'b');
    SET s = REPLACE(s, 'ÿ', 'y');
    SET s = REPLACE(s, 'ƒ', 'f');
    RETURN s;
END//
DELIMITER ;