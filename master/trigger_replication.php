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
		INSERT visitor (site,id,hwaddr,jointime,leavetime)
		       VALUES(:site_id,:id,:hwaddr,:jointime,:leavetime)
      		       ON DUPLICATE KEY UPDATE hwaddr=values(hwaddr),
					       jointime=values(jointime),
					       leavetime=values(leavetime)');

	// Site id is the same for all rows
	$sth_master->bindParam(':site_id', $creds->id, PDO::PARAM_INT);

	$sth_site->execute();

	// Now we have prepared both servers and the site has some data ready!

	while (($row = $sth_site->fetchObject()) !== FALSE) {
		$sth_master->bindParam(':id', $row->id,  PDO::PARAM_INT);
		$sth_master->bindParam(':hwaddr', $row->hwaddr,  PDO::PARAM_STR);
		$sth_master->bindParam(':jointime', $row->jointime,  PDO::PARAM_STR);
		$sth_master->bindParam(':leavetime', $row->leavetime,  PDO::PARAM_STR);
		$sth_master->execute();
	}
	
	$sth_master->closeCursor();
	$sth_site->closeCursor();

	// Set data replication flag
	$dbh_site->exec('UPDATE visitor SET fresh=0 where fresh=1');
}
catch (Exception $e) {
	errorexit('unable to replicate visitor table',$e);
}

try {
	/**
	 * Replicate device table
	 */

	$sth_site = $dbh_site->prepare('
		SELECT hwaddr,name,changed FROM device WHERE fresh=1');

	$sth_master = $dbh_master->prepare('
		INSERT device (hwaddr,name,changed)
		       VALUES(:hwaddr,:name,:changed)
       		       ON DUPLICATE KEY UPDATE name=values(name),
		                               changed=values(changed)');
	
	$sth_site->execute();

	// Now we have prepared both servers and the site has some data ready!

	while (($row = $sth_site->fetchObject()) !== FALSE) {
		$sth_master->bindParam(':hwaddr', $row->hwaddr,  PDO::PARAM_STR);
		$sth_master->bindParam(':name', $row->name,  PDO::PARAM_STR);
		$sth_master->bindParam(':changed', $row->changed,  PDO::PARAM_STR);
		$sth_master->execute();
	}
	
	$sth_master->closeCursor();
	$sth_site->closeCursor();

	// Set data replication flag
	$dbh_site->exec('UPDATE device SET fresh=0 where fresh=1');
}
catch (Exception $e) {
	errorexit('unable to replicate device table',$e);
}

/**
 * Everything is now ok.
 *
 * We need to commit. Remember that THIS IS NOT PERFECTLY SAFE. There
 * is always chance for this to fail due to Two Generals' Problem. But
 * this is quite safe because the "destruction window" is so
 * narrow. That happens if the network or this script fails between the
 * next two lines.
 */
try {
	$dbh_site->commit();
	$dbh_master->commit();
}
catch (Exception $e) {
	errorexit('death and destruction. commit failed on only one side. '.
		  'your data is probably corrupted on the master side.',$e);
}

/**
 * Launch the IRC bot trigger. FIXME: Hard coded path names.
 */
$bot_pid = intval(file_get_contents("/var/lib/kattilabotti/kattilabot.pid"));
if (! posix_kill($bot_pid, 12)) { // SIGUSR2
	errorexit('The data went ok but the triggers failed. IRC and others '.
		  'may have not been updated.');
}

print("success: ok.\n");
