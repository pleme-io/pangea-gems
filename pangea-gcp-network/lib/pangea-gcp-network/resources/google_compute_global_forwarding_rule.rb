def google_compute_global_forwarding_rule(name:, ip_protocol:, port_range:, target:)
  resource :google_compute_global_forwarding_rule, name do
    name name.to_s.gsub('_', '-')
    ip_protocol ip_protocol
    port_range port_range
    target target
  end
  { id: "${google_compute_global_forwarding_rule.#{name}.id}" }
end