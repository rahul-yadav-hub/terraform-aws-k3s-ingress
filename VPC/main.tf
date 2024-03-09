
// Define VPC resources
resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr_block_vpc         #"10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name  

    tags = {
        Name = "${var.tag_name}-${var.vpc_name}" # Tag all resource with specific name.......String Interpolation
        "kubernetes.io/cluster/mycluster" = "owned"
    }
}
// Fetch AZs
data "aws_availability_zones" "available" {
  state = "available"
}


// Define subnet resources
// It will first create all Public subnet then private
resource "aws_subnet" "subnet" {
  count                   = sum([var.public_subnet_count, var.private_subnet_count]) #Total Subnet
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, count.index) #"10.0.0.0/24" 
  map_public_ip_on_launch = count.index + 1 > var.public_subnet_count ? false : true  # Decide whether Public or Private
  availability_zone       = count.index + 1 > var.public_subnet_count ? data.aws_availability_zones.available.names[count.index - var.public_subnet_count] : data.aws_availability_zones.available.names[count.index] #select 1st available AZ
  tags = {
    Name = count.index + 1 > var.public_subnet_count ? "${var.tag_name}-private-${count.index - var.public_subnet_count + 1}" : "${var.tag_name}-public-${count.index + 1}" # Tag all resource with specific name
    "kubernetes.io/cluster/mycluster" = "owned"
  }
}


// Define IGW resource
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.tag_name}-IGW"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define EIP resource
resource "aws_eip" "nat_eip" {
  count = var.private_subnet_count > 0 ? 1 : 0
  vpc        = true
  depends_on = [aws_internet_gateway.my-igw]
}

// Define NAT Gateway resource
resource "aws_nat_gateway" "my-nat" {
  count = var.private_subnet_count > 0 ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.subnet[0].id
  tags = {
    Name = "${var.tag_name}-NAT-gateway"
  }
  depends_on = [aws_eip.nat_eip]
}

// Define Public RT resource
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name   = "${var.tag_name}-public-RT"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define Private RT resource
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "${var.tag_name}-private-RT"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define Public RT Route resource
resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.publicRT.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.my-igw.id}"
  depends_on = [aws_route_table.publicRT]
}

// Define Private RT Route resource
resource "aws_route" "private_nat_gateway" {
  count                  = var.private_subnet_count > 0 ? 1 : 0                           # not creating 
  route_table_id         = "${aws_route_table.privateRT.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.my-nat[0].id}"
  depends_on = [aws_route_table.privateRT]
}

// RT Association resource
resource "aws_route_table_association" "association" {
  count                   = sum([var.public_subnet_count, var.private_subnet_count])
  subnet_id               = aws_subnet.subnet[count.index].id
  route_table_id          = count.index + 1 > var.public_subnet_count ? aws_route_table.privateRT.id : aws_route_table.publicRT.id
}

