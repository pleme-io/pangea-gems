require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_url_map"

RSpec.describe "google_compute_url_map" do
  it "creates a compute url map with the correct parameters" do
    name = "my-url-map"
    default_service = "my-default-service"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:default_service) { |value| @default_service = value }

    context.instance_eval do
      google_compute_url_map(
        name: name,
        default_service: default_service
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_url_map)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@default_service)).to eq(default_service)
  end
end
