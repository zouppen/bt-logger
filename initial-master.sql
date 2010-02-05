-- A table for storing site connection parameters
CREATE TABLE `site_credential` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(15) NOT NULL,
  `password` char(8) default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Master visitor table.
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


-- Master device table. Stores names of Bluetooth devices found.
CREATE TABLE `device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) NOT NULL,
  `name` text,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Public device table, used to limit anonymous access to certain
-- devices only.
CREATE TABLE `friend` (
  `id` int(11) NOT NULL auto_increment,
  `hwaddr` char(17) NOT NULL,
  `nick` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Public sites and their names. Only these are shown to anonymous
-- viewers.
CREATE TABLE `site_public` (
  `id` int(11) NOT NULL,
  `name` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Views for anonymous user
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY
DEFINER VIEW `visitor_public` AS select `friend`.`id` AS
`id`,`visitor`.`jointime` AS `jointime`,`visitor`.`leavetime` AS
`leavetime` from (`friend` join `visitor`) where (`friend`.`hwaddr` =
`visitor`.`hwaddr`);

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY
DEFINER VIEW `device_public` AS select `friend`.`id` AS
`id`,`friend`.`nick` AS `nick` from `friend`;
