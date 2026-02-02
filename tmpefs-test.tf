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
resource "aws_efs_mount_target" "efs-app-test" {
  file_system_id    = aws_efs_file_system.efs-app-test.id
  subnet_id         = [subnet-0812b5ad4f0ac874a, subnet-068f84dc34992a380, subnet-0f6c9b2c10459ec4e]
  security_groups   = [sg-0daadd71882e1abf4]

  depends_on = [aws_efs_file_system.efs-app-test]
}

output "efs_id" {
  value = aws_efs_file_system.efs-app-test.id
}