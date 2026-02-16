# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-network/resources/subnet'

RSpec.describe 'subnet' do
  let(:mock_context) { double("context") }
  let(:name) { :test_subnet }
  let(:vpc_id) { 'vpc-123' }
  let(:cidr_block) { '10.0.1.0/24' }
  let(:availability_zone) { 'us-west-2a' }
  let(:tags) { { Environment: 'test' } }

  it 'generates a subnet resource block' do
    expect(mock_context).to receive(:resource).with(:aws_subnet, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.vpc_id(id); @vpc_id = id; end
      def resource_config.cidr_block(block); @cidr_block = block; end
      def resource_config.map_public_ip_on_launch(map); @map_public_ip_on_launch = map; end
      def resource_config.availability_zone(az); @availability_zone = az; end
      def resource_config.tags(tags); @tags = tags; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@vpc_id)).to eq(vpc_id)
      expect(resource_config.instance_variable_get(:@cidr_block)).to eq(cidr_block)
      expect(resource_config.instance_variable_get(:@map_public_ip_on_launch)).to be(false)
      expect(resource_config.instance_variable_get(:@availability_zone)).to eq(availability_zone)
      expect(resource_config.instance_variable_get(:@tags)).to eq(tags)
    end
    subnet(
      mock_context,
      name: name,
      vpc_id: vpc_id,
      cidr_block: cidr_block,
      availability_zone: availability_zone,
      tags: tags
    )
  end
end
