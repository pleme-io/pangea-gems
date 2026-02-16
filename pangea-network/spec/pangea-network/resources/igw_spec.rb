# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-network/resources/igw'

RSpec.describe 'igw' do
  let(:mock_context) { double("context") }
  let(:name) { :test_igw }
  let(:vpc_id) { 'vpc-123' }
  let(:tags) { { Environment: 'test' } }

  it 'generates a igw resource block' do
    expect(mock_context).to receive(:resource).with(:aws_internet_gateway, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.vpc_id(id); @vpc_id = id; end
      def resource_config.tags(tags); @tags = tags; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@vpc_id)).to eq(vpc_id)
      expect(resource_config.instance_variable_get(:@tags)).to eq(tags)
    end
    igw(mock_context, name: name, vpc_id: vpc_id, tags: tags)
  end
end
