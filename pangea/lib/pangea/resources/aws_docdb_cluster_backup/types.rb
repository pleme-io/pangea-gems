# frozen_string_literal: true

require 'pangea/resources/types'

module Pangea
  module Resources
    module AWS
      module Types
      # Type-safe attributes for AwsDocdbClusterBackup resources
      # Provides a DocumentDB cluster backup resource (Note: This is typically managed through cluster configuration).
      class DocdbClusterBackupAttributes < Dry::Struct
        attribute :cluster_identifier, Resources::Types::String
        attribute :backup_retention_period, Resources::Types::Integer.optional
        attribute :preferred_backup_window, Resources::Types::String.optional
        
        # Tags to apply to the resource
        attribute :tags, Resources::Types::AwsTags.default({})

        # Custom validation
        def self.new(attributes = {})
          attrs = super(attributes)
          
          
          
          
          attrs
        end
        
        # TODO: Add computed properties specific to aws_docdb_cluster_backup

      end
    end
      end
    end
  end
end