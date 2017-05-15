CREATE TABLE IF NOT EXISTS `translations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `translate_key` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `translate_value` text COLLATE utf8mb4_bin,
  `locale` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT 'ja',
  `file_id` int(10) unsigned NOT NULL,
  `match_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_file_id` (`file_id`),
  KEY `idx_translate_key` (`translate_key`)
);
CREATE TABLE IF NOT EXISTS files (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  file_path VARCHAR(255) NOT NULL,
  locale VARCHAR(10) NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY(id)
);
