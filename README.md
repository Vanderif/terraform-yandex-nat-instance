# Yandex Cloud NAT Gateway Deployment

## Usage

* Create terraform.tfvars file or use system environmets to set variables.
	List of mandatory variables:
	- token
	- cloud_id
	- folder_id
* Run `terraform init` and `terraform plan` if needed
* Optional. If you need to add NAT Gateway to existing VPC:
	- Run `terraform import yandex_vpc_network.vpc <VPC_ID>`
	- Run `terraform import yandex_vpc_subnet.subnet <SUBNET_ID>`
	- Set AZ variiable `azone`
* Run `terraform apply`
* From Yandex Cloud Console:
	- Create Route Table and Static Route using private IP address of NAT Gateway instance
	- Apply created Route Table to subnet

## Notes

* Use `key.pem` file to ssh to Nat Gateway instance