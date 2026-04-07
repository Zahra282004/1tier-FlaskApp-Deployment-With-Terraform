provider "aws"{
    region= "us-east-1"
}
variable "cidr_block"{
    default ="10.0.0.0/16"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
}


resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone= "us-east-1a"
  map_public_ip_on_launch = true #whatever instance craeted inside this subnet must be given a public ip on launch
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id


  route {
    cidr_block = "0.0.0.0/0"  #pass traffic from otside vpc through igw
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.rt.id
}


resource "aws_security_group" "my_sg" {
  name = "my_sg"
  vpc_id      = aws_vpc.my_vpc.id
}


resource "aws_security_group_rule" "inbound" {
  type              = "ingress"
  description       = "http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_sg.id
}


resource "aws_security_group_rule" "inbound-2" {
  type              = "ingress"
  description       = "ssh"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_sg.id
}


resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  description = "from ec2 to access the internet"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_sg.id
}


resource "aws_instance" "ec2" {
  ami = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  subnet_id= aws_subnet.my_subnet.id
  key_name="key_zahra"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
  Name = "Zahra-Web-Server"
}


# for file sending or remote_exec hume ek gateway ki zaroorat hoti so that our local server can connect ec2,theredore we use connection block
connection {
    type        = "ssh"
    user        = "ubuntu"  
    private_key = file("~/Downloads/key_zahra.pem")  
    host        = self.public_ip
  }


  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "~/app.py" # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo apt install python3-flask",
      "nohup sudo python3 app.py &",
      "sleep 2" 
    ]
  }
}


