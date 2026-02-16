require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_global_address"

RSpec.describe "google_compute_global_address" do
  it "creates a compute global address with the correct parameters" do
    name = "my-global-address"
    purpose = "VPC_PEERING"
    address_type = "INTERNAL"
    prefix_length = 16
    network = "my-network"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:purpose) { |value| @purpose = value }
    context.define_singleton_method(:address_type) { |value| @address_type = value }
    context.define_singleton_method(:prefix_length) { |value| @prefix_length = value }
    context.define_singleton_method(:network) { |value| @network = value }

    context.instance_eval do
      google_compute_global_address(
        name: name,
        purpose: purpose,
        address_type: address_type,
        prefix_length: prefix_length,
        network: network
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_global_address)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@purpose)).to eq(purpose)
    expect(context.instance_variable_get(:@address_type)).to eq(address_type)
    expect(context.instance_variable_get(:@prefix_length)).to eq(prefix_length)
    expect(context.instance_variable_get(:@network)).to eq(network)
  end
end
