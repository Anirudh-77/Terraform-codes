#--Output instance id

# output "test-instance" {
#   value = data.aws_ami.latest-linux-ami.id
# }


output "public-ip" {
  value = module.myapp-server.instance.public_ip
}