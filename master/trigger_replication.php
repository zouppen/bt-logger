<?php // -*- coding: utf-8 -*-
error_reporting(E_ALL);
ini_set('display_errors', '1');
header('Content-type: text/plain');

require('db.inc');
require('error.php');

/**
 * Connect the db.
 */

$dbh = new PDO('mysql:host='.$mysql_host.';dbname='.$mysql_dbname,
	       $mysql_user, $mysql_password);

/**
 * Get the credentials for an IP
 */
$sth = $dbh->prepare('SELECT id,ip,password from site_credential '.
		     'where ip=:ip;');
	
if($sth === FALSE) errorexit("master database is not ok (1).");

$sth->bindParam(':ip', $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);

if($sth->execute() == FALSE) errorexit("master database is not ok (2).");

$creds = $sth->fetch(PDO::FETCH_ASSOC);
if ($creds === FALSE) errorexit("permission denied.");
$sth->closeCursor();

/**
 * Create temporary tables
 */
$sth = $dbh->prepare(sprintf(file_get_contents('federation.sql'),
			     $creds['ip'],$creds['password']));
if($sth->execute() == FALSE) errorexit("unable to create temporary tables.");
$sth->closeCursor();

/**
 * Do the mystical replication!
 */
$sth = $dbh->prepare(sprintf(file_get_contents('replication.sql'),
			     $creds['id']));
if($sth->execute() == FALSE) errorexit("replication failed.");
$sth->closeCursor();

print("succeess: ok.\n");