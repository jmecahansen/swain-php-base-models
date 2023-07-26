-- application routes
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_routes_dynamic;
DROP TABLE IF EXISTS c_routes_static;
SET FOREIGN_KEY_CHECKS = 1;

-- dynamic routes
CREATE TABLE IF NOT EXISTS c_routes_dynamic (
    route_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    route_methods VARCHAR(175) NOT NULL DEFAULT 'CONNECT|DELETE|GET|HEAD|OPTIONS|PATCH|POST|PUT|TRACE',
    route_path VARCHAR(175) NOT NULL,
    route_target LONGTEXT NOT NULL,
    route_name VARCHAR(175),
    PRIMARY KEY (route_id),
    INDEX (route_methods),
    INDEX (route_path),
    INDEX (route_name),
    UNIQUE KEY (route_methods, route_path, route_name)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- static routes
CREATE TABLE IF NOT EXISTS c_routes_static (
    route_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    route_methods VARCHAR(175) NOT NULL DEFAULT 'CONNECT|DELETE|GET|HEAD|OPTIONS|PATCH|POST|PUT|TRACE',
    route_path VARCHAR(175) NOT NULL,
    route_target LONGTEXT NOT NULL,
    route_name VARCHAR(175),
    PRIMARY KEY (route_id),
    INDEX (route_methods),
    INDEX (route_path),
    INDEX (route_name),
    UNIQUE KEY (route_methods, route_path, route_name)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;