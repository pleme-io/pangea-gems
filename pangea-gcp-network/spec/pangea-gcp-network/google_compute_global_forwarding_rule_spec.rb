require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_global_forwarding_rule"

RSpec.describe "google_compute_global_forwarding_rule" do
  it "creates a compute global forwarding rule with the correct parameters" do
    name = "my-forwarding-rule"
    ip_protocol = "TCP"
    port_range = "443"
    target = "my-target"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:ip_protocol) { |value| @ip_protocol = value }
    context.define_singleton_method(:port_range) { |value| @port_range = value }
    context.define_singleton_method(:target) { |value| @target = value }

    context.instance_eval do
      google_compute_global_forwarding_rule(
        name: name,
        ip_protocol: ip_protocol,
        port_range: port_range,
        target: target
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_global_forwarding_rule)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@ip_protocol)).to eq(ip_protocol)
    expect(context.instance_variable_get(:@port_range)).to eq(port_range)
    expect(context.instance_variable_get(:@target)).to eq(target)
  end
end
