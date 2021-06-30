#--conection to host remotly and runnung some script  
#-- provisioner is not recomended
  # connection {
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = "${file(var.private-key)}"
  # }

#--remotly execute command in instance
  
  # provisioner "remote-exec" {
  #   inline = [
  #     "export ENV=dev",
  #     "mkdir new-folder"
  #   ]
  # }
#-- copy file from local to remote instance
  # provisioner "file" {
  #   source = "entry-script.sh"
  #   destination = "/home/ec2-user/entry-script-on-ec2.sh"
  # }

#-ecxecute commands on local machine
  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} > pub-ip.txt"
  # }

