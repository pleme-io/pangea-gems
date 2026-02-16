require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_target_http_proxy"

RSpec.describe "google_compute_target_http_proxy" do
  it "creates a compute target http proxy with the correct parameters" do
    name = "my-http-proxy"
    url_map = "my-url-map"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:url_map) { |value| @url_map = value }

    context.instance_eval do
      google_compute_target_http_proxy(
        name: name,
        url_map: url_map
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_target_http_proxy)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@url_map)).to eq(url_map)
  end
end
