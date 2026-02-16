# frozen_string_literal: true

require 'dry-struct'
require 'pangea/resources/types'
require 'pangea/resources/base'
require 'pangea/resources/reference'

module Pangea
  module Resources
    module AWS
      module ElastiCacheExtended
        class BackupPolicyAttributes < Dry::Struct
          attribute :cache_cluster_id, Types::String
          attribute :snapshot_retention_limit, Types::Integer
          attribute :snapshot_window, Types::String.optional
        end

        class BackupPolicyReference < ::Pangea::Resources::ResourceReference
          property :id
        end

        module BackupPolicy
          def aws_elasticache_backup_policy(name, attributes = {})
            attrs = BackupPolicyAttributes.new(attributes)
            
            synthesizer.resource :aws_elasticache_backup_policy, name do
              cache_cluster_id attrs.cache_cluster_id
              snapshot_retention_limit attrs.snapshot_retention_limit
              snapshot_window attrs.snapshot_window if attrs.snapshot_window
            end

            BackupPolicyReference.new(name, :aws_elasticache_backup_policy, synthesizer, attrs)
          end
        end
      end
    end
  end
end