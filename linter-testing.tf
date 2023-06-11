resource "aws_instance" "proxy" {
  # tflint-ignore: all
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/files/init-puppet.tmpl", {
    hostname      = var.hostname
    puppet_master = var.puppet_master
  })

  # We fetch the AMI ID dynamically, this means updates to the AMI will recreate the proxies which isn't what we want.
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    for tag in concat([
      {
        name : "Name",
        value : var.hostname,
      },
    ], var.tags) :
    tag.name => tag.value
  }
}

resource "aws_eip" "proxy_ip" {
  count = var.use_elastic_ip ? 1 : 0

  vpc      = true
  instance = aws_instance.proxy.id

  network_border_group = var.network_border_group != "" ? var.network_border_group : null

  tags = {
    for tag in concat([
      {
        name : "Name",
        value : var.hostname,
      },
    ], var.tags) :
    tag.name => tag.value
  }
}
