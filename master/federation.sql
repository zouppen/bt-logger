-- Federated table format. Used in replication. Definitions here
-- should be identical to those in site/initial.sql except tables are
-- TEMPORARY, there are no keys and no default values (having keys
-- makes MySQL optimize in wrong place).
-- 
-- FIXME: The truth is the opposite! PUT KEYS HERE!
-- 
-- This file is almost SQL but contains some printf formatting for PHP
-- because those variables can not be binded in SQL (are too low level
-- for SQL).

CREATE TEMPORARY TABLE `visitor_client` (
  `id` int(11),
  `hwaddr` char(17),
  `jointime` datetime,
  `leavetime` datetime,
  `fresh` TINYINT
) ENGINE=FEDERATED
  CONNECTION='mysql://master:%2$s@%1$s/bluetooth/visitor';

CREATE TEMPORARY TABLE `device_client` (
  `id` int(11),
  `hwaddr` char(17),
  `name` text,
  `changed` timestamp,
  `fresh` TINYINT
) ENGINE=FEDERATED
  CONNECTION='mysql://master:%2$s@%1$s/bluetooth/device';
