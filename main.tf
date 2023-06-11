locals {
  bastion_ip = "52.38.111.95/32" # This is the ip for the production bastion

  tags = [
    {
      name  = "Environment"
      value = var.environment
    },
    {
      name  = "Stage"
      value = var.stage
    },
    {
      name  = "Service"
      value = "Proxies"
    },
    {
      name  = "Team"
      value = "DevOps"
    },
    {
      name  = "CostCenter"
      value = var.environment == "production" ? "Common" : "Development"
    },
    {
      name : "Region",
      value : var.region,
    },
  ]

  puppet_master      = "puppet.production.legitscript.com"
  availability_zones = length(var.availability_zone_override) > 0 ? var.availability_zone_override : [
    data.aws_availability_zones.all_zones.names[0],
    data.aws_availability_zones.all_zones.names[1],
    data.aws_availability_zones.all_zones.names[2],
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.63.0"

  name = "proxy-vpc-${var.stage}"
  cidr = "${var.vpc_cidr_prefix}.0.0/16"

  azs            = local.availability_zones
  public_subnets = ["${var.vpc_cidr_prefix}.1.0/24", "${var.vpc_cidr_prefix}.2.0/24", "${var.vpc_cidr_prefix}.3.0/24"]

  enable_nat_gateway = false

  tags = {
  for tag in local.tags :
  tag.name => tag.value
  }
}

resource "aws_security_group" "proxy_security_group" {
  # tflint-ignore: all
  name        = "proxy-${var.stage}-${var.region}-security-group"
  description = "Security group for ${var.stage} proxies in ${var.region}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.vpn_public_ip]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [local.bastion_ip]
  }

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  for tag in concat([
    {
      name : "Name",
      value : "proxy-${var.stage}-${var.region}-security-group",
    },
  ], local.tags) :
  tag.name => tag.value
  }
}

module "proxies" {
  source = "./modules/proxy"

  count = length(var.proxy_names)

  ami_id             = nonsensitive(data.aws_ssm_parameter.amazon_linux_2_ami.value)
  use_elastic_ip     = var.use_elastic_ips
  instance_type      = var.override_instance_type != "" ? var.override_instance_type : var.instance_type # if instance type needs to be specific to local zone
  subnet_id          = module.vpc.public_subnets[count.index % 3]
  security_group_ids = [aws_security_group.proxy_security_group.id]
  key_pair_name      = var.key_pair_name
  hostname           = var.proxy_names[count.index]
  puppet_master      = local.puppet_master
  tags               = local.tags
  network_border_group = var.network_border_group
}
