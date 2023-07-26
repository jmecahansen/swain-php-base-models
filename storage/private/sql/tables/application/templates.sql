-- application templates
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_templates;
SET FOREIGN_KEY_CHECKS = 1;

-- templates
CREATE TABLE IF NOT EXISTS c_templates (
    template_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    template_key VARCHAR(175) NOT NULL,
    template_content LONGTEXT NOT NULL,
    PRIMARY KEY (template_id),
    INDEX (template_key),
    UNIQUE KEY (template_key)
) ENGINE=InnoDB DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_520_ci;