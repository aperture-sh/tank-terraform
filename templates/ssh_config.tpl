Host *
	SendEnv LANG LC_*

Host ${ network }
  IdentityFile ${ ssh_key }
  ProxyCommand ssh ubuntu@${ bastion_node } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p

Host ${ bastion_node }
  IdentityFile ${ ssh_key }
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%r@%h:%p
  ControlPersist 5m