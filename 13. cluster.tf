data "template_file" "master_public" {
	count = "${yandex_compute_instance.master.count}"

	template = "${file("templates/hosts.tpl")}"
	vars {
		ip = "${element(yandex_compute_instance.master.*.network_interface.0.nat_ip_address, count.index)}"
		name   = "${element(yandex_compute_instance.master.*.name, count.index)}"
	}
}


data "template_file" "master_private" {
	count = "${yandex_compute_instance.master.count}"

	template = "${file("templates/hosts.tpl")}"
	vars {
		ip = "${element(yandex_compute_instance.master.*.network_interface.0.ip_address, count.index)}"
		name   = "${element(yandex_compute_instance.master.*.name, count.index)}-internal"
	}
}


data "template_file" "worker_public" {
	count = "${yandex_compute_instance.worker.count}"

	template = "${file("templates/hosts.tpl")}"
	vars {
		ip = "${element(yandex_compute_instance.worker.*.network_interface.0.nat_ip_address, count.index)}"
		name   = "${element(yandex_compute_instance.worker.*.name, count.index)}"
	}
}


data "template_file" "worker_private" {
	count = "${yandex_compute_instance.worker.count}"

	template = "${file("templates/hosts.tpl")}"
	vars {
		ip = "${element(yandex_compute_instance.worker.*.network_interface.0.ip_address, count.index)}"
		name   = "${element(yandex_compute_instance.worker.*.name, count.index)}-internal"
	}
}


data "template_file" "allhosts" {
	template = "${file("templates/allhosts.tpl")}"

	vars {
		masters_public_ip_hosts = "${join("\n", data.template_file.master_public.*.rendered)}"
		masters_private_ip_hosts = "${join("\n", data.template_file.master_private.*.rendered)}"
		workers_public_ip_hosts = "${join("\n", data.template_file.worker_public.*.rendered)}"
		workers_private_ip_hosts = "${join("\n", data.template_file.worker_private.*.rendered)}"
	}
}


resource "null_resource" "master_hosts_init" {
	count = "${yandex_compute_instance.master.count}"
    
	provisioner "remote-exec" {
		inline = [
			"sudo sh -c \"echo '${data.template_file.allhosts.rendered}' >> /etc/hosts\""
		]

		connection {
			host = "${element(yandex_compute_instance.master.*.network_interface.0.nat_ip_address, count.index)}"
			type = "ssh"
			user = "${var.username}"
			private_key = "${tls_private_key.ssh-key.private_key_pem}"
		}
	}
}


resource "null_resource" "worker_hosts_init" {
	count = "${yandex_compute_instance.worker.count}"
    
	provisioner "remote-exec" {
		inline = [
			"sudo sh -c \"echo '${data.template_file.allhosts.rendered}' >> /etc/hosts\""
		]

		connection {
			host = "${element(yandex_compute_instance.worker.*.network_interface.0.nat_ip_address, count.index)}"
			type = "ssh"
			user = "${var.username}"
			private_key = "${tls_private_key.ssh-key.private_key_pem}"
		}
	}
}


resource "null_resource" "outputs_init" {
	provisioner "local-exec" {
		command = "test -e ${var.output_path} || mkdir -p ${var.output_path}"
	}

	provisioner "local-exec" {
		command = "rm -rf ${var.output_path}*"
	}

	provisioner "local-exec" {
		command = "test -e ${var.private_key_file} || echo \"${tls_private_key.ssh-key.private_key_pem}\" > ${var.private_key_file} && chmod 400 ${var.private_key_file}"
	}
}