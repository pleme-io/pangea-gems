require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_service_account_key"

RSpec.describe "google_service_account_key" do
  it "creates a service account key with the correct parameters" do
    name = "my-service-account-key"
    service_account_id = "my-service-account-id"
    private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:service_account_id) { |value| @service_account_id = value }
    context.define_singleton_method(:private_key_type) { |value| @private_key_type = value }

    context.instance_eval do
      google_service_account_key(
        name: name,
        service_account_id: service_account_id,
        private_key_type: private_key_type
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_service_account_key)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@service_account_id)).to eq(service_account_id)
    expect(context.instance_variable_get(:@private_key_type)).to eq(private_key_type)
  end
end
