<?php
header('Content-Type: text/html; charset=UTF-8');
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" href="basic.css" type="text/css" />
<title>Kattilassa vierailleita</title>
</head>
<body>
<?php // -*- coding: utf-8 -*-
error_reporting(E_ALL);
ini_set('display_errors', '1');
mb_internal_encoding('UTF-8');
// Some constants
$my_site = 1; // Kattila

$dbh = new PDO('mysql:host=zouppen.iki.fi;dbname=bluetooth',
	       'viewer','');
$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

/**
 * Let's get visitors.
 */

$sth = $dbh->prepare("SELECT nick,CONVERT_TZ(jointime,'UTC','Europe/Helsinki') as jointime ".
		     "from visitor_public as v, device_public as d ".
		     "where site=:site and v.id=d.id and leavetime IS NULL");
$sth->bindParam(':site', $my_site, PDO::PARAM_INT);
$sth->execute();

$row = $sth->fetchObject();

print('<h1>Kattilassa tällä hetkellä</h1>');

if ($row === FALSE) {
  print('<p>Kattilassa ei tällä hetkellä ole ketään, joka haluaa tietonsa näkyvän.</p>');
 } else {
  print('<table><tr><th>Nick</th><th>Saapui</th></tr>');
  do {
    print('<tr><td>'.htmlspecialchars($row->nick).
	  '</td><td>'.htmlspecialchars($row->jointime).'</td></tr>');
  } while (($row = $sth->fetchObject()) !== FALSE);
  print('</table>');
 }
$sth->closeCursor();

/**
 * Last visit time and total.
 */

$sth = $dbh->prepare("
	SELECT nick,sec_to_time(sum(time_to_sec(timediff(coalesce(leavetime,utc_timestamp()),jointime)))) as total,
	       convert_tz((select leavetime from visitor_public as v2
			   where v2.id=v.id order by leavetime desc limit 1),
			   'UTC','Europe/Helsinki') as last_visit
	       from visitor_public as v, device_public as d
	       where site=:site and v.id=d.id group by v.id");

$sth->bindParam(':site', $my_site, PDO::PARAM_INT);
$sth->execute();

$row = $sth->fetchObject();

print('<h1>Henkilöiden vierailut Kattilassa</h1>');

if ($row === FALSE) {
  print('<p>Kanta on tyhjä.</p>');
 } else {
  print('<table><tr><th>Nick</th><th>Yhteensä paikalla</th><th>Lähti viimeksi</th></tr>');
  do {
    print('<tr><td>'.htmlspecialchars($row->nick).'</td>'.
	  '<td>'.htmlspecialchars($row->total).'</td>'.
	  '<td>'.htmlspecialchars($row->last_visit).'</td></tr>');
  } while (($row = $sth->fetchObject()) !== FALSE);
  print('</table>');
 }
$sth->closeCursor();

?>

<p>Täällä ovat näkyvillä vain niiden henkilöiden tiedot, joiden
Bluetooth-kännykkä on haettavissa ja he ovat antaneet suostumuksensa tietojen
käyttöön tällä sivulla.
Suostumuksen saa annettua kirjoittamalla irkkiin Zouppen -nimimerkille.</p>

  <p><a href="simple_stats.phps" title="lähdekoodit">Tutustu lähdekoodiin</a> ja kokeile myös itse yhdistää tietokantaan palvelimella <tt>zouppen.iki.fi</tt>. Koneelle pääsee mm. yliopiston www-palvelimelta käsin ja osoitteista, jotka on ilmoitettu Zouppenille.</p>

<p>Koko <a href="http://iki.fi/zouppen/repo/bt-logger.git">projektin lähdekoodit</a> löytyvät myös.</p>

</body></html>