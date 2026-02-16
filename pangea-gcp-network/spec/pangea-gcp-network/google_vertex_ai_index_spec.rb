require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_vertex_ai_index"

RSpec.describe "google_vertex_ai_index" do
  it "creates a vertex ai index with the correct parameters" do
    name = "my-vertex-ai-index"
    display_name = "My Vertex AI Index"
    description = "My Vertex AI Index Description"
    region = "us-central1"
    labels = {
      "my-label" => "my-value"
    }
    metadata = {
      "contentsDeltaUri" => "gs://my-bucket/my-folder",
      "config" => {
        "dimensions" => 100,
        "approximateNeighborsCount" => 10
      }
    }
    index_update_method = "BATCH_UPDATE"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:display_name) { |value| @display_name = value }
    context.define_singleton_method(:description) { |value| @description = value }
    context.define_singleton_method(:region) { |value| @region = value }
    context.define_singleton_method(:labels) { |value| @labels = value }
    context.define_singleton_method(:metadata) { |value| @metadata = value }
    context.define_singleton_method(:index_update_method) { |value| @index_update_method = value }

    context.instance_eval do
      google_vertex_ai_index(
        name: name,
        display_name: display_name,
        description: description,
        region: region,
        labels: labels,
        metadata: metadata,
        index_update_method: index_update_method
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_vertex_ai_index)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@display_name)).to eq(display_name)
    expect(context.instance_variable_get(:@description)).to eq(description)
    expect(context.instance_variable_get(:@region)).to eq(region)
    expect(context.instance_variable_get(:@labels)).to eq(labels)
    expect(context.instance_variable_get(:@metadata)).to eq(metadata)
    expect(context.instance_variable_get(:@index_update_method)).to eq(index_update_method)
  end
end
