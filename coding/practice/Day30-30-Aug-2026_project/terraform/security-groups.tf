# ============================================================
# BASTION SECURITY GROUP
# ============================================================

resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
}


# SSH FROM MY IP
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id

  description = "SSH access from my IP"

  cidr_ipv4 = var.my_ip

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}


# Bastion outbound
resource "aws_vpc_security_group_egress_rule" "bastion_outbound" {
  security_group_id = aws_security_group.bastion.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}


# ============================================================
# EKS CLUSTER SECURITY GROUP
# ============================================================

resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}


# Bastion -> EKS API
resource "aws_vpc_security_group_ingress_rule" "eks_api_from_bastion" {
  security_group_id = aws_security_group.eks_cluster.id

  description = "Bastion access to EKS API"

  referenced_security_group_id = aws_security_group.bastion.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}


# EKS outbound
resource "aws_vpc_security_group_egress_rule" "eks_cluster_outbound" {
  security_group_id = aws_security_group.eks_cluster.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}


# ============================================================
# EKS NODE SECURITY GROUP
# ============================================================

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}


# Node -> Node
resource "aws_vpc_security_group_ingress_rule" "nodes_from_nodes" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "Worker node communication"

  referenced_security_group_id = aws_security_group.eks_nodes.id

  ip_protocol = "-1"
}


# Cluster -> Node
resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "EKS control plane to worker nodes"

  referenced_security_group_id = aws_security_group.eks_cluster.id

  ip_protocol = "-1"
}


# Node outbound
resource "aws_vpc_security_group_egress_rule" "nodes_outbound" {
  security_group_id = aws_security_group.eks_nodes.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}