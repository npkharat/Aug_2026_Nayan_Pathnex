aws_region         = "ap-south-1"
cluster_name       = "devops-learning-eks"
kubernetes_version = "1.36"

vpc_cidr = "10.0.0.0/16"

worker_instance_types = [
  "t3.medium",
  "t3a.medium",
  "m5.large",
  "m5a.large"
]

desired_nodes = 2
min_nodes     = 2
max_nodes     = 2

bastion_instance_type = "t3.micro"

key_name = "bastion_ed25519"

my_ip = "0.0.0.0/0"