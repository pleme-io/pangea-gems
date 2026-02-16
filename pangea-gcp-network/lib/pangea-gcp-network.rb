# frozen_string_literal: true

require_relative "pangea-gcp-network/version"

Dir[File.join(__dir__, "pangea-gcp-network", "resources", "*.rb")].each { |file| require file }

module PangeaGcpNetwork
  class Error < StandardError; end
end