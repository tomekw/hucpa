require "dry-validation"

module Hucpa
  class Configuration
    java_import com.zaxxer.hikari.HikariConfig

    def initialize(options)
      @options = options
    end

    def to_hikari_config
      fail ArgumentError, validation_errors if validation.failure?

      HikariConfiguration.new.tap do |config|
        CONFIGURATION_OPTIONS.each do |option|
          option_setter = "#{option}="
          option_value = send(option)

          if config.respond_to?(option_setter) && !option_value.nil?
            config.public_send(option_setter, option_value)
          end
        end
      end
    end

    private

    attr_reader :options

    ADAPTERS = {
      db2: "com.ibm.db2.jcc.DB2SimpleDataSource",
      derby: "org.apache.derby.jdbc.ClientDataSource",
      fdbsql: "com.foundationdb.sql.jdbc.ds.FDBSimpleDataSource",
      firebird: "org.firebirdsql.pool.FBSimpleDataSource",
      h2: "org.h2.jdbcx.JdbcDataSource",
      hsqldb: "org.hsqldb.jdbc.JDBCDataSource",
      mariadb: "org.mariadb.jdbc.MySQLDataSource",
      mysql: "com.mysql.jdbc.jdbc2.optional.MysqlDataSource",
      oracle: "oracle.jdbc.pool.OracleDataSource",
      pgjdbc_ng: "com.impossibl.postgres.jdbc.PGDataSource",
      postgresql: "org.postgresql.ds.PGSimpleDataSource",
      sqlite: "org.sqlite.JDBC",
      sqlserver: "com.microsoft.sqlserver.jdbc.SQLServerDataSource",
      sqlserver_jtds: "net.sourceforge.jtds.jdbcx.JtdsDataSource",
      sybase: "com.sybase.jdbcx.SybDataSource"
    }.freeze
    private_constant :ADAPTERS

    VALIDATION_SCHEMA = Dry::Validation.Schema do
      configure do
        def self.messages
          super.merge(
            en: {
              errors: {
                "adapter/jdbc_url options": "are invalid. Either adapter or jdbc_url must be filled"
              }
            }
          )
        end
      end

      required(:password).filled(:str?)
      required(:username).filled(:str?)

      optional(:adapter).filled(included_in?: ADAPTERS.keys)
      optional(:jdbc_url).filled(:str?)

      optional(:auto_commit).filled(:bool?)
      optional(:connection_test_query).filled(:str?)
      optional(:connection_timeout).filled(:int?, gteq?: 250)
      optional(:database_name).filled(:str?)
      optional(:idle_timeout).filled { int? & (eql?(0) | gteq?(10_000)) }
      optional(:max_lifetime).filled { int? & (eql?(0) | gteq?(30_000)) }
      optional(:maximum_pool_size).filled(:int?, gteq?: 1)
      optional(:minimum_idle).filled(:int?, gteq?: 1)
      optional(:pool_name).filled(:str?)
      optional(:server_name).filled(:str?)

      rule("adapter/jdbc_url options": %i[adapter jdbc_url]) do |adapter, jdbc_url|
        adapter.filled? ^ jdbc_url.filled?
      end
    end
    private_constant :VALIDATION_SCHEMA

    CONFIGURATION_OPTIONS = VALIDATION_SCHEMA.rules.keys
    private_constant :CONFIGURATION_OPTIONS

    class HikariConfiguration < HikariConfig
      def adapter=(value)
        self.data_source_class_name = ADAPTERS.fetch(value)
      end

      def database_name=(value)
        self.data_source_properties["databaseName"] = value
      end

      def server_name=(value)
        self.data_source_properties["serverName"] = value
      end
    end
    private_constant :HikariConfiguration

    CONFIGURATION_OPTIONS.each do |param|
      define_method(param) do
        options.fetch(param, nil)
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
