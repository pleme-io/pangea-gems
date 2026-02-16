require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_firewall"

RSpec.describe "google_compute_firewall" do
  it "creates a compute firewall with the correct parameters" do
    name = "my-firewall"
    network = "my-network"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol: "tcp",
      ports: ["80", "443"]
    }]

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:source_ranges) { |value| @source_ranges = value }
    context.define_singleton_method(:allow) { |value| @allow = value }

    context.instance_eval do
      google_compute_firewall(
        name: name,
        network: network,
        source_ranges: source_ranges,
        allow: allow
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_firewall)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@network)).to eq(network)
    expect(context.instance_variable_get(:@source_ranges)).to eq(source_ranges)
    expect(context.instance_variable_get(:@allow)).to eq(allow)
  end
end
