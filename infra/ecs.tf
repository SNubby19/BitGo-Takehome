resource "aws_ecs_cluster" "main" {
  name = "scalable-web-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "scalable-web-task"
  network_mode             = "bridge" 
  requires_compatibilities = ["EC2"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB RAM
  
  container_definitions = jsonencode([
    {
      name      = "web-app"
      image     = "ghcr.io/therealdwright/scalable-web-service:v1"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 0 # hostPort 0 allows dynamic port mapping on the EC2 instance!
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "scalable-web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2 # Keeps 2 copies running to survive an instance loss
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "web-app"
    container_port   = 8080
  }
}
