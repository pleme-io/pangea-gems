require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_managed_ssl_certificate"

RSpec.describe "google_compute_managed_ssl_certificate" do
  it "creates a compute managed ssl certificate with the correct parameters" do
    name = "my-ssl-certificate"
    managed = {
      domains: ["example.com"]
    }

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:managed) { |&block| @managed = block }

    context.instance_eval do
      google_compute_managed_ssl_certificate(
        name: name,
        managed: managed
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_managed_ssl_certificate)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
  end
end
