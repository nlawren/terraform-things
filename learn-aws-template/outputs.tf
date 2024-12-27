output "node_ip" {
  value = aws_instance.dev_node.public_ip
}

output "node_name" {
  value = aws_instance.dev_node.public_dns
}

output "node_ami" {
  value = aws_instance.dev_node.ami
}