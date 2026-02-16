# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/pangea-aws-network/resources/security_group_rule'
require 'ostruct'

RSpec.describe 'security_group_rule' do
  let(:mock_context) { double("context") }

  it "calls resource with correct parameters for ingress with cidr_blocks" do
    expect(mock_context).to receive(:resource).with(:aws_security_group_rule, :my_rule) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.security_group_id(id); @security_group_id = id; end
      def resource_config.type(type); @type = type; end
      def resource_config.from_port(port); @from_port = port; end
      def resource_config.to_port(port); @to_port = port; end
      def resource_config.protocol(protocol); @protocol = protocol; end
      def resource_config.cidr_blocks(blocks); @cidr_blocks = blocks; end
      def resource_config.source_security_group_id(id); @source_security_group_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@security_group_id)).to eq("sg-123")
      expect(resource_config.instance_variable_get(:@type)).to eq('ingress')
      expect(resource_config.instance_variable_get(:@from_port)).to eq(80)
      expect(resource_config.instance_variable_get(:@to_port)).to eq(80)
      expect(resource_config.instance_variable_get(:@protocol)).to eq('tcp')
      expect(resource_config.instance_variable_get(:@cidr_blocks)).to eq(['0.0.0.0/0'])
      expect(resource_config.instance_variable_get(:@source_security_group_id)).to be_nil
    end
    security_group_rule(mock_context, :my_rule, "sg-123", 'ingress', 80, 80, 'tcp', ['0.0.0.0/0'])
  end

  it "calls resource with correct parameters for egress with source_security_group_id" do
    expect(mock_context).to receive(:resource).with(:aws_security_group_rule, :my_egress_rule) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.security_group_id(id); @security_group_id = id; end
      def resource_config.type(type); @type = type; end
      def resource_config.from_port(port); @from_port = port; end
      def resource_config.to_port(port); @to_port = port; end
      def resource_config.protocol(protocol); @protocol = protocol; end
      def resource_config.cidr_blocks(blocks); @cidr_blocks = blocks; end
      def resource_config.source_security_group_id(id); @source_security_group_id = id; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@security_group_id)).to eq("sg-123")
      expect(resource_config.instance_variable_get(:@type)).to eq('egress')
      expect(resource_config.instance_variable_get(:@from_port)).to eq(3306)
      expect(resource_config.instance_variable_get(:@to_port)).to eq(3306)
      expect(resource_config.instance_variable_get(:@protocol)).to eq('tcp')
      expect(resource_config.instance_variable_get(:@cidr_blocks)).to be_nil
      expect(resource_config.instance_variable_get(:@source_security_group_id)).to eq("sg-456")
    end
    security_group_rule(mock_context, :my_egress_rule, "sg-123", 'egress', 3306, 3306, 'tcp', [], "sg-456")
  end
end