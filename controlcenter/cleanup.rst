Cleaning out all Docker Images
=====================================================================

* cdz build; ./services/repos/docker_mrclean.sh 
* Now go through manual install of all docker images
* Manually rebuild serviced

Upgrading/Cleaning the Docker Folder /var/lib/docker
=====================================================================

If you need to upgrade or purfiy Docker you can do::

   sudo stop docker
   umount $(grep 'aufs' /proc/mounts | awk '{print$2}' | sort -r)
   rm -rf /var/lib/docker
   # => [Upgrade Docker if needed]
   # => Re-install your images or rebuild zendev


Cleaning out Serviced Templates
=====================================================================
For now these live in /tmp/serviced-root . 
Here are the steps:

* stop serviced
* rm -rf /tmp/serviced-root
* Re-deploy your templates
