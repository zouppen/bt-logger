-- A table for storing site connection parameters
CREATE TABLE `site_credential` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(15) NOT NULL,
  `password` char(8) default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Master visitor database.
CREATE TABLE `visitor` (
  `site` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `hwaddr` char(17) NOT NULL,
  `jointime` datetime default NULL,
  `leavetime` datetime default NULL,
  PRIMARY KEY  (`site`,`id`),
  KEY `site` (`site`),
  KEY `hwaddr` (`hwaddr`),
  KEY `joins` (`jointime`),
  KEY `leaves` (`leavetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Master device database. Stores names of Bluetooth devices found.
CREATE TABLE `device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) NOT NULL,
  `name` text,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
