# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../../lib/pangea-network/resources/eks'

RSpec.describe 'eks' do
  let(:mock_context) { double("context") }
  let(:name) { :test_eks }
  let(:role_arn) { 'arn:aws:iam::123456789012:role/eks-role' }

  it 'generates a eks cluster resource block' do
    expect(mock_context).to receive(:resource).with(:aws_eks_cluster, name) do |name, &block|
      resource_config = OpenStruct.new
      def resource_config.name(name); @name = name; end
      def resource_config.role_arn(arn); @role_arn = arn; end
      def resource_config.version(v); @version = v; end
      def resource_config.access_config(ac); @access_config = ac; end
      def resource_config.vpc_config(vc); @vpc_config = vc; end
      def resource_config.bootstrap_self_managed_addons(bsma); @bootstrap_self_managed_addons = bsma; end
      def resource_config.compute_config(cc); @compute_config = cc; end
      def resource_config.kubernetes_network_config(knc); @kubernetes_network_config = knc; end
      def resource_config.storage_config(sc); @storage_config = sc; end
      resource_config.instance_exec(&block)
      expect(resource_config.instance_variable_get(:@name)).to eq(self.name.to_s)
      expect(resource_config.instance_variable_get(:@role_arn)).to eq(role_arn)
      expect(resource_config.instance_variable_get(:@version)).to eq('1.31')
      expect(resource_config.instance_variable_get(:@access_config)).to eq({ authentication_mode: :API })
      expect(resource_config.instance_variable_get(:@vpc_config)).to eq({})
      expect(resource_config.instance_variable_get(:@bootstrap_self_managed_addons)).to be(false)
      expect(resource_config.instance_variable_get(:@compute_config)).to eq({})
      expect(resource_config.instance_variable_get(:@kubernetes_network_config)).to eq({})
      expect(resource_config.instance_variable_get(:@storage_config)).to eq({})
    end
    eks(mock_context, name: name, role_arn: role_arn)
  end
end
