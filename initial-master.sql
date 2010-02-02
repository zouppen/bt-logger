-- A table for storing site connection parameters
CREATE TABLE `site_credential` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(15) NOT NULL,
  `password` char(8) default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip` (`ip`)
) DEFAULT CHARSET=utf8;

-- Trying to do a tool to create a temporary table
DELIMITER |
CREATE PROCEDURE prepare_fetch (IN site_ip varchar(15), OUT site_id int)
BEGIN
	-- Table column layout must be identical to the one in client (site)
	-- database!
	-- Do not include keys, not needed in master server.

	DECLARE site_password varchar(8);

	SELECT id,password INTO site_id,site_password FROM site_credential WHERE ip=@site_ip;

	CREATE TEMPORARY TABLE `visitor_client` (
	  `id` int(11),
	  `hwaddr` char(17),
	  `jointime` datetime,
	  `leavetime` datetime,
	  `fresh` TINYINT
	) ENGINE=FEDERATED
	  CONNECTION=concat('mysql://master:',@site_password,'@',@site_ip,'/bluetooth/visitor');
END|
DELIMITER ;

-- Some table locking to 
-- LOCK TABLES visitor WRITE, visitor_client WRITE;
-- LOCK TABLES device WRITE, device_client WRITE;
	

-- This mammoth procedure syncs a given database to the master tables
-- If there is a value already, this updates contents smoothly.
-- Remember to lock the tables before executing this
DELIMITER |
CREATE PROCEDURE fetch_remote_data (IN site_id int)
BEGIN
	-- Visitor log. Additional column for storing site (place) information
	-- (important for handling duplicates, too).

	INSERT INTO visitor (site,id,hwaddr,jointime,leavetime)
	       SELECT @site_id,id,hwaddr,jointime,leavetime
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
       		      ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
		      	 	       	      jointime=values(jointime),
					      leavetime=values(leavetime);

	UPDATE device_client SET fresh=0;
END|
DELIMITER ;