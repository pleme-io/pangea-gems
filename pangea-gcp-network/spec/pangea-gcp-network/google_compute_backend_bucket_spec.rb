require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_backend_bucket"

RSpec.describe "google_compute_backend_bucket" do
  it "creates a compute backend bucket with the correct parameters" do
    name = "my-backend-bucket"
    bucket_name = "my-bucket"
    enable_cdn = true

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:bucket_name) { |value| @bucket_name = value }
    context.define_singleton_method(:enable_cdn) { |value| @enable_cdn = value }

    context.instance_eval do
      google_compute_backend_bucket(
        name: name,
        bucket_name: bucket_name,
        enable_cdn: enable_cdn
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_backend_bucket)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@bucket_name)).to eq(bucket_name)
    expect(context.instance_variable_get(:@enable_cdn)).to eq(enable_cdn)
  end
end
