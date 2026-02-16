require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_subnetwork"

RSpec.describe "google_compute_subnetwork" do
  it "creates a compute subnetwork with the correct parameters" do
    name = "my-subnetwork"
    ip_cidr_range = "10.0.0.0/16"
    region = "us-central1"
    network = "my-network"
    private_ip_google_access = true

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:ip_cidr_range) { |value| @ip_cidr_range = value }
    context.define_singleton_method(:region) { |value| @region = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:private_ip_google_access) { |value| @private_ip_google_access = value }

    context.instance_eval do
      google_compute_subnetwork(
        name: name,
        ip_cidr_range: ip_cidr_range,
        region: region,
        network: network,
        private_ip_google_access: private_ip_google_access
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_subnetwork)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s)
    expect(context.instance_variable_get(:@ip_cidr_range)).to eq(ip_cidr_range)
    expect(context.instance_variable_get(:@region)).to eq(region)
    expect(context.instance_variable_get(:@network)).to eq(network)
    expect(context.instance_variable_get(:@private_ip_google_access)).to eq(private_ip_google_access)
  end
end
