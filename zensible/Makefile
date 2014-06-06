
default: site

# %:
#       ansible-playbook -i production -K $@.yml 

 zenoss:
	ansible-playbook -i production zenoss.yml -k

 vars:
	ansible -u zenoss -m setup -i production zenoss  > vars.txt

