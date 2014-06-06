DB2 Information for Scavengers
===============================

Some Base links:
-----------------

* http://www.tldp.org/HOWTO/DB2-HOWTO/planning.html
* http://www.centos.org/docs/2/rh-cm-en-1.0/s1-service-db2.html
* http://www.dbforums.com/db2/1655091-db2-cpu-time-wait-time.html
* http://stackoverflow.com/questions/15382561/adding-db2-jars-to-java-webapp-using-maven


Supported drivers for JDBC and SQLJ
------------------------------------

The DB2 product includes support for two types of JDBC driver architecture.
According to the JDBC specification, there are four types of JDBC driver architectures:

* Type 1 (Wont work for Zenpack. Not supported in DB2)

   Drivers that implement the JDBC API as a mapping to another data access
   API, such as Open Database Connectivity (ODBC). Drivers of this type are
   generally dependent on a native library, which limits their portability.
   The DB2 database system does not provide a type 1 driver.

* Type 2 (Might work, but not portable)

   Drivers that are written partly in the Java programming language and partly
   in native code. The drivers use a native client library specific to the
   data source to which they connect. Because of the native code, their
   portability is limited.

* Type 3 (Standard Choice without the fancy Type 4 options. Use if possible)

   Drivers that use a pure Java client and communicate with a data server
   using a data-server-independent protocol. The data server then communicates
   the client's requests to the data source. 

* Type 4 (Fancy Options: Not needed)

   Drivers that are pure Java and implement the network protocol for a specific
   data source. The client connects directly to the data source.


DB2 vs Oracle
--------------

:: 

                         DB2-Oracle Terminology Mapping

   Because Oracle applications can be enabled to work with DB2® data servers
   when the DB2 environment is set up appropriately, it is important to
   understand how certain Oracle concepts map to DB2 concepts.

   Table 1 provides a concise summary of commonly used Oracle terms and
   their DB2 equivalents.

           Table 1. Mapping of common Oracle concepts to DB2 concepts
   +------------------------------------------------------------------------+
   |     Oracle concept     |    DB2 concept    |           Notes           |
   |------------------------+-------------------+---------------------------|
   | active log             | active log        | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | actual parameter       | argument          | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | alert log              | db2diag log files | The db2diag log files are |
   |                        | and               | primarily intended for    |
   |                        | administration    | use by IBM Software       |
   |                        | notification log  | Support for               |
   |                        |                   | troubleshooting purposes. |
   |                        |                   | The administration        |
   |                        |                   | notification log is       |
   |                        |                   | primarily intended for    |
   |                        |                   | troubleshooting use by    |
   |                        |                   | database and system       |
   |                        |                   | administrators.           |
   |                        |                   | Administration            |
   |                        |                   | notification log messages |
   |                        |                   | are also logged to the    |
   |                        |                   | db2diag log files using a |
   |                        |                   | standardized message      |
   |                        |                   | format.                   |
   |------------------------+-------------------+---------------------------|
   | archive log            | offline-archive   | This is the same concept. |
   |                        | log               |                           |
   |------------------------+-------------------+---------------------------|
   | archive log mode       | log archiving     | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | background_dump_dest   | diagpath          | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | created global         | created global    | This is the same concept. |
   | temporary table        | temporary table   |                           |
   |------------------------+-------------------+---------------------------|
   | cursor sharing         | statement         | This is the same concept. |
   |                        | concentrator      |                           |
   |------------------------+-------------------+---------------------------|
   | data block             | data page         | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | data buffer cache      | buffer pool       | This is the same concept. |
   |                        |                   | However, in DB2 you can   |
   |                        |                   | have as many buffer pools |
   |                        |                   | of any page size you      |
   |                        |                   | like.                     |
   |------------------------+-------------------+---------------------------|
   | data dictionary        | system catalog    | The DB2 system catalog    |
   |                        |                   | contains metadata in the  |
   |                        |                   | form of tables and views. |
   |                        |                   | The database manager      |
   |                        |                   | creates and maintains two |
   |                        |                   | sets of system catalog    |
   |                        |                   | views that are defined on |
   |                        |                   | the base system catalog   |
   |                        |                   | tables:                   |
   |                        |                   |                           |
   |                        |                   |   * SYSCAT views, which   |
   |                        |                   |     are read-only views   |
   |                        |                   |   * SYSSTAT views, which  |
   |                        |                   |     are updatable views   |
   |                        |                   |     that contain          |
   |                        |                   |     statistical           |
   |                        |                   |     information that is   |
   |                        |                   |     used by the optimizer |
   |------------------------+-------------------+---------------------------|
   | data dictionary cache  | catalog cache     | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | data file              | container         | DB2 data is physically    |
   |                        |                   | stored in containers,     |
   |                        |                   | which contain objects.    |
   |------------------------+-------------------+---------------------------|
   | database link          | nickname          | A nickname is an          |
   |                        |                   | identifier that refers to |
   |                        |                   | an object at a remote     |
   |                        |                   | data source (a federated  |
   |                        |                   | database object).         |
   |------------------------+-------------------+---------------------------|
   | dual table             | dual table        | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | dynamic performance    | snapshot monitor  | Snapshot monitor SQL      |
   | views                  | SQL               | administrative views,     |
   |                        | administrative    | which use schema          |
   |                        | views             | SYSIBMADM, return monitor |
   |                        |                   | data about a specific     |
   |                        |                   | area of the database      |
   |                        |                   | system. For example, the  |
   |                        |                   | SYSIBMADM.SNAPBP SQL      |
   |                        |                   | administrative view       |
   |                        |                   | provides a snapshot of    |
   |                        |                   | buffer pool information.  |
   |------------------------+-------------------+---------------------------|
   | extent                 | extent            | A DB2 extent is made up   |
   |                        |                   | of a set of contiguous    |
   |                        |                   | data pages.               |
   |------------------------+-------------------+---------------------------|
   | formal parameter       | parameter         | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | global index           | nonpartitioned    | This is the same concept. |
   |                        | index             |                           |
   |------------------------+-------------------+---------------------------|
   | inactive log           | online-archive    | This is the same concept. |
   |                        | log               |                           |
   |------------------------+-------------------+---------------------------|
   | init.ora and Server    | database manager  | A DB2 instance can        |
   | Parameter File         | configuration     | contain multiple          |
   | (SPFILE)               | file and database | databases. Therefore,     |
   |                        | configuration     | configuration parameters  |
   |                        | file              | and their values are      |
   |                        |                   | stored at both the        |
   |                        |                   | instance level, in the    |
   |                        |                   | database manager          |
   |                        |                   | configuration file, and   |
   |                        |                   | at the database level, in |
   |                        |                   | the database              |
   |                        |                   | configuration file. These |
   |                        |                   | files are managed through |
   |                        |                   | the GET or UPDATE DBM CFG |
   |                        |                   | command and the GET or    |
   |                        |                   | UPDATE DB CFG command,    |
   |                        |                   | respectively.             |
   |------------------------+-------------------+---------------------------|
   | instance               | instance or       | An instance is a          |
   |                        | database manager  | combination of background |
   |                        |                   | processes and shared      |
   |                        |                   | memory. A DB2 instance is |
   |                        |                   | also known as a database  |
   |                        |                   | manager. Because a DB2    |
   |                        |                   | instance can contain      |
   |                        |                   | multiple databases, there |
   |                        |                   | are DB2 configuration     |
   |                        |                   | files at both the         |
   |                        |                   | instance level (the       |
   |                        |                   | database manager          |
   |                        |                   | configuration file) and   |
   |                        |                   | at the database level     |
   |                        |                   | (the database             |
   |                        |                   | configuration file).      |
   |------------------------+-------------------+---------------------------|
   | large pool             | utility heap      | The utility heap is used  |
   |                        |                   | by the backup, restore,   |
   |                        |                   | and load utilities.       |
   |------------------------+-------------------+---------------------------|
   | library cache          | package cache     | The package cache, which  |
   |                        |                   | is allocated from         |
   |                        |                   | database shared memory,   |
   |                        |                   | is used to cache sections |
   |                        |                   | for static and dynamic    |
   |                        |                   | SQL and XQuery statements |
   |                        |                   | on a database.            |
   |------------------------+-------------------+---------------------------|
   | local index            | partitioned index | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | materialized view      | materialized      | An MQT is a table whose   |
   |                        | query table (MQT) | definition is based on    |
   |                        |                   | the results of a query    |
   |                        |                   | and is meant to be used   |
   |                        |                   | to improve performance.   |
   |                        |                   | The DB2 SQL compiler      |
   |                        |                   | determines whether a      |
   |                        |                   | query would run more      |
   |                        |                   | efficiently against an    |
   |                        |                   | MQT than it would against |
   |                        |                   | the base table on which   |
   |                        |                   | the MQT is based.         |
   |------------------------+-------------------+---------------------------|
   | noarchive log mode     | circular logging  | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | Oracle Call Interface  | DB2CI Interface   | DB2CI is a 'C' and 'C++'  |
   | (OCI)                  |                   | application programming   |
   |                        |                   | interface that uses       |
   |                        |                   | function calls to connect |
   |                        |                   | to DB2 Version 9.7        |
   |                        |                   | databases, manage         |
   |                        |                   | cursors, and perform SQL  |
   |                        |                   | statements. See [4]IBM    |
   |                        |                   | Data Server Driver for    |
   |                        |                   | DB2CI for a list of OCI   |
   |                        |                   | APIs supported by the     |
   |                        |                   | DB2CI driver.             |
   |------------------------+-------------------+---------------------------|
   | Oracle Call Interface  | Call Level        | CLI is a C and C++        |
   | (OCI)                  | Interface (CLI)   | application programming   |
   |                        |                   | interface that uses       |
   |                        |                   | function calls to pass    |
   |                        |                   | dynamic SQL statements as |
   |                        |                   | function arguments. In    |
   |                        |                   | most cases, you can       |
   |                        |                   | replace an OCI function   |
   |                        |                   | with a CLI function and   |
   |                        |                   | relevant changes to the   |
   |                        |                   | supporting program code.  |
   |------------------------+-------------------+---------------------------|
   | ORACLE_SID environment | DB2INSTANCE       | This is the same concept. |
   | variable               | environment       |                           |
   |                        | variable          |                           |
   |------------------------+-------------------+---------------------------|
   | partitioned tables     | partitioned       | This is the same concept. |
   |                        | tables            |                           |
   |------------------------+-------------------+---------------------------|
   | Procedural             | SQL Procedural    | SQL PL is an extension of |
   | Language/Structured    | Language (SQL PL) | SQL that consists of      |
   | Query Language         |                   | statements and language   |
   | (PL/SQL)               |                   | elements. SQL PL provides |
   |                        |                   | statements for declaring  |
   |                        |                   | variables and condition   |
   |                        |                   | handlers, assigning       |
   |                        |                   | values to variables, and  |
   |                        |                   | implementing procedural   |
   |                        |                   | logic. SQL PL is a subset |
   |                        |                   | of the SQL Persistent     |
   |                        |                   | Stored Modules (SQL/PSM)  |
   |                        |                   | language standard. Oracle |
   |                        |                   | PL/SQL statements can be  |
   |                        |                   | compiled and executed     |
   |                        |                   | using DB2 interfaces.     |
   |------------------------+-------------------+---------------------------|
   | program global area    | application       | Application shared memory |
   | (PGA)                  | shared memory and | stores information that   |
   |                        | agent private     | is shared between a       |
   |                        | memory            | database and a particular |
   |                        |                   | application: primarily,   |
   |                        |                   | rows of data being passed |
   |                        |                   | to or from the database.  |
   |                        |                   | Agent private memory      |
   |                        |                   | stores information used   |
   |                        |                   | to service a particular   |
   |                        |                   | application, such as sort |
   |                        |                   | heaps, cursor             |
   |                        |                   | information, and session  |
   |                        |                   | contexts.                 |
   |------------------------+-------------------+---------------------------|
   | redo log               | transaction log   | The transaction log       |
   |                        |                   | records database          |
   |                        |                   | transactions and can be   |
   |                        |                   | used for recovery.        |
   |------------------------+-------------------+---------------------------|
   | role                   | role              | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | segment                | storage object    | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | session                | session; database | This is the same concept. |
   |                        | connection        |                           |
   |------------------------+-------------------+---------------------------|
   | startup nomount        | db2start          | The command that starts   |
   |                        |                   | the instance.             |
   |------------------------+-------------------+---------------------------|
   | synonym                | alias             | An alias is an            |
   |                        |                   | alternative name for a    |
   |                        |                   | table, view, nickname, or |
   |                        |                   | another alias. The term   |
   |                        |                   | "synonym" is tolerated    |
   |                        |                   | and can be specified in   |
   |                        |                   | place of "alias". Aliases |
   |                        |                   | are not used to control   |
   |                        |                   | what version of a DB2     |
   |                        |                   | procedure or user-defined |
   |                        |                   | function is being used by |
   |                        |                   | an application; to do     |
   |                        |                   | this, use the SET PATH    |
   |                        |                   | statement to add the      |
   |                        |                   | required schema to the    |
   |                        |                   | value of the CURRENT PATH |
   |                        |                   | special register.         |
   |------------------------+-------------------+---------------------------|
   | system global area     | instance shared   | The instance shared       |
   | (SGA)                  | memory and        | memory stores all of the  |
   |                        | database shared   | information for a         |
   |                        | memory            | particular instance, such |
   |                        |                   | as lists of all active    |
   |                        |                   | connections and security  |
   |                        |                   | information. The database |
   |                        |                   | shared memory stores      |
   |                        |                   | information for a         |
   |                        |                   | particular database, such |
   |                        |                   | as package caches, log    |
   |                        |                   | buffers, and buffer       |
   |                        |                   | pools.                    |
   |------------------------+-------------------+---------------------------|
   | SYSTEM table space     | SYSCATSPACE table | The SYSCATSPACE table     |
   |                        | space             | space contains the system |
   |                        |                   | catalog. This table space |
   |                        |                   | is created by default     |
   |                        |                   | when you create a         |
   |                        |                   | database.                 |
   |------------------------+-------------------+---------------------------|
   | table space            | table space       | This is the same concept. |
   |------------------------+-------------------+---------------------------|
   | user global area (UGA) | application       | Application global memory |
   |                        | global memory     | comprises application     |
   |                        |                   | shared memory and         |
   |                        |                   | application-specific      |
   |                        |                   | memory.                   |
   +------------------------------------------------------------------------+


Installing DB2 Express on Linux
---------------------------------

* First you must install Linux
* Next install the prerequisites for DB2
* Make sure the client can do X11 Forwarding to your workstation
* Download DB2 Express, extract it in /opt
* SSH into your instance as root, X11 forwarding on
* Run the installer at /opt/expc/db2setup
* Select defaults and make sure to save set in the Response File
* If you can't type into Java, just cut-n-paste passwords 
* Make sure the installer finishes without error
* Save the Response File
* Next time use the Response File to install all
* Once installed, issue "db2sampl" to create a sample db.
  - db2 connect to sample
  - db2 'select * from dept'


Links for Installation:

* http://www.ibiblio.org/pub/linux/docs/HOWTO/DB2-HOWTO
* http://www.tldp.org/HOWTO/DB2-HOWTO/prerequisites.html
* http://www.sqlpanda.com/2013/08/install-db2-105-on-centos-64.html

Removing DB2 on Linux
------------------------

* Remove the Database Administration Server::

   sudo su - dasusr1 db2admin stop
   /opt/ibm/db2/V10.5/instance/dasdrop dasusr1 

* Remove the DB2 instance(s)::

   sudo su - db2inst1 -c db2stop
   /opt/ibm/db2/V10.5/instance/db2ilist
   /opt/ibm/db2/V10.5/instance/db2idrop db2inst1
   /opt/ibm/db2/V10.5/instance/db2ilist

* Remove the software installation::

   /opt/ibm/db2/V10.5/install/db2_deinstall -a

* Remote the user accounts too::

   userdel -r db2inst1
   userdel -r dasusr1
   userdel -r db2fenc1


