# ===========================
# CONFIGURACIÓN DE AWS ECR
# ===========================

resource "aws_ecr_repository" "deepseek_repo" {
  name = "deepseek-repo"
}

resource "aws_ecr_repository" "fargate_repo" {
  name = "fargate-repo"
}

# ===========================
# CONSTRUCCIÓN Y PUSH DE IMÁGENES A ECR
# ===========================

resource "null_resource" "build_and_push_deepseek" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.deepseek_repo.repository_url}
      docker build -t deepseek-image .
      docker tag deepseek-image ${aws_ecr_repository.deepseek_repo.repository_url}:latest
      docker push ${aws_ecr_repository.deepseek_repo.repository_url}:latest
    EOT
  }
}


# ===========================
# RED Y SUBNETS
# ===========================

resource "aws_vpc" "deepseek_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.deepseek_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

# ===========================
# APPLICATION LOAD BALANCER (ALB)
# ===========================

resource "aws_alb" "deepseek_alb" {
  name               = "deepseek-alb"
  internal          = false
  load_balancer_type = "application"
  security_groups    = [] # Agregar grupos de seguridad
  subnets           = [aws_subnet.public_subnet.id]
}

# ===========================
# CLÚSTER ECS
# ===========================

resource "aws_ecs_cluster" "deepseek_cluster" {
  name = "deepseek-cluster"
}

# ===========================
# CONFIGURACIÓN DE EC2 PARA ECS (OPCIONAL)
# ===========================

resource "aws_launch_template" "deepseek_lt" {
  name_prefix   = "deepseek-ec2-"
  image_id      = "ami-0abcdef1234567890" # Reemplaza con la AMI correcta
  instance_type = "g4dn.xlarge"

  user_data = base64encode(file("install.sh"))
}

# ===========================
# DEFINICIÓN DE TAREAS ECS
# ===========================

resource "aws_ecs_task_definition" "deepseek_task" {
  family                   = "deepseek-task"
  requires_compatibilities = ["EC2", "FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "deepseek-container",
      "image": "${aws_ecr_repository.deepseek_repo.repository_url}:latest",
      "cpu": 512,
      "memory": 1024,
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION
}

# ===========================
# SERVICIO ECS (FARGATE)
# ===========================

resource "aws_ecs_service" "deepseek_service" {
  name            = "deepseek-service"
  cluster         = aws_ecs_cluster.deepseek_cluster.id
  task_definition = aws_ecs_task_definition.deepseek_task.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    assign_public_ip = true
  }
}
