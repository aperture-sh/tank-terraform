resource "openstack_blockstorage_volume_v2" "db_vol" {
  name = "db-vol-${count.index}"
  count = "${var.cassandra_node_count}"
  size = "${var.cassandra_disk_size}"
}

resource "openstack_compute_volume_attach_v2" "db_vol_attached" {
  count = "${var.cassandra_node_count}"
  instance_id = "${element(openstack_compute_instance_v2.cassandra.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.db_vol.*.id, count.index)}"
}
