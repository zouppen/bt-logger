-- This file is SQL and contains the query for replication.
-- 
-- Temporary tables are contained in federation.sql. This query
-- expects those tables present. Locking can't be done in a MySQL
-- procedure, so we have those here.

-- LOCK TABLES visitor WRITE,
--     	    visitor_client WRITE,
--	    device WRITE,
--	    device_client WRITE;

CALL fetch_remote_data (%1$d);

-- UNLOCK TABLES;
