# Test with ADG

Now we can run some testing with the ADG.

## Prerequisites

This lab assumes you have already completed the following labs:

- Deploy Active Data Guard with LVM

## Step 1: Test transaction replication

1. From on-premise side, create a test user in orclpdb, and grant privileges to the user. You need  to check if the pdb is open.

```
[oracle@workshop ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 06:52:50 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB			  READ WRITE

SQL> alter session set container=orclpdb;

Session altered.

SQL> create user testuser identified by testuser;

User created.

SQL> grant connect,resource to testuser;

Grant succeeded.

SQL> alter user testuser quota unlimited on users;

User altered.

SQL> exit;
```

2. Connect with testuser using the on-premise host ip address or hostname, create test table and insert a test record.

```
[oracle@workshop ~]$ sqlplus testuser/testuser@xxx.xxx.xxx.xxx:1521/orclpdb

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 06:59:56 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> create table test(a number,b varchar2(20));

Table created.
SQL> insert into test values(1,'line1');

1 row created.

SQL> commit;

Commit complete.

SQL>  
```

3. From cloud side, open the standby database as read only.

```
[oracle@dbstby ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 07:04:39 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> select open_mode,database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
MOUNTED 	     PHYSICAL STANDBY

SQL> alter database open;

Database altered.

SQL> alter pluggable database orclpdb open;

Pluggable database altered.

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB			  READ ONLY  NO
	 
SQL> select open_mode,database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ ONLY WITH APPLY PHYSICAL STANDBY

SQL> exit
Disconnected from Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.7.0.0.0
[oracle@dbstby ~]$ 
```
If the `OPEN_MODE` is **READ ONLY**, you can run the following command in sqlplus as sysdba, then check the `open_mode` again, you can see the `OPEN_MODE` is **READ ONLY WITH APPLY** now.
```
SQL> alter database recover managed standby database cancel;

Database altered.

SQL> alter database recover managed standby database using current logfile disconnect;

Database altered.

SQL> select open_mode,database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ ONLY WITH APPLY PHYSICAL STANDBY
```

4. From cloud side, connect as testuser to orclpdb using DBCS host ip address or hostname. Check if the test table and record has replicated to the standby.

```
[oracle@dbstby ~]$ sqlplus testuser/testuser@xxx.xxx.xxx.xxx:1521/orclpdb

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 07:09:27 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Sat Feb 01 2020 06:59:56 +00:00

Connected to:
Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> select * from test;

	 A B
---------- --------------------
	 1 line1

SQL> 
```



## Step 2: Test DML Redirection

Starting  with Oracle DB 19c, we can run DML operations on Active Data Guard standby databases. This enables you to occasionally execute DMLs on read-mostly applications on the standby database.

Automatic redirection of DML operations to the primary can be configured at the system level or the session level. The session level setting overrides the system level

1. From cloud side, connect to orclpdb as testuser. Test the DML before and after the DML Redirection is enabled.

```
SQL> insert into test values(2,'line2');
insert into test values(2,'line2')
            *
ERROR at line 1:
ORA-16000: database or pluggable database open for read-only access


SQL> ALTER SESSION ENABLE ADG_REDIRECT_DML;

Session altered.

SQL> insert into test values(2,'line2');

1 row created.

SQL> commit; 

Commit complete.

SQL> select * from test;

	 A B
---------- --------------------
	 2 line2
	 1 line1

SQL> exit
Disconnected from Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.7.0.0.0
[oracle@dbstby ~]$ 
```

2. From on-premise side, connect to orclpdb as testuser. Check the records in the test table.

```
SQL> select * from test;

	 A B
---------- --------------------
	 2 line2
	 1 line1

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0
[oracle@adgstudent1 ~]$ 
```

You may encounter the performance issue when using the DML redirection. This is because each of the DML is issued on a standby database will be passed to the primary database where it is executed. The session waits until the corresponding changes are shipped to and applied to the standby. So it's support read-mostly applications, which occasionally execute DMLs, on the standby database.

## Step 3: Check lag between the primary and standby

There are several ways to check the log lag between the primary and standby.

1. From standby site, connect as sysdba, query the `v$dataguard_stats` view.

   ```
   SQL> set linesize 120;
   SQL> column name format a25;
   SQL> column value format a20;
   SQL> column time_computed format a20;
   SQL> column datum_time format a20;
   SQL> select name, value, time_computed, datum_time from v$dataguard_stats;
   
   NAME			                VALUE 	             TIME_COMPUTED	      DATUM_TIME
   ------------------------- -------------------- -------------------- --------------------
   transport lag		          +00 00:00:00	       09/05/2020 07:17:33  09/05/2020 07:17:30
   apply lag		              +00 00:00:00	       09/05/2020 07:17:33  09/05/2020 07:17:30
   apply finish time	        +00 00:00:00.000     09/05/2020 07:17:33
   estimated startup time	  9		                 09/05/2020 07:17:33
   
   SQL> 
   ```

   

2. Check the Oracle System Change Number (SCN) from the primary and standby.

   - on primary side:

     ```
     SQL> SELECT current_scn FROM v$database;
     
     CURRENT_SCN
     -----------
         2784376
     ```

     

   - on standby side:

     ```
     SQL> SELECT current_scn FROM v$database;
     
     CURRENT_SCN
     -----------
         2784330
     ```

     

3. Check with Data Guard Broker. Change `ORCL_nrt1d4` with your standby database unique name.

   ```
   [oracle@dbcs0 ~]$ dgmgrl sys/Ora_DB4U@orcl
   DGMGRL for Linux: Release 19.0.0.0.0 - Production on Sat Sep 5 07:25:52 2020
   Version 19.7.0.0.0
   
   Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
   
   Welcome to DGMGRL, type "help" for information.
   Connected to "ORCL"
   Connected as SYSDBA.
   DGMGRL> show database ORCL_nrt1d4
   
   Database - orcl_nrt1d4
   
     Role:               PHYSICAL STANDBY
     Intended State:     APPLY-ON
     Transport Lag:      0 seconds (computed 3 seconds ago)
     Apply Lag:          0 seconds (computed 3 seconds ago)
     Average Apply Rate: 6.00 KByte/s
     Real Time Query:    ON
     Instance(s):
       ORCL
   
   Database Status:
   SUCCESS
   
   DGMGRL> 
   ```

   

4. Prepare a sample workload.

5. asdf

6. asdf

7. sdaf

## Step 4: Switchover to the Cloud 

At any time, you can manually execute a Data Guard switchover (planned event) or failover (unplanned event). Customers may also choose to automate Data Guard failover by configuring Fast-Start failover. Switchover and failover reverse the roles of the databases in a Data Guard configuration – the standby in the cloud becomes primary and the original on-premise primary becomes a standby database. Refer to Oracle MAA Best Practices for additional information on Data Guard role transitions. 

Switchovers are always a planned event that guarantees no data is lost. To execute a switchover, perform the following in Data Guard Broker 

1. Connect DGMGRL from on-premise side, validate the standby database to see if Ready For Switchover is Yes. Replace `ORCL_nrt1d4` with your standby db unique name.

```
[oracle@workshop ~]$ dgmgrl sys/Ora_DB4U@orcl
DGMGRL for Linux: Release 19.0.0.0.0 - Production on Sat Feb 1 07:21:55 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Welcome to DGMGRL, type "help" for information.
Connected to "ORCL"
Connected as SYSDBA.
DGMGRL> validate database ORCL_nrt1d4

  Database Role:     Physical standby database
  Primary Database:  orcl

  Ready for Switchover:  Yes
  Ready for Failover:    Yes (Primary Running)

  Flashback Database Status:
    orcl       :  On
    orcl_nrt1d4:  Off

  Managed by Clusterware:
    orcl       :  NO             
    orcl_nrt1d4:  YES            
    Validating static connect identifier for the primary database orcl...
    The static connect identifier allows for a connection to database "orcl".

DGMGRL> 
```

2. Switch over to cloud standby database, replace `ORCL_nrt1d4` with your standby db unique name.

```
DGMGRL> switchover to orcl_nrt1d4
Performing switchover NOW, please wait...
Operation requires a connection to database "orcl_nrt1d4"
Connecting ...
Connected to "ORCL_nrt1d4"
Connected as SYSDBA.
New primary database "orcl_nrt1d4" is opening...
Operation requires start up of instance "ORCL" on database "orcl"
Starting instance "ORCL"...
Connected to an idle instance.
ORACLE instance started.
Connected to "ORCL"
Database mounted.
Database opened.
Connected to "ORCL"
Switchover succeeded, new primary is "orcl_nrt1d4"
DGMGRL> show configuration

Configuration - adgconfig

  Protection Mode: MaxPerformance
  Members:
  orcl_nrt1d4 - Primary database
    orcl        - Physical standby database 

Fast-Start Failover:  Disabled

Configuration Status:
SUCCESS   (status updated 104 seconds ago)

DGMGRL> 
```

3. Check from on-premise side. You can see the previous primary side becomes the new standby side.

```
[oracle@workshop ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 10:16:54 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB			  READ ONLY  NO
SQL> select open_mode,database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ ONLY WITH APPLY PHYSICAL STANDBY

SQL> 
```

4. Check from cloud side. You can see it's becomes the new primary side.

```
[oracle@dbstby ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Sat Feb 1 10:20:06 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB			  READ WRITE NO
SQL> select open_mode,database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ WRITE	     PRIMARY

SQL> 
```

