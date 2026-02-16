# frozen_string_literal: true

require_relative '../spec_helper'
require_relative "../../lib/pangea-gcp-network/resources/create_firewall"

RSpec.describe "create_firewall" do
  it "calls resource with correct parameters for TCP and UDP ports" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:source_ranges) { |value| @source_ranges = value }
    context.define_singleton_method(:allow) do |&block|
      @allow ||= []
      allow_context = Object.new
      allow_context.define_singleton_method(:protocol) { |value| @protocol = value }
      allow_context.define_singleton_method(:ports) { |value| @ports = value }
      allow_context.instance_eval(&block)
      @allow << { protocol: allow_context.instance_variable_get(:@protocol), ports: allow_context.instance_variable_get(:@ports) }
    end

    create_firewall(context, :my_firewall, "network-id", ['10.0.0.0/24'], [22, 80, 443], [53])

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_firewall)
    expect(context.instance_variable_get(:@resource_name)).to eq(:my_firewall)
    expect(context.instance_variable_get(:@name)).to eq("my-firewall")
    expect(context.instance_variable_get(:@network)).to eq("network-id")
    expect(context.instance_variable_get(:@source_ranges)).to eq(['10.0.0.0/24'])
    expect(context.instance_variable_get(:@allow)).to eq([
      { protocol: 'tcp', ports: [22, 80, 443] },
      { protocol: 'udp', ports: [53] }
    ])
  end

  it "calls resource with correct parameters for only TCP ports" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:source_ranges) { |value| @source_ranges = value }
    context.define_singleton_method(:allow) do |&block|
      @allow ||= []
      allow_context = Object.new
      allow_context.define_singleton_method(:protocol) { |value| @protocol = value }
      allow_context.define_singleton_method(:ports) { |value| @ports = value }
      allow_context.instance_eval(&block)
      @allow << { protocol: allow_context.instance_variable_get(:@protocol), ports: allow_context.instance_variable_get(:@ports) }
    end

    create_firewall(context, :my_firewall_tcp, "network-id", ['10.0.0.0/24'], [80, 443])

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_firewall)
    expect(context.instance_variable_get(:@resource_name)).to eq(:my_firewall_tcp)
    expect(context.instance_variable_get(:@name)).to eq("my-firewall-tcp")
    expect(context.instance_variable_get(:@network)).to eq("network-id")
    expect(context.instance_variable_get(:@source_ranges)).to eq(['10.0.0.0/24'])
    expect(context.instance_variable_get(:@allow)).to eq([
      { protocol: 'tcp', ports: [80, 443] }
    ])
  end

  it "calls resource with correct parameters for only UDP ports" do
    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:network) { |value| @network = value }
    context.define_singleton_method(:source_ranges) { |value| @source_ranges = value }
    context.define_singleton_method(:allow) do |&block|
      @allow ||= []
      allow_context = Object.new
      allow_context.define_singleton_method(:protocol) { |value| @protocol = value }
      allow_context.define_singleton_method(:ports) { |value| @ports = value }
      allow_context.instance_eval(&block)
      @allow << { protocol: allow_context.instance_variable_get(:@protocol), ports: allow_context.instance_variable_get(:@ports) }
    end

    create_firewall(context, :my_firewall_udp, "network-id", ['10.0.0.0/24'], [], [53])

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_firewall)
    expect(context.instance_variable_get(:@resource_name)).to eq(:my_firewall_udp)
    expect(context.instance_variable_get(:@name)).to eq("my-firewall-udp")
    expect(context.instance_variable_get(:@network)).to eq("network-id")
    expect(context.instance_variable_get(:@source_ranges)).to eq(['10.0.0.0/24'])
    expect(context.instance_variable_get(:@allow)).to eq([
      { protocol: 'udp', ports: [53] }
    ])
  end
end
