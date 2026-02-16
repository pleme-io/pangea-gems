# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/pangea-authorization/resources/policy'

RSpec.describe 'iam_policy' do
  it 'calls resource with correct parameters' do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resources ||= []
      resource_context = Object.new
      resource_context.define_singleton_method(:name) { |value| @name = value }
      resource_context.define_singleton_method(:description) { |value| @description = value }
      resource_context.define_singleton_method(:policy) { |value| @policy = value }
      resource_context.define_singleton_method(:role) { |value| @role = value }
      resource_context.define_singleton_method(:policy_arn) { |value| @policy_arn = value }
      resource_context.instance_eval(&block) if block
      @resources << { type: type, name: name, context: resource_context }
    end

    iam_policy(context, name: 'my-policy', desc: 'My Policy', content: { 'foo' => 'bar' }, role: 'my-role')

    policy_resource = context.instance_variable_get(:@resources).find { |r| r[:type] == :aws_iam_policy }
    attachment_resource = context.instance_variable_get(:@resources).find { |r| r[:type] == :aws_iam_role_policy_attachment }

    expect(policy_resource[:name]).to eq('my-policy')
    expect(attachment_resource[:name]).to eq('my-policy')
  end
end
