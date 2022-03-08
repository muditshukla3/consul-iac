# Security Group for SSH Connection
resource "aws_security_group" "ssh-sg" {

    vpc_id = aws_vpc.consul-vpc.id
    name = "${var.main_project_tag}-ssh-sg"
    description = "Security group to allow SSH connection"

    tags = merge(
    { "Name" = "${var.main_project_tag}-ssh-sg" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_security_group_rule" "allow-ssh-sg-rule" {
   security_group_id = aws_security_group.ssh-sg.id
   type = "ingress"
   protocol = "tcp"
   from_port = 22
   to_port = 22
   cidr_blocks = var.allowed_cidr_blocks
   description = "Allow SSH Traffic"
}

## Load Balancer SG
resource "aws_security_group" "load_balancer" {
  name_prefix = "${var.main_project_tag}-alb-sg"
  description = "Firewall for the application load balancer fronting the consul server."
  vpc_id      = aws_vpc.consul-vpc.id
  
  tags = merge(
    { "Name" = "${var.main_project_tag}-alb-sg" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_security_group_rule" "load_balancer_allow_80" {
  security_group_id = aws_security_group.load_balancer.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = var.allowed_cidr_blocks
  description       = "Allow HTTP traffic."
}

resource "aws_security_group_rule" "load_balancer_allow_outbound" {
  security_group_id = aws_security_group.load_balancer.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow any outbound traffic."
}

# Security Group for Consul Server
resource "aws_security_group" "consul-server-sg" {

    vpc_id = aws_vpc.consul-vpc.id
    name = "${var.main_project_tag}-consul-sg"
    description = "Security group for consul ports"
}

resource "aws_security_group_rule" "allow-load-balancer-http-8500" {
   security_group_id = aws_security_group.consul-server-sg.id
   type = "ingress"
   protocol = "tcp"
   from_port = 8500
   to_port = 8500
   source_security_group_id = aws_security_group.load_balancer.id
   description = "Allow HTTP API Traffic form load balancer to consul"
}

resource "aws_security_group_rule" "consul_server_allow_client_8500" {
  security_group_id        = aws_security_group.consul-server-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8500
  to_port                  = 8500
  source_security_group_id = aws_security_group.consul-client-sg.id
  description              = "Allow HTTP traffic from Consul Client."
}

resource "aws_security_group_rule" "consul_server_allow_client_8301" {
  security_group_id        = aws_security_group.consul-server-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = aws_security_group.consul-client-sg.id
  description              = "Allow LAN gossip traffic from Consul Client to Server.  For managing cluster membership for distributed health check of the agents."
}

resource "aws_security_group_rule" "consul_server_allow_client_8300" {
  security_group_id        = aws_security_group.consul-server-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8300
  to_port                  = 8300
  source_security_group_id = aws_security_group.consul-client-sg.id
  description              = "Allow RPC traffic from Consul Client to Server.  For client and server agents to send and receive data stored in Consul."
}

resource "aws_security_group_rule" "consul_server_allow_server_8301" {
  security_group_id        = aws_security_group.consul-server-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = aws_security_group.consul-server-sg.id
  description              = "Allow LAN gossip traffic from Consul Server to Server.  For managing cluster membership for distributed health check of the agents."
}

resource "aws_security_group_rule" "consul_server_allow_server_8300" {
  security_group_id        = aws_security_group.consul-server-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8300
  to_port                  = 8300
  source_security_group_id = aws_security_group.consul-server-sg.id
  description              = "Allow RPC traffic from Consul Server to Server.  For client and server agents to send and receive data stored in Consul."
}

resource "aws_security_group_rule" "consul_server_allow_outbound" {
  security_group_id = aws_security_group.consul-server-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow any outbound traffic."
}

# Consul Client Instance SG

resource "aws_security_group" "consul-client-sg" {
  name_prefix = "${var.main_project_tag}-consul-client-sg"
  description = "Firewall for the consul client."
  vpc_id      = aws_vpc.consul-vpc.id
  tags = merge(
    { "Name" = "${var.main_project_tag}-consul-client-sg" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_security_group_rule" "consul_client_allow_8500" {
  security_group_id        = aws_security_group.consul-client-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8500
  to_port                  = 8500
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Allow HTTP traffic from Load Balancer."
}

resource "aws_security_group_rule" "consul_client_allow_outbound" {
  security_group_id = aws_security_group.consul-client-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow any outbound traffic."
}