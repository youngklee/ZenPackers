Cleaning out all Docker Images
=====================================================================

* cdz build; ./services/repos/docker_mrclean.sh 
* Now go through manual install of all docker images
* Manually rebuild serviced

Cleaning out Serviced Templates
=====================================================================
For now these live in /tmp/serviced-root . 
Here are the steps:

* stop serviced
* rm -rf /tmp/serviced-root
* Re-deploy your templates
