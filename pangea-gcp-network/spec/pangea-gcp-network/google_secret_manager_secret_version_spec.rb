require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_secret_manager_secret_version"

RSpec.describe "google_secret_manager_secret_version" do
  it "creates a secret manager secret version with the correct parameters" do
    name = "my-secret-version"
    secret = "my-secret"
    secret_data = "my-secret-data"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:secret) { |value| @secret = value }
    context.define_singleton_method(:secret_data) { |value| @secret_data = value }

    context.instance_eval do
      google_secret_manager_secret_version(
        name: name,
        secret: secret,
        secret_data: secret_data
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_secret_manager_secret_version)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@secret)).to eq(secret)
    expect(context.instance_variable_get(:@secret_data)).to eq(secret_data)
  end
end
