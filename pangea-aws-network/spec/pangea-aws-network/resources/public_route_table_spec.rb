# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-aws-network/resources/public_route_table'

RSpec.describe 'public_route_table' do
  let(:mock_context) { double("context") }
  let(:name) { :test_route_table }
  let(:vpc_id) { 'vpc-123' }
  let(:igw_id) { 'igw-456' }

  it 'generates a public route table and route resource blocks' do
    expect(mock_context).to receive(:resource).with(:aws_route_table, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.vpc_id(id); @vpc_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@vpc_id)).to eq(vpc_id)
    end
    expect(mock_context).to receive(:resource).with(:aws_route, :"#{name}_default_route") do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.route_table_id(id); @route_table_id = id; end
      def resource_config.destination_cidr_block(block); @destination_cidr_block = block; end
      def resource_config.gateway_id(id); @gateway_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@route_table_id)).to eq("${aws_route_table.#{self.name}.id}")
      expect(resource_config.instance_variable_get(:@destination_cidr_block)).to eq('0.0.0.0/0')
      expect(resource_config.instance_variable_get(:@gateway_id)).to eq(igw_id)
    end
    public_route_table(mock_context, name: name, vpc_id: vpc_id, igw_id: igw_id)
  end
end
