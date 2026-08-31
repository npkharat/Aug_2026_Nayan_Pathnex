#!/bin/bash

set -e

# Update system
dnf update -y

# Install basic packages
dnf install -y git wget curl unzip java-17-amazon-corretto

# ==========================================
# Install Docker
# ==========================================

dnf install -y docker

systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker without sudo
usermod -aG docker ec2-user

# ==========================================
# Install Jenkins
# ==========================================

curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key \
  -o /etc/pki/rpm-gpg/jenkins.io-2026.key

rpm --import /etc/pki/rpm-gpg/jenkins.io-2026.key

cat > /etc/yum.repos.d/jenkins.repo <<EOF
[jenkins]
name=Jenkins
baseurl=https://pkg.jenkins.io/redhat-stable/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/jenkins.io-2026.key
enabled=1
EOF

dnf install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# ==========================================
# Install AWS CLI
# ==========================================

dnf install -y awscli

# ==========================================
# Install Helm
# ==========================================

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  | bash

# ==========================================
# Install kubectl
# ==========================================

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

# ==========================================
# Display versions in log
# ==========================================

docker --version
java -version
jenkins --version
aws --version
helm version
kubectl version --client

echo "========================================="
echo "Bastion setup completed successfully!"
echo "========================================="