require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_network"

RSpec.describe "google_compute_network" do
  it "creates a compute network with the correct parameters" do
    name = "my-network"
    auto_create_subnetworks = false

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:auto_create_subnetworks) { |value| @auto_create_subnetworks = value }

    context.instance_eval do
      google_compute_network(
        name: name,
        auto_create_subnetworks: auto_create_subnetworks
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_network)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s)
    expect(context.instance_variable_get(:@auto_create_subnetworks)).to eq(auto_create_subnetworks)
  end
end
