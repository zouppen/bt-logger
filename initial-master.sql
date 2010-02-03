-- A table for storing site connection parameters
CREATE TABLE `site_credential` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(15) NOT NULL,
  `password` char(8) default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`)
) DEFAULT CHARSET=utf8;


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
) DEFAULT CHARSET=utf8;


-- Master device database. Stores names of Bluetooth devices found.
CREATE TABLE `device` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hwaddr` char(17) NOT NULL,
  `name` text,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hwaddr` (`hwaddr`),
  KEY `name` (`name`(10))
);


-- This mammoth procedure syncs a given database to the master tables
-- If there is a value already, this updates contents smoothly.
-- Remember to lock the tables before executing this
DELIMITER |
CREATE PROCEDURE fetch_remote_data (IN site_id int)
BEGIN
	-- Visitor log. Additional column for storing site (place) information
	-- (important for handling duplicates, too).

	INSERT INTO visitor (site,id,hwaddr,jointime,leavetime)
	       SELECT site_id,id,hwaddr,jointime,leavetime
	              FROM visitor_client WHERE fresh=1
       		      ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
		      	 	       	      jointime=values(jointime),
					      leavetime=values(leavetime);

	UPDATE visitor_client SET fresh=0;

	-- Device table. Devices are global, so we don't need any client
	-- specific values. Triggers take care of storing historical data.
	
	INSERT INTO device (hwaddr,name,changed)
	       SELECT hwaddr,name,changed
	              FROM device_client WHERE fresh=1
       		      ON DUPLICATE KEY UPDATE name=values(name),
		      	 	       	      changed=values(changed);

	UPDATE device_client SET fresh=0;
END|
DELIMITER ;