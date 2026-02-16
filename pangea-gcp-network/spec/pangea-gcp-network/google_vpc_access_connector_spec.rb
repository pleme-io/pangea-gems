require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_vpc_access_connector"

RSpec.describe "google_vpc_access_connector" do
  it "creates a vpc access connector with the correct parameters" do
    name = "my-vpc-access-connector"
    region = "us-central1"
    network = "my-network"
    ip_cidr_range = "10.8.0.0/28"
    machine_type = "e2-micro"
    min_instances = 2
    max_instances = 3
    depends_on = ["my-dependency"]

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:region) { |value| @region = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:ip_cidr_range) { |value| @ip_cidr_range = value }
    context.define_singleton_method(:machine_type) { |value| @machine_type = value }
    context.define_singleton_method(:min_instances) { |value| @min_instances = value }
    context.define_singleton_method(:max_instances) { |value| @max_instances = value }
    context.define_singleton_method(:depends_on) { |value| @depends_on = value }

    context.instance_eval do
      google_vpc_access_connector(
        name: name,
        region: region,
        network: network,
        ip_cidr_range: ip_cidr_range,
        machine_type: machine_type,
        min_instances: min_instances,
        max_instances: max_instances,
        depends_on: depends_on
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_vpc_access_connector)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@region)).to eq(region)
    expect(context.instance_variable_get(:@network)).to eq(network)
    expect(context.instance_variable_get(:@ip_cidr_range)).to eq(ip_cidr_range)
    expect(context.instance_variable_get(:@machine_type)).to eq(machine_type)
    expect(context.instance_variable_get(:@min_instances)).to eq(min_instances)
    expect(context.instance_variable_get(:@max_instances)).to eq(max_instances)
    expect(context.instance_variable_get(:@depends_on)).to eq(depends_on)
  end
end
