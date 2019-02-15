data "template_file" "init" {
	template = "${file("templates/userdata.tpl")}"

	vars {
		username = "${var.username}"
		public_key = "${tls_private_key.ssh-key.public_key_openssh}"
	}
}


resource "yandex_compute_instance" "master" {
	count = "${var.master_count}"

	name = "${format("%s%02d", var.master_name_prefix, count.index)}"
	platform_id = "standard-v1"
	zone = "${var.azone}"

	resources {
		cores  = "${var.master_cpu_count}"
		memory = "${var.master_cpu_count * 8}"
	}

	boot_disk {
		initialize_params {
			image_id = "${data.yandex_compute_image.centos7.id}"
			size = 15
			type_id = "network-nvme"
		}
	}

	network_interface {
		subnet_id = "${yandex_vpc_subnet.subnet.id}"
		nat = true
	}

	metadata {
		user-data = "${data.template_file.init.rendered}"
	}

	provisioner "remote-exec" {
		scripts = "${var.master_scripts_list}"

		connection {
			type = "ssh"
			user = "${var.username}"
			private_key = "${tls_private_key.ssh-key.private_key_pem}"
		}
	}
}


resource "yandex_compute_disk" "worker-disk" {
	count = "${5 * var.worker_count}"

	name = "${format("%s-disk%02d", var.worker_name_prefix, count.index)}"
	type = "network-nvme"
	size = "${var.worker_disk_size}"
}


resource "yandex_compute_instance" "worker" {
	count = "${var.worker_count}"

	name = "${format("%s%02d", var.worker_name_prefix, count.index)}"
	platform_id = "standard-v1"
	zone = "${var.azone}"
	allow_stopping_for_update = true

	resources {
		cores  = "${var.worker_cpu_count}"
		memory = "${var.worker_cpu_count * 8}"
	}

	boot_disk {
		initialize_params {
			image_id = "${data.yandex_compute_image.centos7.id}"
			size = 15
			type_id = "network-nvme"
		}
	}

	secondary_disk {
		disk_id = "${element(yandex_compute_disk.worker-disk.*.id, count.index * 5 + 0)}"
		auto_delete = true
	}
	secondary_disk {
		disk_id = "${element(yandex_compute_disk.worker-disk.*.id, count.index * 5 + 1)}"
		auto_delete = true
	}
	secondary_disk {
		disk_id = "${element(yandex_compute_disk.worker-disk.*.id, count.index * 5 + 2)}"
		auto_delete = true
	}
	secondary_disk {
		disk_id = "${element(yandex_compute_disk.worker-disk.*.id, count.index * 5 + 3)}"
		auto_delete = true
	}
	secondary_disk {
		disk_id = "${element(yandex_compute_disk.worker-disk.*.id, count.index * 5 + 4)}"
		auto_delete = true
	}

	network_interface {
		subnet_id = "${yandex_vpc_subnet.subnet.id}"
		nat = true
	}

	metadata {
		user-data = "${data.template_file.init.rendered}"
	}

	provisioner "remote-exec" {
		scripts = "${var.worker_scripts_list}"

		connection {
			type = "ssh"
			user = "${var.username}"
			private_key = "${tls_private_key.ssh-key.private_key_pem}"
		}
	}
}