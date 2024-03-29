================
Bluetooth logger
================

**THIS PROJECT HAS BEEN ARCHIVED.** It relied on discoverable Bluetooth which
hasn't been available since Android phones came. It's a product of the Nokia
age. Nowadays better approach is to monitor DHCP leases in a WLAN network.
See `Visitors project`_.

Description
===========

Logs all Bluetooth devices in the range to a relational
database. Intended to be run periodically. A database row contains
time of devices joining and leaving your Bluetooth range. Also,
hardware addresses and screen names are logged.

Installation
============

MySQL
-----

Create a new database. If you want to call the database 'bluetooth', you
can setup initial tables simply from 'misc/initial.sql'. On the
database server, run::

   $ mysql -u root -p <initial.sql

Then open MySQL console. Make a new user with all the needed privileges.
Type in the following (remember to change user, host and password)::

   $ mysql -u root -p

And type::

   CREATE USER 'user'@'host' IDENTIFIED BY 'password';
   GRANT CREATE TEMPORARY TABLES, INSERT, EXECUTE ON `bluetooth`.* TO 'user'@'host';
   FLUSH PRIVILEGES;

Now your database is ready to receive Bluetooth device data.

Python
------

This script is tested with Python 2.6. I recommend installing that version.

Running
=======

You can run this in cron or in other periodic facility with the following line::

   python log.py | mysql -h my_host -u my_user --password=my_pass my_db

.. _Visitors project: https://github.com/HacklabJKL/visitors/
