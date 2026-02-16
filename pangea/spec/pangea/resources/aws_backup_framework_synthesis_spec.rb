# frozen_string_literal: true

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/aws_backup_framework/resource'
require 'pangea/resources/aws_backup_framework/types'

RSpec.describe 'aws_backup_framework synthesis' do
  include Pangea::Resources::AWS
  
  let(:synthesizer) { TerraformSynthesizer.new }
  
  describe 'terraform synthesis' do
    it 'synthesizes basic backup framework' do
      synthesizer.instance_eval do
        aws_backup_framework(:basic_framework, {
          name: "BasicFramework",
          description: "Basic backup compliance framework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:basic_framework]
      
      expect(framework).to include(
        name: "BasicFramework",
        description: "Basic backup compliance framework"
      )
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with frequency controls' do
      synthesizer.instance_eval do
        aws_backup_framework(:frequency_framework, {
          name: "FrequencyFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "hours"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "24"
                }
              ]
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:frequency_framework]
      
      expect(framework[:name]).to eq("FrequencyFramework")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with resource scope filtering' do
      synthesizer.instance_eval do
        aws_backup_framework(:scoped_framework, {
          name: "ScopedFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
              scope: {
                compliance_resource_types: ["EBS", "RDS"],
                tags: {
                  "Environment" => "production"
                }
              }
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:scoped_framework]
      
      expect(framework[:name]).to eq("ScopedFramework")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with multiple controls' do
      synthesizer.instance_eval do
        aws_backup_framework(:multi_control, {
          name: "MultiControlFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "1"
                }
              ]
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            },
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:multi_control]
      
      expect(framework[:name]).to eq("MultiControlFramework")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with retention parameters' do
      synthesizer.instance_eval do
        aws_backup_framework(:retention_framework, {
          name: "RetentionFramework",
          control: [
            {
              name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                },
                {
                  parameter_name: "requiredRetentionDays",
                  parameter_value: "30"
                }
              ]
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:retention_framework]
      
      expect(framework[:name]).to eq("RetentionFramework")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with complex scope configuration' do
      synthesizer.instance_eval do
        aws_backup_framework(:complex_scope, {
          name: "ComplexScopeFramework",
          control: [
            {
              name: "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN",
              scope: {
                compliance_resource_types: ["EBS", "RDS", "DynamoDB", "EFS"],
                tags: {
                  "Environment" => "production",
                  "DataTier" => "critical",
                  "BackupRequired" => "true"
                }
              }
            }
          ]
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:complex_scope]
      
      expect(framework[:name]).to eq("ComplexScopeFramework")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes framework with tags' do
      synthesizer.instance_eval do
        aws_backup_framework(:tagged_framework, {
          name: "TaggedFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ],
          tags: {
            Environment: "production",
            Purpose: "compliance",
            Owner: "security-team",
            CostCenter: "infrastructure"
          }
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:tagged_framework]
      
      expect(framework[:name]).to eq("TaggedFramework")
      expect(framework).to have_key(:tags)
    end
    
    it 'synthesizes production compliance framework' do
      synthesizer.instance_eval do
        aws_backup_framework(:prod_compliance, {
          name: "ProductionComplianceFramework",
          description: "Comprehensive compliance framework for production workloads",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "hours"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "12"
                }
              ],
              scope: {
                compliance_resource_types: ["EBS", "RDS"],
                tags: {
                  "Environment" => "production",
                  "Tier" => "critical"
                }
              }
            },
            {
              name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                },
                {
                  parameter_name: "requiredRetentionDays",
                  parameter_value: "90"
                }
              ]
            },
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            },
            {
              name: "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN",
              scope: {
                tags: {
                  "BackupRequired" => "true"
                }
              }
            }
          ],
          tags: {
            Environment: "production",
            Purpose: "compliance",
            Complexity: "comprehensive",
            Owner: "platform-team"
          }
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:prod_compliance]
      
      expect(framework[:name]).to eq("ProductionComplianceFramework")
      expect(framework[:description]).to include("Comprehensive compliance")
      expect(framework).to have_key(:control)
      expect(framework).to have_key(:tags)
    end
    
    it 'synthesizes database-focused framework' do
      synthesizer.instance_eval do
        aws_backup_framework(:database_framework, {
          name: "DatabaseProtectionFramework",
          description: "Framework focused on database backup compliance",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "hours"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "6"
                }
              ],
              scope: {
                compliance_resource_types: ["RDS", "DynamoDB"]
              }
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED",
              scope: {
                compliance_resource_types: ["RDS", "DynamoDB"]
              }
            },
            {
              name: "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN",
              scope: {
                compliance_resource_types: ["RDS", "DynamoDB"],
                tags: {
                  "DataTier" => "database"
                }
              }
            }
          ],
          tags: {
            Purpose: "database-protection",
            DataTier: "database",
            FrequencyTier: "high"
          }
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:database_framework]
      
      expect(framework[:name]).to eq("DatabaseProtectionFramework")
      expect(framework[:description]).to include("database")
      expect(framework).to have_key(:control)
    end
    
    it 'synthesizes development framework' do
      synthesizer.instance_eval do
        aws_backup_framework(:dev_framework, {
          name: "DevelopmentFramework",
          description: "Lightweight framework for development environments",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "7"
                }
              ],
              scope: {
                tags: {
                  "Environment" => "development"
                }
              }
            }
          ],
          tags: {
            Environment: "development",
            Purpose: "basic-protection",
            CostOptimized: "true"
          }
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:dev_framework]
      
      expect(framework[:name]).to eq("DevelopmentFramework")
      expect(framework[:description]).to include("development")
      expect(framework).to have_key(:control)
    end
    
    it 'handles empty tags gracefully' do
      synthesizer.instance_eval do
        aws_backup_framework(:no_tags, {
          name: "NoTagsFramework",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ],
          tags: {}
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:no_tags]
      
      expect(framework).not_to have_key(:tags)
    end
    
    it 'generates correct JSON for terraform' do
      synthesizer.instance_eval do
        aws_backup_framework(:json_test, {
          name: "JsonTestFramework",
          description: "Framework for JSON validation testing",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ],
          tags: {
            Name: "json-test-framework",
            Environment: "testing",
            Purpose: "validation"
          }
        })
      end
      
      json_output = JSON.pretty_generate(synthesizer.synthesis)
      parsed = JSON.parse(json_output, symbolize_names: true)
      
      framework = parsed[:resource][:aws_backup_framework][:json_test]
      expect(framework[:name]).to eq("JsonTestFramework")
      expect(framework[:description]).to include("JSON validation")
      expect(framework[:tags]).to be_a(Hash)
      expect(framework[:tags][:Environment]).to eq("testing")
    end
    
    it 'synthesizes framework with all supported controls' do
      synthesizer.instance_eval do
        aws_backup_framework(:all_controls, {
          name: "AllControlsFramework",
          description: "Framework with all supported AWS Backup controls",
          control: [
            {
              name: "BACKUP_RECOVERY_POINT_MINIMUM_FREQUENCY_AND_POINT_IN_TIME_RECOVERY",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "hours"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "24"
                }
              ]
            },
            {
              name: "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK",
              input_parameter: [
                {
                  parameter_name: "requiredRetentionDays",
                  parameter_value: "30"
                }
              ]
            },
            {
              name: "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            },
            {
              name: "BACKUP_LAST_RECOVERY_POINT_CREATED",
              input_parameter: [
                {
                  parameter_name: "requiredFrequencyUnit",
                  parameter_value: "days"
                },
                {
                  parameter_name: "requiredFrequencyValue",
                  parameter_value: "1"
                }
              ]
            },
            {
              name: "BACKUP_RESOURCES_PROTECTED_BY_BACKUP_PLAN"
            },
            {
              name: "BACKUP_RECOVERY_POINT_ENCRYPTED"
            }
          ],
          tags: {
            Purpose: "comprehensive-testing",
            ControlCount: "all-supported",
            TestCase: "maximum-coverage"
          }
        })
      end
      
      result = synthesizer.synthesis
      framework = result[:resource][:aws_backup_framework][:all_controls]
      
      expect(framework[:name]).to eq("AllControlsFramework")
      expect(framework[:description]).to include("all supported")
      expect(framework).to have_key(:control)
      expect(framework).to have_key(:tags)
    end
  end
end