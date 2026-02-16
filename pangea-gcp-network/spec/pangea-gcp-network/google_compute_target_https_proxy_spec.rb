require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_compute_target_https_proxy"

RSpec.describe "google_compute_target_https_proxy" do
  it "creates a compute target https proxy with the correct parameters" do
    name = "my-https-proxy"
    ssl_certificates = ["my-ssl-certificate"]
    url_map = "my-url-map"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:ssl_certificates) { |value| @ssl_certificates = value }
    context.define_singleton_method(:url_map) { |value| @url_map = value }

    context.instance_eval do
      google_compute_target_https_proxy(
        name: name,
        ssl_certificates: ssl_certificates,
        url_map: url_map
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_compute_target_https_proxy)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@ssl_certificates)).to eq(ssl_certificates)
    expect(context.instance_variable_get(:@url_map)).to eq(url_map)
  end
end
