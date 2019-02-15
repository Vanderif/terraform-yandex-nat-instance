resource "yandex_vpc_network" "vpc" {
	name = "${var.project_name_prefix}-vpc"
}


resource "yandex_vpc_subnet" "subnet" {
	name           = "${var.project_name_prefix}-subnet"
	v4_cidr_blocks = ["10.1.0.0/24"]
	zone           = "${var.azone}"
	network_id     = "${yandex_vpc_network.vpc.id}"
}