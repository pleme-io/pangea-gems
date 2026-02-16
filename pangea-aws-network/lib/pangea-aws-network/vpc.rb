# frozen_string_literal: true

module PangeaAwsNetwork
  module Vpc
    def self.create_vpc(context, product, cidr_block, enable_dns_support = true, enable_dns_hostnames = true, tags = {})
      context.resource :aws_vpc, product do
        cidr_block cidr_block
        enable_dns_support enable_dns_support
        enable_dns_hostnames enable_dns_hostnames
        tags tags
      end
    end

    def self.create_internet_gateway(context, product, vpc_id, tags = {})
      context.resource :aws_internet_gateway, :"#{product}_igw" do
        vpc_id vpc_id
        tags tags
      end
    end

    def self.create_subnet(context, name, vpc_id, cidr_block, availability_zone, map_public_ip_on_launch = false,
                           tags = {})
      context.resource :aws_subnet, name do
        vpc_id vpc_id
        cidr_block cidr_block
        map_public_ip_on_launch map_public_ip_on_launch
        availability_zone availability_zone
        tags tags
      end
    end
  end
end
