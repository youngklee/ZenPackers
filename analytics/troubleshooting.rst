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
- **Staging:**
- **Failed:**

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
