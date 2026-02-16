require "spec_helper"
require_relative "../../lib/pangea-aws-network/vpc"
require 'ostruct'

RSpec.describe PangeaAwsNetwork::Vpc do
  let(:mock_context) { double("context") }

  describe ".create_vpc" do
    it "calls resource with correct parameters" do
      expect(mock_context).to receive(:resource).with(:aws_vpc, :my_vpc) do |name, &block|
        resource_config = OpenStruct.new
        def resource_config.cidr_block(block); @cidr_block = block; end
        def resource_config.enable_dns_support(enable); @enable_dns_support = enable; end
        def resource_config.enable_dns_hostnames(enable); @enable_dns_hostnames = enable; end
        def resource_config.tags(tags); @tags = tags; end
        resource_config.instance_exec(&block)
        expect(resource_config.instance_variable_get(:@cidr_block)).to eq("10.0.0.0/16")
        expect(resource_config.instance_variable_get(:@enable_dns_support)).to be(true)
        expect(resource_config.instance_variable_get(:@enable_dns_hostnames)).to be(true)
        expect(resource_config.instance_variable_get(:@tags)).to eq({ "Environment" => "test" })
      end
      described_class.create_vpc(mock_context, :my_vpc, "10.0.0.0/16", true, true, { "Environment" => "test" })
    end
  end

  describe ".create_internet_gateway" do
    it "calls resource with correct parameters" do
      expect(mock_context).to receive(:resource).with(:aws_internet_gateway, :my_vpc_igw) do |name, &block|
        resource_config = OpenStruct.new
        def resource_config.vpc_id(id); @vpc_id = id; end
        def resource_config.tags(tags); @tags = tags; end
        resource_config.instance_exec(&block)
        expect(resource_config.instance_variable_get(:@vpc_id)).to eq("vpc-123")
        expect(resource_config.instance_variable_get(:@tags)).to eq({ "Name" => "my_vpc_igw" })
      end
      described_class.create_internet_gateway(mock_context, :my_vpc, "vpc-123", { "Name" => "my_vpc_igw" })
    end
  end

  describe ".create_subnet" do
    it "calls resource with correct parameters" do
      expect(mock_context).to receive(:resource).with(:aws_subnet, :my_subnet) do |name, &block|
        resource_config = OpenStruct.new
        def resource_config.vpc_id(id); @vpc_id = id; end
        def resource_config.cidr_block(block); @cidr_block = block; end
        def resource_config.map_public_ip_on_launch(map); @map_public_ip_on_launch = map; end
        def resource_config.availability_zone(az); @availability_zone = az; end
        def resource_config.tags(tags); @tags = tags; end
        resource_config.instance_exec(&block)
        expect(resource_config.instance_variable_get(:@vpc_id)).to eq("vpc-123")
        expect(resource_config.instance_variable_get(:@cidr_block)).to eq("10.0.1.0/24")
        expect(resource_config.instance_variable_get(:@map_public_ip_on_launch)).to be(true)
        expect(resource_config.instance_variable_get(:@availability_zone)).to eq("us-east-1a")
        expect(resource_config.instance_variable_get(:@tags)).to eq({ "Name" => "my_subnet" })
      end
      described_class.create_subnet(mock_context, :my_subnet, "vpc-123", "10.0.1.0/24", "us-east-1a", true, { "Name" => "my_subnet" })
    end
  end
end
