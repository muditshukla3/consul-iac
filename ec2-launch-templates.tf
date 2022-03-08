resource "random_id" "gossip_key" {
  byte_length = 32
}

resource "aws_launch_template" "server-launch-template" {
  name_prefix            = "${var.main_project_tag}-server-lt-"
  image_id               = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = [aws_security_group.ssh-sg.id,aws_security_group.load_balancer.id
                            ,aws_security_group.consul-server-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.consul_instance_profile.name
  }
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.main_project_tag}-server" },
      { "Project" = var.main_project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${var.main_project_tag}-server-volume" },
      { "Project" = var.main_project_tag }
    )
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-server-lt" },
    { "Project" = var.main_project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh",{
    PROJECT_TAG   = "Project"
    PROJECT_VALUE = var.main_project_tag
    BOOTSTRAP_NUMBER = var.server_min_count
    GOSSIP_KEY = random_id.gossip_key.b64_std
  }))
}

resource "aws_launch_template" "client-launch-template" {
  name_prefix            = "${var.main_project_tag}-client-lt-"
  image_id               = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = [aws_security_group.ssh-sg.id,aws_security_group.load_balancer.id
                            ,aws_security_group.consul-client-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.consul_instance_profile.name
  }
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.main_project_tag}-client" },
      { "Project" = var.main_project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${var.main_project_tag}-client-volume" },
      { "Project" = var.main_project_tag }
    )
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-client-lt" },
    { "Project" = var.main_project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/scripts/client.sh",{
    PROJECT_TAG   = "Project"
    PROJECT_VALUE = var.main_project_tag
    GOSSIP_KEY = random_id.gossip_key.b64_std
  }))
}