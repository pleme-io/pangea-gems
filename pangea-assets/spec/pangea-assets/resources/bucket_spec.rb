# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/pangea-assets/resources/bucket'

RSpec.describe 'bucket' do
  it 'calls resource with correct parameters' do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:bucket) { |value| @bucket = value }
    context.define_singleton_method(:tags) { |value| @tags = value }

    result = bucket(context, name: 'my-bucket', tags: { 'environment' => 'test' })

    expect(context.instance_variable_get(:@resource_type)).to eq(:aws_s3_bucket)
    expect(context.instance_variable_get(:@resource_name)).to eq('my-bucket')
    expect(context.instance_variable_get(:@bucket)).to eq('my-bucket')
    expect(context.instance_variable_get(:@tags)).to eq({ 'environment' => 'test' })
    expect(result).to eq({ name: 'my-bucket', arn: '${aws_s3_bucket.my-bucket.arn}' })
  end
end
