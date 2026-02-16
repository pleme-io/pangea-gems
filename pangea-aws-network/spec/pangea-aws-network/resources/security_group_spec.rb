# frozen_string_literal: true

require_relative '../../spec_helper'
require 'pangea-aws-network/resources/security_group'
require 'ostruct'

RSpec.describe 'security_group' do
  let(:mock_context) { double("context") }

  it "calls resource with correct parameters" do
    expect(mock_context).to receive(:resource).with(:aws_security_group, :my_sg) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.vpc_id(id); @vpc_id = id; end
      def resource_config.description(desc); @description = desc; end
      def resource_config.tags(tags); @tags = tags; end
      def resource_config.name(name); @name = name; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@vpc_id)).to eq("vpc-123")
      expect(resource_config.instance_variable_get(:@description)).to eq('My Security Group')
      expect(resource_config.instance_variable_get(:@tags)).to eq({ Name: "my_sg" })
    end
    security_group(mock_context, :my_sg, "vpc-123", 'My Security Group', { Name: "my_sg" })
  end
end