# This file contains the configuration for our the key (main) resources to be provisioned.
# This comprises the terraform configurations for a new IAM role for EKS, the EKS policy for the IAM role,
# and the EKS cluster itself, including the worker nodes.


resource "aws_iam_role" "eks-iam-role" {
 name = "plotly-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
}


resource "aws_eks_cluster" "plotly-eks-cluster" {
 name = "plotly-eks-cluster"
 role_arn = aws_iam_role.eks-iam-role.arn

 vpc_config {
  subnet_ids = [var.subnet_id_1, var.subnet_id_2]   # cluster subnet IDs are specified in the variables file
 }

 depends_on = [                                     # this depends_on meta argument tells terraform to first create
  aws_iam_role.eks-iam-role,                        # the iam role before creating the cluster
 ]
}


resource "aws_iam_role" "workernodes" {             # This IAM role is for the worker node (not for the cluster) 
  name = "plotly-eks-node-group"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }


resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.plotly-eks-cluster.name
  node_group_name = "plotly-workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids   = [var.subnet_id_1, var.subnet_id_2]                          # Subnets would be specified in variables.tf file
  instance_types = ["t3.xlarge"]              
 
  scaling_config {                                                           # We set capacity to 1 for demo purpose only
   desired_size = 1                                                          # In a real life production use case, we should have more
   max_size   = 1
   min_size   = 1
  }
 
  depends_on = [                                                             # This block ensures that the worker node policies are first               
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,                 # attached to the worker node IAM role before the node group 
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,                      # is created
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
