Analytics trobleshooting guide
==============================

Based on docs by William Gerber.

What problem do you have?
=========================

- `I get no reports`_.

I get no reports
================

Are your batches working? 

- **Yes:** `Can you log into Zenoss Analytics at all?`_
- **No:** `My batches are not working`_

My batches are not working
==========================
See at what state they are stuck in at the web UI:

- **Unstarted:** `Zenetl or zenperfetl daemon fails`_
- **Extracting:** `Zenetl or zenperfetl daemon fails`_
- **Staging:** `Is it model data in staging?`_
- **Failed:**  ????

Can you log into Zenoss Analytics at all?
=========================================

Zenetl or zenperfetl daemon fails
=================================
Have you configured the 4 URLS for Analytics through the WEB UI?

If no, then go configure them.

Update each Hub and Collector so it gets the proper config properties

Check to see if the collector can hit the Analytics server.  From the command prompt do the following:
``wget http://analytics_server_url/reporting``

Did you get a text file without error?

- **Yes:** `Is there enough space on the hard drives to write files to?`_
- **No:** `Check analytics availability from collector`_

Is there enough space on the hard drives to write files to?
===========================================================

Check analytics availability from collector
===========================================

Is it model data in staging?
============================
- **No:** `Check triggers`_
- **Yes:** Has it been in staging over 4 hours?

  - **No:** We only check for Model batches ready to load into DB once every 4 hours.
  - **Yes:** `Check triggers`_

Check triggers
==============
Log into the reporting database and run this query a few times over a couple of minutes:

``select trigger_name, from_unixtime(next_fire_time/1000) as next_time,
from_unixtime(prev_fire_time/1000) as last_time, trigger_state from reporting.QRTZ_TRIGGERS;``

Are some of the triggers state stuck in blocked? If yes, then something caused one or more of the triggers to fail
repeatedly and the system finally gave up.  Fix the root cause and then update the QRTZ_TRIGGERS table to a state of WAITING and bounce the zenoss_analytics service.

Go to the Analytics application server and look through the ``/opt/zenoss_analytics/zenoss_analytics.log`` file for glaring errors. **or ``/opt/zenoss_analytics/webapps/zenoss-analytics/WEB-INF/logs/jasperserver.log`` ????**
