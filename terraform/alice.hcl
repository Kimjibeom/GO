provider "aws" {
  region = "us-east-1"  # 기본 리전 설정
}

# US East 1 리전 VPC
module "vpc_us_east_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "eks-vpc-east-1"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# US West 2 리전 VPC
module "vpc_us_west_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "eks-vpc-west-2"
  cidr = "10.1.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# 인터넷 게이트웨이 설정
resource "aws_internet_gateway" "gw_us_east_1" {
  vpc_id = module.vpc_us_east_1.vpc_id
}

resource "aws_internet_gateway" "gw_us_west_2" {
  vpc_id = module.vpc_us_west_2.vpc_id
}

# 라우팅 테이블 구성
resource "aws_route_table" "rt_us_east_1" {
  vpc_id = module.vpc_us_east_1.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_us_east_1.id
  }
}

resource "aws_route_table" "rt_us_west_2" {
  vpc_id = module.vpc_us_west_2.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_us_west_2.id
  }
}

# 보안 그룹 설정
resource "aws_security_group" "secure_web_traffic_east" {
  name        = "secure-web-traffic-east"
  description = "Allow only HTTP traffic"
  vpc_id      = module.vpc_us_east_1.vpc_id

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

resource "aws_security_group" "secure_web_traffic_west" {
  name        = "secure-web-traffic-west"
  description = "Allow only HTTP traffic"
  vpc_id      = module.vpc_us_west_2.vpc_id

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

# DNS 설정 (Route 53)
resource "aws_route53_zone" "primary" {
  name = "example.com"
}

resource "aws_route53_health_check" "health_check" {
  fqdn              = aws_lb.global_lb.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.id
  name    = "www.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_lb.global_lb.dns_name]

  health_check_id = aws_route53_health_check.health_check.id
}

# S3 버킷 설정
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# 모니터링 및 로깅 설정 (CloudWatch 로그 그룹)
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/eks/my-cluster/logs"
  retention_in_days = 14
}

# 첫 번째 리전의 EKS 클러스터
module "eks_us_east_1" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster-active-1"
  cluster_version = "1.17"
  region          = "us-east-1"
  subnets         = module.vpc_us_east_1.private_subnets

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "m5.large"
    }
  }
}

# Amazon RDS 데이터베이스 인스턴스 (주 클러스터)
resource "aws_db_instance" "primary_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.medium"
  name                 = "primarydb"
  username             = "dbadmin"
  password             = "dbpassword"
  parameter_group_name = "default.mysql5.7"
  multi_az             = true
  availability_zone    = "us-east-1a"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}

# 두 번째 리전의 EKS 클러스터
module "eks_us_west_2" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster-active-2"
  cluster_version = "1.17"
  region          = "us-west-2"
  subnets         = module.vpc_us_west_2.private_subnets

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "m5.large"
    }
  }
}

# Cross-Region Read Replica (보조 클러스터)
resource "aws_db_instance" "replica_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.medium"
  replicate_source_db  = aws_db_instance.primary_db.id
  name                 = "replicadb"
  username             = "dbadmin"
  password             = "dbpassword"
  parameter_group_name = "default.mysql5.7"
  availability_zone    = "us-west-2a"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}

# DB 서브넷 그룹 정의
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-dbsubnet-group"
  subnet_ids = concat(module.vpc_us_east_1.private_subnets, module.vpc_us_west_2.private_subnets)

  tags = {
    Name = "My DB Subnet Group"
  }
}

# 오토 스케일링 설정
resource "aws_autoscaling_policy" "example" {
  name                   = "cpu-utilization"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example.name

  policy_type = "SimpleScaling"

  alarm {
    alarm_name          = "high-cpu-usage"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 75
    actions_enabled     = true
    alarm_description   = "This alarm monitors EC2 CPU usage"
    alarm_actions       = [aws_sns_topic.example.arn]
  }
}

# Global Load Balancer를 위한 설정
resource "aws_route53_record" "global_lb" {
  zone_id = aws_route53_zone.primary.id
  name    = "api.global.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.global_lb.dns_name
    zone_id                = aws_lb.global_lb.zone_id
    evaluate_target_health = true
  }
}

# Global Load Balancer
resource "aws_lb" "global_lb" {
  name               = "global-lb"
  load_balancer_type = "application"
  subnets            = concat(module.vpc_us_east_1.public_subnets, module.vpc_us_west_2.public_subnets)

  enable_deletion_protection = true
}

# Target Group for us-east-1
resource "aws_lb_target_group" "tg_us_east_1" {
  name     = "tg-us-east-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_us_east_1.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }
}

# Target Group for us-west-2
resource "aws_lb_target_group" "tg_us_west_2" {
  name     = "tg-us-west-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_us_west_2.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }
}

# Listener for HTTP Traffic in us-east-1
resource "aws_lb_listener" "front_end_east" {
  load_balancer_arn = aws_lb.global_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_us_east_1.arn
  }
}

# Listener for HTTP Traffic in us-west-2
resource "aws_lb_listener" "front_end_west" {
  load_balancer_arn = aws_lb.global_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_us_west_2.arn
  }
}


# 두 클러스터 간 트래픽을 균등하게 분배하기 위한 설정
resource "aws_lb_target_group_attachment" "east" {
  target_group_arn = aws_lb_target_group.global_tg.arn
  target_id        = module.eks_us_east_1.cluster_endpoint
  port             = 80
}

resource "aws_lb_target_group_attachment" "west" {
  target_group_arn = aws_lb_target_group.global_tg.arn
  target_id        = module.eks_us_west_2.cluster_endpoint
  port             = 80
}