require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_cloud_run_service_iam_member"

RSpec.describe "google_cloud_run_service_iam_member" do
  it "creates a cloud run service iam member with the correct parameters" do
    name = "my-service-iam"
    service = "my-service"
    location = "us-central1"
    role = "roles/run.invoker"
    member = "user:test@example.com"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:service) { |value| @service = value }
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:role) { |value| @role = value }
    context.define_singleton_method(:member) { |value| @member = value }

    context.instance_eval do
      google_cloud_run_service_iam_member(
        name: name,
        service: service,
        location: location,
        role: role,
        member: member
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_cloud_run_service_iam_member)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@service)).to eq(service)
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@role)).to eq(role)
    expect(context.instance_variable_get(:@member)).to eq(member)
  end
end
