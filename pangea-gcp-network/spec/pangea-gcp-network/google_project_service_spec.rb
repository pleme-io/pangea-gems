require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_project_service"

RSpec.describe "google_project_service" do
  it "creates a project service with the correct parameters" do
    name = "my-project-service"
    service = "my-service"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:service) { |value| @service = value }

    context.instance_eval do
      google_project_service(
        name: name,
        service: service
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_project_service)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@service)).to eq(service)
  end
end
