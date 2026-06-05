resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "myvpc"
    }
}

resource "aws_subnet" "pub_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.public_subnet_zone
    tags = {
        Name = "pub-subnet"
    }
    map_public_ip_on_launch = true   # Every instance launched on this subnet will have a public ip
}

resource "aws_subnet" "pvt_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = var.private_subnet_zone
    cidr_block = var.private_subnet_cidr
    tags = {
        Name = "pvt-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "pub-rt"
    }
}

resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "pvt-rt"
    }
}

resource "aws_route_table_association" "pub_sb_rt" {
    route_table_id = aws_route_table.pub_rt.id
    subnet_id = aws_subnet.pub_subnet.id
}

resource "aws_route_table_association" "pvt_sb_rt" {
    route_table_id = aws_route_table.pvt_rt.id
    subnet_id = aws_subnet.pvt_subnet.id
}

resource "aws_security_group" "allow_tls_from_anywhere" {
    name        = "allow_tls_from_anywhere"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = aws_vpc.my_vpc.id
    tags = {
        Name = "allow_tls_from_anywhere"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = aws_security_group.allow_tls_from_anywhere.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
  security_group_id = aws_security_group.allow_tls_from_anywhere.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "pub_all_out" {
  security_group_id = aws_security_group.allow_tls_from_anywhere.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "allow_tls_from_my_vpc" {
    name        = "allow_tls_from_my_vpc"
    description = "Allow TLS inbound traffic and all outbound traffic from my_vpc"
    vpc_id      = aws_vpc.my_vpc.id
    tags = {
        Name = "allow_tls_from_my_vpc"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_pvt_inst" {
    security_group_id = aws_security_group.allow_tls_from_my_vpc.id
    cidr_ipv4         = aws_vpc.my_vpc.cidr_block
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_to_pvt_inst" {
  security_group_id = aws_security_group.allow_tls_from_my_vpc.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "pvt_all_out" {
  security_group_id = aws_security_group.allow_tls_from_my_vpc.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_key_pair" "key_to_ssh" {
    key_name = "key_to_ssh"
    public_key = file(var.public_key_path)
}

resource "aws_instance" "pvt_inst" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.pvt_subnet.id
    vpc_security_group_ids = [ 
        aws_security_group.allow_tls_from_my_vpc.id
    ]
    key_name = aws_key_pair.key_to_ssh.key_name
    tags = {
        Name = "pvt-inst"
    }
}

resource "aws_instance" "pub_inst" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.pub_subnet.id
    vpc_security_group_ids = [ 
        aws_security_group.allow_tls_from_anywhere.id 
    ]
    key_name = aws_key_pair.key_to_ssh.key_name
    tags = {
        Name = "pub-inst"
    }
}

output "public_inst_pub_ip" {
    description = "Public Instance's Public IP"
    value = aws_instance.pub_inst.public_ip
}

output "private_inst_pvt_ip" {
    description = "Private Instance's Private IP"
    value = aws_instance.pvt_inst.private_ip
}
