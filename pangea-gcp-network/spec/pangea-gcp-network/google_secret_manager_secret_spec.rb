require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_secret_manager_secret"

RSpec.describe "google_secret_manager_secret" do
  it "creates a secret manager secret with the correct parameters" do
    name = "my-secret"
    secret_id = "my-secret-id"
    replication = {
      user_managed: {
        replicas: [
          {
            location: "us-central1"
          }
        ]
      }
    }

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:secret_id) { |value| @secret_id = value }
    context.define_singleton_method(:replication) { |&block| @replication = block }

    context.instance_eval do
      google_secret_manager_secret(
        name: name,
        secret_id: secret_id,
        replication: replication
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_secret_manager_secret)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@secret_id)).to eq(secret_id)
  end
end
