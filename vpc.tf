resource "aws_vpc" "ccp_course_practice_vpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "ccp-course-practice-vpc"
  }
}

# Fetch available AZs in the region
data "aws_availability_zones" "available" {}

# Create a subnet for each AZ (assuming a maximum of 6 AZs for simplicity here)
resource "aws_subnet" "ccp_course_practice_subnets" {
  count                   = 6
  cidr_block              = "172.31.${count.index * 16}.0/20"
  vpc_id                  = aws_vpc.ccp_course_practice_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ccp-course-practice-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "ccp_course_practice_igw" {
  vpc_id = aws_vpc.ccp_course_practice_vpc.id
}

resource "aws_route" "ccp_course_practice_route" {
  route_table_id         = aws_vpc.ccp_course_practice_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ccp_course_practice_igw.id
}
