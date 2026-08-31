# ============================================================
# EKS CLUSTER IAM ROLE
# ============================================================

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-cluster-role"
  }
}


# ============================================================
# EKS CLUSTER IAM POLICY
# ============================================================

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# ============================================================
# EKS CLUSTER
# ============================================================

resource "aws_eks_cluster" "main" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster.arn

  # ==========================================================
  # KUBERNETES VERSION
  # ==========================================================

  version = var.kubernetes_version


  # ==========================================================
  # STANDARD SUPPORT
  # ==========================================================

  upgrade_policy {
    support_type = "STANDARD"
  }


  # ==========================================================
  # EKS AUTHENTICATION
  # ==========================================================

  access_config {
    authentication_mode = "API"
  }


  # ==========================================================
  # VPC CONFIGURATION
  # ==========================================================

  vpc_config {

    # EKS control plane is associated with private subnets
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]


    # EKS cluster security group
    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]


    # Private API access
    endpoint_private_access = true


    # Public API access
    endpoint_public_access = true
  }


  # ==========================================================
  # DEPENDENCIES
  # ==========================================================

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]


  # ==========================================================
  # TAGS
  # ==========================================================

  tags = {
    Name = var.cluster_name
  }
}


# ============================================================
# EKS WORKER NODE IAM ROLE
# ============================================================

resource "aws_iam_role" "eks_nodes" {

  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-node-role"
  }
}


# ============================================================
# EKS WORKER NODE POLICY
# ============================================================

resource "aws_iam_role_policy_attachment" "worker_node_policy" {

  role = aws_iam_role.eks_nodes.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# ============================================================
# VPC CNI POLICY
# ============================================================

resource "aws_iam_role_policy_attachment" "cni_policy" {

  role = aws_iam_role.eks_nodes.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# ============================================================
# ECR PULL POLICY
# ============================================================

resource "aws_iam_role_policy_attachment" "ecr_policy" {

  role = aws_iam_role.eks_nodes.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# ============================================================
# EKS MANAGED SPOT NODE GROUP
# ============================================================

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${var.cluster_name}-spot-nodes"

  node_role_arn = aws_iam_role.eks_nodes.arn


  # ==========================================================
  # PRIVATE SUBNETS
  # ==========================================================

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]


  # ==========================================================
  # SPOT INSTANCE TYPES
  # ==========================================================

  # Multiple instance types give EKS more Spot capacity
  # options.

  instance_types = var.worker_instance_types


  # ==========================================================
  # SPOT CAPACITY
  # ==========================================================

  capacity_type = "SPOT"


  # ==========================================================
  # NODE SCALING
  # ==========================================================

  scaling_config {

    desired_size = var.desired_nodes

    min_size = var.min_nodes

    max_size = var.max_nodes
  }


  # ==========================================================
  # NODE UPDATE CONFIGURATION
  # ==========================================================

  update_config {

    max_unavailable = 1
  }


  # ==========================================================
  # DEPENDENCIES
  # ==========================================================

  depends_on = [

    aws_iam_role_policy_attachment.worker_node_policy,

    aws_iam_role_policy_attachment.cni_policy,

    aws_iam_role_policy_attachment.ecr_policy
  ]


  # ==========================================================
  # TAGS
  # ==========================================================

  tags = {

    Name = "${var.cluster_name}-spot-worker"

    Environment = "learning"

    NodeType = "spot"
  }
}