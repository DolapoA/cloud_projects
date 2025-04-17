############################################
# Enforce access to VPC via VPN exlusively #
############################################

# Create a vpn gateway
resource "aws_vpn_gateway" "cg_vpn" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "cg-vpn-gateway"
  }
}

# Create a clincial genomics VPN connection
resource "aws_vpn_connection" "cg_vpn" { 
  customer_gateway_id = aws_customer_gateway.cg_vpn.id
  # Once connected it encrypts data between the user and the VPN gateway
  # This way activity is kept confidential
  type                = "ipsec.1"
  vpn_gateway_id      = aws_vpn_gateway.cg_vpn.id
  
  # Only allow routes to the VPC that admin is aware of
  # providing tighter control
  static_routes_only = true

  tags = {
    Name = "cg-vpn-connection"
  }
}

# The route table (router) directs traffic through the VPN gateway
resource "aws_route" "vpn_route" {
  # Declare the route table to be used  
  route_table_id         = module.vpc.private_route_table_ids[0]
  # Traffic from the internet...
  destination_cidr_block = "0.0.0.0/0"
  # ...Is directed through the VPN gateway
  gateway_id             = aws_vpn_gateway.cg_vpn.id
}

# Configure security groups to allow traffic only from the VPN connection
resource "aws_security_group" "vpn_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    # The rule refers to all ports
    from_port   = 0
    to_port     = 0
    # The rule relates to all protocols (TCP, UDP & ICMP)
    protocol    = "-1"
    # The rule allows traffic from the VPN connection
    cidr_blocks = ["192.168.100.0/24"]
  }

  egress {
    # This enables users to access the internet as usual
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg"
  }
}

# Define the network ACL
resource "aws_network_acl" "cg" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "cg-network-acl"
  }
}

# Configure network ACLs to allow traffic only from the VPN connection
resource "aws_network_acl_rule" "vpn_acl_rule_inbound" {
  network_acl_id = aws_network_acl.cg.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  cidr_block     = ["192.168.100.0/24"]
  rule_action    = "allow"
}

# Configure network ACLs to allow traffic only from the VPN connection
resource "aws_network_acl_rule" "vpn_acl_rule_outbound" {
    network_acl_id = aws_network_acl.cg.id
    # Assigns a unique number to the rule, among several rules
    # the rules with lower numbers are followed first
    rule_number    = 100
    egress         = true
    protocol       = "-1"
    cidr_block     = "0.0.0.0/0"
    rule_action         = "allow"
}
############################################
# | | | | | | | | | | | | | | | | | | | |  #
############################################