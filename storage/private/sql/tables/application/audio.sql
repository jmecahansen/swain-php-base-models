-- audio
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS c_audio_speech_commands;
SET FOREIGN_KEY_CHECKS = 1;

-- speech commands
CREATE TABLE IF NOT EXISTS c_audio_speech_commands (
    command_id BIGINT(64) UNSIGNED NOT NULL AUTO_INCREMENT,
    context_id BIGINT(64) UNSIGNED,
    context_key VARCHAR(175),
    command_language CHAR(2) NOT NULL DEFAULT 'es',
    command_key VARCHAR(175) NOT NULL,
    command_string LONGTEXT NOT NULL,
    PRIMARY KEY (command_id),
    INDEX (context_id),
    INDEX (context_key),
    INDEX (command_language),
    INDEX (command_key),
    UNIQUE KEY (context_id, context_key, command_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;