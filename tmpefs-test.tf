# Create EFS
resource "aws_efs_file_system" "efs-app-test" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Move files to Infrequent Access after 30 days
  }

  tags = {
    Name = "efs-app-test-efs"
  }
}

# Create Mount Targets
variable "subnet_ids" {
  default = [
    "subnet-0812b5ad4f0ac874a",
    "subnet-068f84dc34992a380",
    "subnet-0f6c9b2c10459ec4e"
  ]
}

resource "aws_efs_mount_target" "efs-app-test" {
  count             = length(var.subnet_ids) # Create a mount target for each subnet
  file_system_id    = aws_efs_file_system.efs-app-test.id
  subnet_id         = var.subnet_ids[count.index]
  security_groups   = ["sg-0daadd71882e1abf4"]

  depends_on = [aws_efs_file_system.efs-app-test]
}
}