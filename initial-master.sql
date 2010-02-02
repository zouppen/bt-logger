-- A table for storing site connection parameters
CREATE TABLE `site_credential` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(15) NOT NULL,
  `password` char(8) default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`)
) DEFAULT CHARSET=utf8;

-- This mammoth procedure syncs a given database to the master tables
-- If there is a value already, this updates contents smoothly.
DELIMITER |
CREATE PROCEDURE fetch_remote_data (IN site_id int)
BEGIN
	-- Visitor log. Additional column for storing site (place) information
	-- (important for handling duplicates, too).
	LOCK visitor WRITE, visitor_client WRITE;
	
	INSERT INTO visitor (site,id,hwaddr,jointime,leavetime)
	       SELECT @client_id,id,hwaddr,jointime,leavetime
	              FROM visitor_client WHERE fresh=1
       		      ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
		      	 	       	      jointime=values(jointime),
					      leavetime=values(leavetime);

	UPDATE visitor_client SET fresh=0;

	UNLOCK TABLES;

	-- Device table. Devices are global, so we don't need any client
	-- specific values. Triggers take care of storing historical data.
	LOCK device WRITE, device_client WRITE;
	
	INSERT INTO device (hwaddr,name,changed)
	       SELECT hwaddr,name,changed
	              FROM device_client WHERE fresh=1
       		      ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
		      	 	       	      jointime=values(jointime),
					      leavetime=values(leavetime);

	UPDATE device_client SET fresh=0;

	UNLOCK TABLES;
END|
DELIMETER ;