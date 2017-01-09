require "dry-validation"

import com.zaxxer.hikari.HikariConfig

module Hucpa
  class Configuration
    def initialize(options)
      @options = options
    end

    def to_hikari_config
      raise ArgumentError.new(validation_errors) if validation.failure?

      HikariConfig.new.tap do |config|
        config.data_source_class_name = ADAPTERS.fetch(adapter)
        config.password = password
        config.username = username

        if !database_name.empty?
          config.data_source_properties["databaseName"] = database_name
        end

        if !server_name.empty?
          config.data_source_properties["serverName"] = server_name
        end
      end
    end

    private

    attr_reader :options

    ADAPTERS = {
      postgresql: "org.postgresql.ds.PGSimpleDataSource"
    }
    private_constant :ADAPTERS

    VALIDATION_SCHEMA = Dry::Validation.Schema do
      required(:adapter).value(included_in?: ADAPTERS.keys)
      required(:password).value(:str?)
      required(:username).value(:str?)

      optional(:database_name).value(:str?)
      optional(:server_name).value(:str?)
    end
    private_constant :VALIDATION_SCHEMA

    NO_VALUE = Class.new do
      def empty?
        true
      end

      def nil?
        true
      end
    end.new
    private_constant :NO_VALUE

    VALIDATION_SCHEMA.rules.keys.each do |param|
      define_method(param) do
        options.fetch(param, NO_VALUE)
      end
    end

    def validation
      @validation ||= VALIDATION_SCHEMA.call(options)
    end

    def validation_errors
      validation.messages(full: true).values.flatten.join(", ")
    end
  end
end
