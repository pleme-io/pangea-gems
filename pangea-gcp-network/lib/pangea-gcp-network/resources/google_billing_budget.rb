def google_billing_budget(name:, billing_account:, budget_filter:, amount:, all_updates_rule:)
  resource :google_billing_budget, name do
    billing_account billing_account
    budget_filter do
      projects budget_filter[:projects]
    end
    amount do
      specified_amount do
        currency_code amount[:specified_amount][:currency_code]
        units         amount[:specified_amount][:units]
      end
    end
    all_updates_rule do
      pubsub_topic   all_updates_rule[:pubsub_topic]
      schema_version all_updates_rule[:schema_version]
    end
  end
  { id: "${google_billing_budget.#{name}.id}" }
end