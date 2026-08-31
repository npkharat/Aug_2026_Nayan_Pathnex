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

  user_data = <<-EOF
              #!/bin/bash

              set -e

              # Update system
              dnf update -y

              # Install useful packages
              dnf install -y \
                git \
                curl \
                wget \
                unzip \
                jq \
                tar \
                gzip

              # ------------------------------------------------
              # AWS CLI
              # ------------------------------------------------

              if ! command -v aws &> /dev/null; then

                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
                  -o "/tmp/awscliv2.zip"

                unzip -q /tmp/awscliv2.zip -d /tmp

                /tmp/aws/install

              fi

              # ------------------------------------------------
              # kubectl
              # ------------------------------------------------

              curl -LO "https://dl.k8s.io/release/v1.36.0/bin/linux/amd64/kubectl"

              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

              rm -f kubectl

              # ------------------------------------------------
              # Helm
              # ------------------------------------------------

              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
                | bash

              # ------------------------------------------------
              # Docker
              # ------------------------------------------------

              dnf install -y docker

              systemctl enable docker
              systemctl start docker

              usermod -aG docker ec2-user

              # ------------------------------------------------
              # EKS kubeconfig
              # ------------------------------------------------

              mkdir -p /home/ec2-user/.kube

              chown -R ec2-user:ec2-user /home/ec2-user/.kube

              echo "Bastion setup completed."

              EOF

  tags = {
    Name = "${var.cluster_name}-bastion"
    Role = "bastion"
  }
}