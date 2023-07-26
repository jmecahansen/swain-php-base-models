-- MySQL extended math routines
-- Author: Julio María Meca Hansen <julio@meca-innotech.com>

-- bootstrapping
DROP FUNCTION IF EXISTS F_HAMMING_DISTANCE;
DROP FUNCTION IF EXISTS F_NUMERIC_DIFFERENCE;
DROP FUNCTION IF EXISTS F_PERCENT_DIFFERENCE;
DROP FUNCTION IF EXISTS F_PERCENT_VALUE;

-- F_HAMMING_DISTANCE
-- returns the hamming distance between two given integer values
CREATE FUNCTION F_HAMMING_DISTANCE(a BIGINT, b BIGINT) RETURNS INT
DETERMINISTIC
RETURN BIT_COUNT(a ^ b);

-- F_NUMERIC_DIFFERENCE
-- calculate the numeric difference between two given numbers
CREATE FUNCTION F_NUMERIC_DIFFERENCE(a DOUBLE, b DOUBLE) RETURNS DOUBLE
DETERMINISTIC
RETURN IF(b > a, b - a, a - b);

-- F_PERCENT_DIFFERENCE
-- calculate the percent difference between two given numbers
CREATE FUNCTION F_PERCENT_DIFFERENCE(a DOUBLE, b DOUBLE) RETURNS DOUBLE
DETERMINISTIC
RETURN IF(b > a, (b - a) / b, (a - b) / a) * 100;

-- F_PERCENT_VALUE
-- calculate the resulting value of applying a given percentage for a given number
CREATE FUNCTION F_PERCENT_VALUE(n DOUBLE, p DOUBLE) RETURNS DOUBLE
DETERMINISTIC
RETURN (n / 100) * p;
