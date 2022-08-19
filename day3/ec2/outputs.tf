output "example_instance_id" {
  description = "Output example instance ID"
  value = aws_instance.example.id
}

output "example_instance_public_ip" {
  description = "Output example instance public IP"
  value = aws_instance.example.public_ip
}

output "example_instance_private_ip" {
  description = "Output example instance private IP"
  value = aws_instance.example.private_ip
}