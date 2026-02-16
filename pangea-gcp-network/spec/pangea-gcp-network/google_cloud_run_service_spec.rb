require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_cloud_run_service"

RSpec.describe "google_cloud_run_service" do
  it "creates a cloud run service with the correct parameters" do
    name = "my-service"
    location = "us-central1"
    template = {
      metadata: {
        annotations: {
          "run.googleapis.com/ingress" => "all"
        }
      },
      spec: {
        container_concurrency: 80,
        containers: [
          {
            image: "gcr.io/my-project/my-image:latest",
            ports: [{ container_port: 8080 }],
            resources: {
              limits: {
                cpu: "1000m",
                memory: "512Mi"
              }
            }
          }
        ]
      }
    }
    lifecycle = {
      ignore_changes: ["template.metadata.annotations"]
    }
    traffic = [
      {
        percent: 100,
        latest_revision: true
      }
    ]

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:template) { |&block| @template = block }
    context.define_singleton_method(:lifecycle) { |&block| @lifecycle = block }
    context.define_singleton_method(:traffic) { |value| @traffic = value }

    context.instance_eval do
      google_cloud_run_service(
        name: name,
        location: location,
        template: template,
        lifecycle: lifecycle,
        traffic: traffic,
        autogenerate_revision_name: nil
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_cloud_run_service)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@traffic)).to eq(traffic)
  end

  it "creates a cloud run service with a virtual name" do
    name = "my-service"
    virtual_name = :my_virtual_service
    location = "us-central1"
    template = {
      metadata: {
        annotations: {
          "run.googleapis.com/ingress" => "all"
        }
      },
      spec: {
        container_concurrency: 80,
        containers: [
          {
            image: "gcr.io/my-project/my-image:latest",
            ports: [{ container_port: 8080 }],
            resources: {
              limits: {
                cpu: "1000m",
                memory: "512Mi"
              }
            }
          }
        ]
      }
    }
    lifecycle = {
      ignore_changes: ["template.metadata.annotations"]
    }
    traffic = [
      {
        percent: 100,
        latest_revision: true
      }
    ]

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:template) { |&block| @template = block }
    context.define_singleton_method(:lifecycle) { |&block| @lifecycle = block }
    context.define_singleton_method(:traffic) { |value| @traffic = value }

    context.instance_eval do
      google_cloud_run_service(
        name: name,
        virtual: virtual_name,
        location: location,
        template: template,
        lifecycle: lifecycle,
        traffic: traffic,
        autogenerate_revision_name: nil
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_cloud_run_service)
    expect(context.instance_variable_get(:@resource_name)).to eq(virtual_name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@traffic)).to eq(traffic)
  end
end
