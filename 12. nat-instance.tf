#############################
### Key Initialization
#############################
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "key-file-g8n" {
	provisioner "local-exec" {
		command = "rm -rf ${var.private_key_file}"
	}

	provisioner "local-exec" {
		command = "test -e ${var.private_key_file} || echo \"${tls_private_key.ssh-key.private_key_pem}\" > ${var.private_key_file} && chmod 400 ${var.private_key_file}"
	}
}

#############################
### VPC Initialization
#############################
resource "yandex_vpc_network" "vpc" {
	name = "nat-vpc"
}


resource "yandex_vpc_subnet" "subnet" {
	name = "nat-subnet"
	v4_cidr_blocks = ["10.1.0.0/24"]
	zone = "${var.azone}"
	network_id = "${yandex_vpc_network.vpc.id}"
}


#############################
### Instance Initialization
#############################
data "template_file" "init" {
	template = "${file("templates/userdata.tpl")}"

	vars {
		username = "${var.username}"
		public_key = "${tls_private_key.ssh-key.public_key_openssh}"
	}
}


resource "yandex_compute_instance" "nat-instance" {
	name = "${var.nat_instance_name}"
	platform_id = "standard-v1"
	zone = "${yandex_vpc_subnet.subnet.zone}"

	resources {
		cores  = "${var.nat_instance_cpu_count}"
		memory = "${var.nat_instance_ram_size}"
	}

	boot_disk {
		initialize_params {
			image_id = "${data.yandex_compute_image.centos7.id}"
			size = "${var.nat_instance_disk_size}"
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
		scripts = "${var.nat_instance_script}"

		connection {
			type = "ssh"
			user = "${var.username}"
			private_key = "${tls_private_key.ssh-key.private_key_pem}"
		}
	}
}