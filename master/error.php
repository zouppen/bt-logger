<?php // -*- coding: utf-8 -*-

/**
 * Returns error message
 */
function errorexit($msg, $e = NULL) {
	// extra debug
	if (!is_null($e)) print('raw error: '.$e->getMessage()."\n");
				
	print("error: ".$msg."\n");
	exit(0);
  }

