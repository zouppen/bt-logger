CREATE TABLE `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hwaddr` char(17) DEFAULT NULL,
  `name` text,
  PRIMARY KEY (`id`),
  KEY `time` (`time`),
  KEY `hwaddr` (`hwaddr`)
);
