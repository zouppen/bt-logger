<?php // -*- coding: utf-8 -*-
error_reporting(E_ALL);
ini_set('display_errors', '1');
header('Content-type: text/plain');

require('db.inc');
require('error.php');

try {
	/**
	 * Connect the master db.
	 */
	
	$dbh_master = new PDO('mysql:host='.$mysql_host.';dbname='.
			      $mysql_dbname, $mysql_user, $mysql_password);
	$dbh_master->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	/**
	 * Get the credentials for an IP
	 */
	
	$sth = $dbh_master->prepare('SELECT id,ip,user,db,password '.
				    'from site_credential where ip=:ip;');
	$sth->bindParam(':ip', $_SERVER['REMOTE_ADDR'], PDO::PARAM_STR);
	$sth->execute();

	$creds = $sth->fetchObject();
	$sth->closeCursor();
}
catch (Exception $e) {
	errorexit('unable to communicate with the master database',$e);
}

// If it returns an empty row
if ($creds === FALSE) errorexit("permission denied.");



try {
	/**
	 * Connect to the site db.
	 */

	$dbh_site = new PDO('mysql:host='.$creds->ip.';dbname='.$creds->db,
			    $creds->user, $creds->password);
	$dbh_site->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	
	// Transaction starts on client
	$dbh_master->beginTransaction();
	$dbh_site->beginTransaction();
}
catch (Exception $e) {
	errorexit('can not connect to the site database at '.$creds->ip);
}

/**
 * Do the mystical replication!
 */

try {
	/**
	 * Replicate visitor table
	 */

	$sth_site = $dbh_site->prepare('
		SELECT id,hwaddr,jointime,leavetime
		       FROM visitor WHERE fresh=1');

	$sth_master = $dbh_master->prepare('
		INSERT visitor site,id,hwaddr,jointime,leavetime
		       VALUES(:site_id,:id,:hwaddr,:jointime,:leavetime)
      		       ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
					       jointime=values(jointime),
					       leavetime=values(leavetime)');

	// Site id is the same for all rows
	$sth_master->bindParam(':site_id', $creds->id, PDO::PARAM_INT);

	$sth_site->execute();

	// Now we have prepared both servers and the site has some data ready!

	while (($row = $sth->fetchObject()) !== FALSE) {
		$sth_master->bindParam(':id', $row->id,  PDO::PARAM_INT);
		$sth_master->bindParam(':hwaddr', $row->hwaddr,  PDO::PARAM_STR);
		$sth_master->bindParam(':jointime', $row->id,  PDO::PARAM_STR);
		$sth_master->bindParam(':leavetime', $row->id,  PDO::PARAM_STR);
	}
	
	$sth_master->closeCursor();
	$sth_site->closeCursor();
}
catch (Exception $e) {
	errorexit('unable to replicate visitor database');
}

//$sth = $dbh->prepare(sprintf(file_get_contents('replication.sql'),
//			     $creds['id']));


print("succeess: ok.\n");