main.tf
provider "aws" {
  region = "eu-north-1"
}
 
# ------------------------
# Data source: Default VPC
# ------------------------
data "aws_vpc" "default" {
  default = true
}
 
# ------------------------
# Data source: Subnets in default VPC
# ------------------------
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
 
# ------------------------
# Security Group (for HTTP)
# ------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
# ------------------------
# ECS Cluster
# ------------------------
resource "aws_ecs_cluster" "my_cluster" {
  name = "simple-ecs-cluster"
}
 
# ------------------------
# ECS Task Definition
# ------------------------
resource "aws_ecs_task_definition" "my_task" {
  family                   = "simple-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
 
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
        }
      ]
    }
  ])
}
 
# ------------------------
# ECS Service
# ------------------------
resource "aws_ecs_service" "my_service" {
  name            = "simple-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
 
  network_configuration {
    subnets          = data.aws_subnets.default_vpc_subnets.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}
