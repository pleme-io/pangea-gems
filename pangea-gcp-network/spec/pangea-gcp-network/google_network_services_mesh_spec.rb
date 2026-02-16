require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_network_services_mesh"

RSpec.describe "google_network_services_mesh" do
  it "creates a network services mesh with the correct parameters" do
    name = "my-mesh"
    location = "global"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:location) { |value| @location = value }

    context.instance_eval do
      google_network_services_mesh(
        name: name,
        location: location
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_network_services_mesh)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@location)).to eq(location)
  end
end
