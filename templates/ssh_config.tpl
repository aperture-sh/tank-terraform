Host *
	SendEnv LANG LC_*

Host ${ private_network }
  IdentityFile ${ ssh_key }
  ProxyCommand ssh ubuntu@${ bastion_node } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p

%{if public_network != ""}
Host ${ public_network }
  IdentityFile ${ ssh_key }
  ProxyCommand ssh ubuntu@${ bastion_node } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p
%{ endif }

%{if private_network2 != ""}
Host ${ private_network2 }
  IdentityFile ${ ssh_key }
  ProxyCommand ssh ubuntu@${ bastion_node } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p
%{ endif }

%{if public_network2 != ""}
Host ${ public_network2 }
  IdentityFile ${ ssh_key }
  ProxyCommand ssh ubuntu@${ bastion_node } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p
%{ endif }

Host ${ bastion_node }
  IdentityFile ${ ssh_key }
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%C
  ControlPersist 5m