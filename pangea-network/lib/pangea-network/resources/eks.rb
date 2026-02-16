# frozen_string_literal: true

def eks(
  context,
  name:,
  role_arn: nil,
  resource_name: nil,
  version: '1.31',
  access_config: { authentication_mode: :API },
  vpc_config: {},
  bootstrap_self_managed_addons: false,
  compute_config: {},
  kubernetes_network_config: {},
  storage_config: {}
)
  resource_name = name if resource_name.nil?
  context.resource :aws_eks_cluster, resource_name do
    name name.to_s
    role_arn role_arn
    version version
    access_config access_config
    vpc_config vpc_config
    bootstrap_self_managed_addons bootstrap_self_managed_addons
    compute_config compute_config
    kubernetes_network_config kubernetes_network_config
    storage_config storage_config
  end
end