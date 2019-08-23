[all:vars]
ansible_user=${ vm_username }
#ansible_ssh_private_key_file=/var/ans/master_key
ansible_python_interpreter=/usr/bin/python3
docker_username=${docker_username}
docker_password=${docker_password}
setupElk=False
teardownElk=False
pruneData=True
cassandra_data_dir=${ cassandra_data_dir }
proxy_node_public_ip=${ bastion_node }
public_endpoint=${ public_endpoint }
cloud_provider=${ cloud_provider }

[proxy_nodes]
${ proxy_node }

[proxy_nodes:vars]
nginx_config_file=/etc/nginx/nginx.conf

[cassandra:children]
cassandra_nodes

[cassandra:vars]
cassandra_config_file=/etc/cassandra/cassandra.yaml
cassandra_cluster_name=tankstore
cassandra_data_dir=${ cassandra_data_dir }/db
cassandra_commitlog_dir=${ cassandra_data_dir }/commitlog
cassandra_hint_dir=${ cassandra_data_dir }/hints
use_db_vol=true
db_vol=${ db_vol_device }
number_of_seeds=${number_of_seeds}

[cassandra_nodes]
${ cassandra_nodes }

[tank_nodes]
${ tank_nodes }


[tank_nodes:vars]
navigator_config_file=/opt/navigator/config.json
mapbox_key=${ mapbox_key }
