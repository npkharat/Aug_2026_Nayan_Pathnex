# ============================================================
# AMAZON LINUX 2023 AMI
# ============================================================

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# ============================================================
# BASTION EC2
# ============================================================

resource "aws_instance" "bastion" {

  ami = data.aws_ssm_parameter.amazon_linux_2023.value

  instance_type = var.bastion_instance_type

  subnet_id = aws_subnet.public_1.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "${var.cluster_name}-bastion"
    Role = "bastion"
  }
}