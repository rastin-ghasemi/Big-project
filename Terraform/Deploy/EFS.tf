##########################
# EFS for  media Storage #
##########################

resource "aws_efs_file_system" "media" {
  encrypted = true
  tags = {
    Name = "${local.Prefix}-media"
  }

}

resource "aws_security_group" "efs" {
    name= "${local.Prefix}-efs"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        security_groups = [
            aws_security_group.ecs_service.id
        ]
    }
  
}

#################################
# Mount target For Both Subnets #
#################################
resource "aws_efs_mount_target" "media-a" {
    file_system_id = aws_efs_file_system.media.id
    subnet_id = aws_subnet.Private-a.id
    security_groups = [aws_security_group.efs.id]
  
}
resource "aws_efs_mount_target" "media-b" {
    file_system_id = aws_efs_file_system.media.id
    subnet_id = aws_subnet.Private-b.id
    security_groups = [aws_security_group.efs.id]
  
}

################################
# EFS Access Point For Our ECS #
################################

resource "aws_efs_access_point" "media" {
    file_system_id = aws_efs_file_system.media.id
    root_directory {
      path = "/api/media"
      creation_info {
        owner_gid = 101
        owner_uid = 101
        permissions = "755"
      }
    }
  
}