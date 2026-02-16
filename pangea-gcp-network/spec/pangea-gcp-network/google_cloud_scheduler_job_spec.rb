require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_cloud_scheduler_job"

RSpec.describe "google_cloud_scheduler_job" do
  it "creates a cloud scheduler job with the correct parameters" do
    name = "my-scheduler-job"
    description = "My test scheduler job"
    schedule = "0 0 * * *"
    time_zone = "America/Los_Angeles"
    attempt_deadline = "320s"
    region = "us-central1"
    retry_config = { retry_count: 3 }
    http_target = {
      http_method: "POST",
      uri: "https://example.com/endpoint",
      body: "SGVsbG8sIFdvcmxkIQ==",
      headers: {
        "Content-Type" => "application/octet-stream"
      }
    }

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:name) { |value| @name = value }
    context.define_singleton_method(:description) { |value| @description = value }
    context.define_singleton_method(:schedule) { |value| @schedule = value }
    context.define_singleton_method(:time_zone) { |value| @time_zone = value }
    context.define_singleton_method(:attempt_deadline) { |value| @attempt_deadline = value }
    context.define_singleton_method(:region) { |value| @region = value }
    context.define_singleton_method(:retry_config) { |&block| @retry_config = block }
    context.define_singleton_method(:http_target) { |&block| @http_target = block }

    context.instance_eval do
      google_cloud_scheduler_job(
        name: name,
        description: description,
        schedule: schedule,
        time_zone: time_zone,
        attempt_deadline: attempt_deadline,
        region: region,
        retry_config: retry_config,
        http_target: http_target
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_cloud_scheduler_job)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@name)).to eq(name.to_s.gsub('_', '-'))
    expect(context.instance_variable_get(:@description)).to eq(description)
    expect(context.instance_variable_get(:@schedule)).to eq(schedule)
    expect(context.instance_variable_get(:@time_zone)).to eq(time_zone)
    expect(context.instance_variable_get(:@attempt_deadline)).to eq(attempt_deadline)
    expect(context.instance_variable_get(:@region)).to eq(region)
  end
end
