-- MyGoogle Replacement SQL
DROP DATABASE IF EXISTS `mygoogle`;
CREATE DATABASE `mygoogle` DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
USE `mygoogle`;



DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `user_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_name` varchar(64),
    PRIMARY KEY (user_name),
    UNIQUE (user_id)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;

DROP TABLE IF EXISTS `user_tab`;
CREATE TABLE `user_tab` (
    user_id int(11) UNSIGNED NOT NULL,
    tab_id  int(11) UNSIGNED NOT NULL,
    tab_name varchar(64),
    PRIMARY KEY (user_id, tab_id)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8; 

DROP TABLE IF EXISTS `feeds`;
CREATE TABLE `feeds` (
    user_id int(11) UNSIGNED NOT NULL,
    tab_id int(11) UNSIGNED NOT NULL,
    position int(4) UNSIGNED NOT NULL,
    url varchar(255),
    PRIMARY KEY (user_id, tab_id, position)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;

INSERT INTO users (`user_name`) VALUES ('jkolber');



--
--



DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
    id                  INT(11) UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    feed_name          VARCHAR(255) NOT NULL DEFAULT '',
    title               VARCHAR(196) NOT NULL DEFAULT 'untitled',
    summary             TEXT NOT NULL DEFAULT '',
    url                 VARCHAR(255) NOT NULL DEFAULT '',
    pubdate_timestamp   INT(11) UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (pubdate_timestamp,url),
    INDEX (feed_name)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;
