require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_artifact_registry_repository"
require_relative "../../lib/pangea-gcp-network/resources/google_artifact_registry_repository_iam_member"

RSpec.describe "google_artifact_registry_repository" do
  it "creates a repository with the correct parameters" do
    name = "my-repo"
    format = "DOCKER"
    repository_id = "my-repo-id"
    location = "us-central1"
    description = "My test repository"
    project = "my-project"
    depends_on = []
    cleanup_policies = []

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:format) { |value| @format = value }
    context.define_singleton_method(:repository_id) { |value| @repository_id = value }
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:description) { |value| @description = value }
    context.define_singleton_method(:project) { |value| @project = value }
    context.define_singleton_method(:depends_on) { |value| @depends_on = value }
    context.define_singleton_method(:cleanup_policies) { |value| @cleanup_policies = value }

    context.instance_eval do
      google_artifact_registry_repository(
        name: name,
        format: format,
        repository_id: repository_id,
        location: location,
        description: description,
        project: project,
        depends_on: depends_on,
        cleanup_policies: cleanup_policies
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_artifact_registry_repository)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@format)).to eq(format)
    expect(context.instance_variable_get(:@repository_id)).to eq(repository_id)
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@description)).to eq(description)
    expect(context.instance_variable_get(:@project)).to eq(project)
    expect(context.instance_variable_get(:@depends_on)).to eq(depends_on)
    expect(context.instance_variable_get(:@cleanup_policies)).to eq(cleanup_policies)
  end
end

RSpec.describe "google_artifact_registry_repository_iam_member" do
  it "creates a repository iam member with the correct parameters" do
    name = "my-repo-iam"
    location = "us-central1"
    repository = "my-repo"
    role = "roles/artifactregistry.reader"
    member = "user:test@example.com"

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:location) { |value| @location = value }
    context.define_singleton_method(:repository) { |value| @repository = value }
    context.define_singleton_method(:role) { |value| @role = value }
    context.define_singleton_method(:member) { |value| @member = value }

    context.instance_eval do
      google_artifact_registry_repository_iam_member(
        name: name,
        location: location,
        repository: repository,
        role: role,
        member: member
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_artifact_registry_repository_iam_member)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@location)).to eq(location)
    expect(context.instance_variable_get(:@repository)).to eq(repository)
    expect(context.instance_variable_get(:@role)).to eq(role)
    expect(context.instance_variable_get(:@member)).to eq(member)
  end
end
