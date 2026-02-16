require "spec_helper"
require_relative "../../lib/pangea-gcp-network/resources/google_billing_budget"

RSpec.describe "google_billing_budget" do
  it "creates a billing budget with the correct parameters" do
    name = "my-budget"
    billing_account = "my-billing-account"
    budget_filter = { projects: ["my-project"] }
    amount = { specified_amount: { currency_code: "USD", units: "100" } }
    all_updates_rule = { pubsub_topic: "my-topic", schema_version: "1.0" }

    context = Object.new
    context.define_singleton_method(:resource) do |type, name, &block|
      @resource_type = type
      @resource_name = name
      instance_eval(&block)
    end
    context.define_singleton_method(:billing_account) { |value| @billing_account = value }
    context.define_singleton_method(:budget_filter) do |&block|
      filter_context = Object.new
      filter_context.define_singleton_method(:projects) { |value| @projects = value }
      filter_context.instance_eval(&block)
      @budget_filter = filter_context.instance_variable_get(:@projects)
    end
    context.define_singleton_method(:amount) do |&block|
      amount_context = Object.new
      amount_context.define_singleton_method(:specified_amount) do |&block|
        specified_amount_context = Object.new
        specified_amount_context.define_singleton_method(:currency_code) { |value| @currency_code = value }
        specified_amount_context.define_singleton_method(:units) { |value| @units = value }
        specified_amount_context.instance_eval(&block)
        @specified_amount = specified_amount_context
      end
      amount_context.instance_eval(&block)
      @amount = amount_context.instance_variable_get(:@specified_amount)
    end
    context.define_singleton_method(:all_updates_rule) do |&block|
      rule_context = Object.new
      rule_context.define_singleton_method(:pubsub_topic) { |value| @pubsub_topic = value }
      rule_context.define_singleton_method(:schema_version) { |value| @schema_version = value }
      rule_context.instance_eval(&block)
      @all_updates_rule = rule_context
    end

    context.instance_eval do
      google_billing_budget(
        name: name,
        billing_account: billing_account,
        budget_filter: budget_filter,
        amount: amount,
        all_updates_rule: all_updates_rule
      )
    end

    expect(context.instance_variable_get(:@resource_type)).to eq(:google_billing_budget)
    expect(context.instance_variable_get(:@resource_name)).to eq(name)
    expect(context.instance_variable_get(:@billing_account)).to eq(billing_account)
    expect(context.instance_variable_get(:@budget_filter)).to eq(budget_filter[:projects])
    expect(context.instance_variable_get(:@amount).instance_variable_get(:@currency_code)).to eq(amount[:specified_amount][:currency_code])
    expect(context.instance_variable_get(:@amount).instance_variable_get(:@units)).to eq(amount[:specified_amount][:units])
    expect(context.instance_variable_get(:@all_updates_rule).instance_variable_get(:@pubsub_topic)).to eq(all_updates_rule[:pubsub_topic])
    expect(context.instance_variable_get(:@all_updates_rule).instance_variable_get(:@schema_version)).to eq(all_updates_rule[:schema_version])
  end
end
