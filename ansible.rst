==============================================================================
Ansible Rough Guide
==============================================================================
.. image:: _static/zebraffe.png
   :scale: 50 %


Description
------------------------------------------------------------------------------

Ansible is a DevOps tool. Its actions are called **Plays** and groups of those
actions are called **Playbooks**.  Ansible is designed to be easy to install,
implement and use.

Prerequisites
------------------------------------------------------------------------------

* Linux 
* Python 2.7
* Ansible

Setup
-----------------------------------------------------------------------------
Once you setup your server with the ansible software (its CLI driven),
you simply make sure you can SSH into your target hosts. You can Setup
SSH passphrases if you like, but it works regardless.
You can also run on non-standard (non-22) tcp port numbers.


Inventory
------------------------------------------------------------------------------

You define your managed hosts with **Inventory Files**. 


:: 

   # ------------------------------------------------------------------
   # file: production

   [monitors]
   mp1.zenoss.loc
   mp2.zenoss.loc  ansible_ssh_port=2201 ansible_ssh_host=90.14.17.12

   [locals]
   localhost              ansible_connection=local

Group Vars and Host Vars
-----------------------------
Group and Host vars are simple YAML files. 
From your ansible root, they are located in::

  $ANSIBLE/group_vars
  $ANSIBLE/host_vars

An example of group and host vars:

 [joe@zen:~/ansible]: cat group_vars/all 

::

   # ================= Ansible Group Vars: ALL ========================
   ---
   # Variables listed here are applicable to all host groups

   http_port: 80
   https_port: 443
   ntpserver: us.pool.ntp.org
   git_repo: http://github.com/xxx/mywebapp.git
   sudo_user: joe
   opt_bin: /opt/bin
   opt_log: /opt/log
   maven_url: http://www.eng.lsu.edu/3.0/binaries/apache-maven-3.0.5-bin.tar.gz

and some host vars....

 [joe@zen:~/ansible]: cat host_vars/mp1.zenoss.loc

::

   backup_tools:
     - backup_files
     - backup_home
     - disk_backup_dirvish
     - find_duplicates
     - report_df
     - reset_cronlog
     - restart_apcmon
     - sudo_dirvish
     - rsync-new

   dirvish_master: False

   hourly_jobs:
    - check_raid
    - check_space

   daily_jobs: [] 

Playbooks
--------------------------------------------------------------------

Playbooks contain the commands that configure the targets.
A playbook is YAML file that has some commands in it.
It can be simply a bunch of commands in a single file or group of files.

Each section is YAML and is indented by 2 at each level.
A simple example is::
   
   # A very simple example for a CentOS box
   ---
   - name: Ensure needed packages are the latest version
     yum: pkg={{item}} state=latest
     with_items: 
       - lxc
       - make
       - icewm
       - openbox


Roles: Getting Organized
---------------------------------------------------------------
Roles allow you to organize your tasks. A Roles folder lives in 
the Ansible root and has a series of folders that correspond to
task groups::

  ansible
  |   
  |-- group_vars
  |   \-- all
  |-- host_vars
  |   |-- 192.168.12.7
  |   \-- mp2.zenoss.loc
  |-- laptops.yml
  |-- production
  |-- roles
  |   |-- common
  |   |-- network
  |   |-- security
  |   \-- zenoss
  \-- zenoss.yml


Inside of each role are the following directories which ansible will
automatically search for needed files:

 [joe@zenpad:~/ansible]: tree -L 1 roles/security

::

  ansible/roles/security/
  |-- files
  |-- handlers
  |-- tasks
  |-- templates
  \-- vars

Here is the lowdown on what goes in these folders:

* **files**: Just plain old files for copy
* **handlers**: plays that get triggered by a *notify* event
* **tasks**: the big enchilada play
* **templates**: files that get templated
* **vars**: any vars local to the role


So full blown security folder looks like this:

 [joe@zenpad:~/ansible]: tree -L 5 roles/network

::

  roles/network/
  |-- files
  |-- handlers
  |   |-- main.yml
  |-- tasks
  |   |-- centos.yml
  |   |-- debian.yml
  |   |-- main.yml
  |   |-- ubuntu.yml
  |-- templates
  |   |-- ifcfg-eth0
  |   |-- ifcfg-eth2
  |   |-- ifcfg-static
  |   |-- network
  |   \-- sysconfig
  |       \-- network-scripts
  \- vars

Thats enough theory. Lets do some demonstrations!

Links:

* Ansible Intro: http://docs.ansible.com/intro.html
* Ansible Modules: http://www.ansibleworks.com/docs/modules.html
* Best Practices:  http://www.ansibleworks.com/docs/playbooks_best_practices.html
* http://jpmens.net/2012/08/30/ansible-variables-variables-and-more-variables/
* Download the associated video :download:`ansible.avi <ansible.avi>`
