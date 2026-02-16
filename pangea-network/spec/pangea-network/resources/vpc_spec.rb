# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-network/resources/vpc'

RSpec.describe 'vpc' do
  let(:mock_context) { double("context") }
  let(:name) { :test_vpc }
  let(:tags) { { Environment: 'test' } }
  let(:cidr_block) { '10.0.0.0/16' }

  it 'generates a vpc resource block' do
    expect(mock_context).to receive(:resource).with(:aws_vpc, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.cidr_block(block); @cidr_block = block; end
      def resource_config.enable_dns_support(enable); @enable_dns_support = enable; end
      def resource_config.tags(tags); @tags = tags; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@cidr_block)).to eq(cidr_block)
      expect(resource_config.instance_variable_get(:@enable_dns_support)).to be(true)
      expect(resource_config.instance_variable_get(:@tags)).to eq(tags)
    end
    vpc(mock_context, name: name, tags: tags, cidr_block: cidr_block)
  end
end