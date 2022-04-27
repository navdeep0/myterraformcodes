provider "aws" {
    region = "us-east-1"
    access_key = "dd"
    secret_key =  "dd"
} 

resource "aws_instance" "web-ec2" {    # create instance which i want to make in public subnet
  ami           = var.image   #calling the image variable for ami id from variable file
  instance_type = var.instancetype  # calling the variable instance type
  

  tags = {
    Name = "cloud-ec2"
  }
}

# if we want to change the value of variables we can change the resources will be automatically pick up
# the values of variablee in resources