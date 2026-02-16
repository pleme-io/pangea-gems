# frozen_string_literal: true

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/aws_docdb_cluster_backup/types'
require 'pangea/resource_registry'

module Pangea
  module Resources
    module AWS
      # Provides a DocumentDB cluster backup resource (Note: This is typically managed through cluster configuration).
      #
      # @param name [Symbol] The resource name
      # @param attributes [Hash] Resource attributes
      # @return [ResourceReference] Reference object with outputs and computed properties
      def aws_docdb_cluster_backup(name, attributes = {})
        # Validate attributes using dry-struct
        attrs = Types::DocdbClusterBackupAttributes.new(attributes)
        
        # Generate terraform resource block via terraform-synthesizer
        resource(:aws_docdb_cluster_backup, name) do
          cluster_identifier attrs.cluster_identifier if attrs.cluster_identifier
          backup_retention_period attrs.backup_retention_period if attrs.backup_retention_period
          preferred_backup_window attrs.preferred_backup_window if attrs.preferred_backup_window
          
          # Apply tags if present
          if attrs.tags.any?
            tags do
              attrs.tags.each do |key, value|
                public_send(key, value)
              end
            end
          end
        end
        
        # Return resource reference with available outputs
        ResourceReference.new(
          type: 'aws_docdb_cluster_backup',
          name: name,
          resource_attributes: attrs.to_h,
          outputs: {
            id: "${aws_docdb_cluster_backup.#{name}.id}",
            cluster_identifier: "${aws_docdb_cluster_backup.#{name}.cluster_identifier}"
          },
          computed_properties: {
            # Computed properties from type definitions
          }
        )
      end
    end
  end
end


# Auto-register this module when it's loaded
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)