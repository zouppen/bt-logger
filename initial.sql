CREATE DATABASE bluetooth;

USE bluetooth;

-- REMEMBER to change the respective table layout in master server
-- if you do alter these tables. Otherwise the world will end to flames.

-- Stores information about visitors.
CREATE TABLE `visitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) NOT NULL,
  `jointime` datetime DEFAULT NULL,
  `leavetime` datetime DEFAULT NULL,
  `fresh` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `hwaddr` (`hwaddr`),
  KEY `joins` (`jointime`),
  KEY `leaves` (`leavetime`),
  KEY `fresh` (`fresh`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Stores names of Bluetooth devices
CREATE TABLE `device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) CHARACTER SET latin1 NOT NULL,
  `name` text CHARACTER SET latin1,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fresh` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10)),
  KEY `fresh` (`fresh`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Contains device history. This should be replicated, not 'device'
CREATE TABLE `device_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) CHARACTER SET latin1 NOT NULL,
  `name` text CHARACTER SET latin1,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fresh` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10)),
  KEY `fresh` (`fresh`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
	       	       WHERE leavetime IS NULL AND 
		       	     hwaddr NOT IN (select hwaddr from log);

	INSERT device (hwaddr,name) SELECT hwaddr,name FROM log
	       	      ON DUPLICATE KEY UPDATE name=values(name);

	TRUNCATE TABLE log;
END|
DELIMITER ;

-- Updates status column if data has changed.
-- Used in updating of the "multiple master" replication flag.
DELIMITER |
CREATE TRIGGER st_visitor BEFORE UPDATE ON visitor FOR EACH ROW 
BEGIN
	SET NEW.fresh = 1;
END|
DELIMITER ;

-- Inserts previous values to historical table if current data has changed.
-- Used in updating of the replication flag, too.
DELIMITER |
CREATE TRIGGER update_device BEFORE UPDATE ON device FOR EACH ROW
BEGIN
	SET NEW.fresh = 1;
	IF OLD.name != NEW.name THEN
		INSERT INTO device_history (hwaddr,name,changed) VALUES (OLD.hwaddr, OLD.name, OLD.changed);
	END IF;
END|
DELIMITER ;
