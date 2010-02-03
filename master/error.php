<?php // -*- coding: utf-8 -*-

/**
 * Returns error message
 */
function errorexit($msg) {
  // extra debug
  global $sth;
  global $dbh;
  print_r($sth->errorInfo());
  print_r($dbh->errorInfo());
  
  print("error: ".$msg."\n");
  exit(0);
  }

