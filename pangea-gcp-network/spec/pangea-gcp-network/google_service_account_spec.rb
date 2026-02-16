require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_service_account"

RSpec.describe "google_service_account" do
  it "creates a service account with the correct parameters" do
    name = "my-service-account"
    account_id = "my-service-account-id"
    display_name = "My Service Account"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:account_id) { |value| @account_id = value }
    context.define_singleton_method(:display_name) { |value| @display_name = value }

    context.instance_eval do
      google_service_account(
        name: name,
        account_id: account_id,
        display_name: display_name
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_service_account)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@account_id)).to eq(account_id)
    expect(context.instance_variable_get(:@display_name)).to eq(display_name)
  end
end
