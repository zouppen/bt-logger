CREATE DATABASE bluetooth;

USE bluetooth;

-- Stores information about visitors
CREATE TABLE IF NOT EXISTS `visitor` (
  `id` int(11) NOT NULL auto_increment,
  `hwaddr` char(17) NOT NULL,
  `jointime` datetime default NULL,
  `leavetime` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `hwaddr` (`hwaddr`),
  KEY `joins` (`jointime`),
  KEY `leaves` (`leavetime`)
);

-- Stores names of Bluetooth devices
CREATE TABLE `device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) NOT NULL,
  `name` text,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10))
);

-- Not actually needed because it's temporary but it's just a reminder
CREATE TEMPORARY TABLE `log` (
  `hwaddr` char(17) DEFAULT NULL,
  `name` text
);

-- Puts interesting data from temporary table to a permanent tables
DELIMITER |
CREATE PROCEDURE update_tables ()
BEGIN
	INSERT visitor (jointime,hwaddr)
	       	       (SELECT now(),hwaddr FROM log
		       	       WHERE hwaddr NOT IN (SELECT hwaddr FROM visitor
			    	  	     	    WHERE leavetime IS NULL));

	UPDATE visitor SET leavetime=now()
	       	       WHERE hwaddr NOT IN (select hwaddr from log);

	INSERT device (hwaddr,name) SELECT hwaddr,name FROM log
	       	      ON DUPLICATE KEY UPDATE name=values(name);

	TRUNCATE TABLE log;
END|
DELIMITER ;
