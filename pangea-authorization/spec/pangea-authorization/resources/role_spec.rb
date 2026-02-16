# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/pangea-authorization/resources/role'

RSpec.describe 'iam_role' do
  it 'calls resource with correct parameters' do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:tags) { |value| @tags = value }
    context.define_singleton_method(:assume_role_policy) { |value| @assume_role_policy = value }

    result = iam_role(context, name: 'my-role', tags: { 'environment' => 'test' }, assume_role_policy: 'policy')

    expect(context.instance_variable_get(:@resource_type)).to eq(:aws_iam_role)
    expect(context.instance_variable_get(:@resource_name)).to eq('my-role')
    expect(context.instance_variable_get(:@name)).to eq('my-role')
    expect(context.instance_variable_get(:@tags)).to eq({ 'environment' => 'test' })
    expect(context.instance_variable_get(:@assume_role_policy)).to eq('policy')
    expect(result).to eq({ name: 'my-role', arn: '${aws_iam_role.my-role.arn}' })
  end
end
