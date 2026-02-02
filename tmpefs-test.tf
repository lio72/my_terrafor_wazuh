# # Create EFS
# resource "aws_efs_file_system" "efs-app-test" {
#   lifecycle_policy {
#     transition_to_ia = "AFTER_30_DAYS" # Move files to Infrequent Access after 30 days
#   }

#   tags = {
#     Name = "efs-app-test-efs"
#   }
# }

# # Create Mount Targets
# resource "aws_efs_mount_target" "efs-app-test" {
#   count             = length(var.subnet_ids)
#   file_system_id    = aws_efs_file_system.efs-app-test.id
#   subnet_id         = var.subnet_ids[count.index]
#   security_groups   = [var.security_group_id]

#   depends_on = [aws_efs_file_system.efs-app-test]
# }

# output "efs_id" {
#   value = aws_efs_file_system.efs-app-test.id
# }