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
        config.password = password
        config.username = username

        if !adapter.nil?
          config.data_source_class_name = data_source_class_name
        end

        if !jdbc_url.nil?
          config.jdbc_url = jdbc_url
        end

        if !auto_commit.nil?
          config.auto_commit = auto_commit
        end

        if !connection_test_query.nil?
          config.connection_test_query = connection_test_query
        end

        if !connection_timeout.nil?
          config.connection_timeout = connection_timeout
        end

        if !idle_timeout.nil?
          config.idle_timeout = idle_timeout
        end

        if !max_lifetime.nil?
          config.max_lifetime = max_lifetime
        end

        if !maximum_pool_size.nil?
          config.maximum_pool_size = maximum_pool_size
        end

        if !minimum_idle.nil?
          config.minimum_idle = minimum_idle
        end

        if !pool_name.nil?
          config.pool_name = pool_name
        end

        if !database_name.nil?
          config.data_source_properties["databaseName"] = database_name
        end

        if !server_name.nil?
          config.data_source_properties["serverName"] = server_name
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
    }
    private_constant :ADAPTERS

    VALIDATION_SCHEMA = Dry::Validation.Schema do
      configure do
        def self.messages
          super.merge(
            en: {
              errors: {
                :"adapter/jdbc_url options" => "are invalid. Either adapter or jdbc_url must be filled"
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
      optional(:max_lifetime).filled(:int?, gteq?: 0)
      optional(:maximum_pool_size).filled(:int?, gteq?: 1)
      optional(:minimum_idle).filled(:int?, gteq?: 1)
      optional(:pool_name).filled(:str?)
      optional(:server_name).filled(:str?)

      rule(:"adapter/jdbc_url options" => %i[adapter jdbc_url]) do |adapter, jdbc_url|
        adapter.filled? ^ jdbc_url.filled?
      end
    end
    private_constant :VALIDATION_SCHEMA

    VALIDATION_SCHEMA.rules.keys.each do |param|
      define_method(param) do
        options.fetch(param, nil)
      end
    end

    def data_source_class_name
      ADAPTERS.fetch(adapter)
    end

    def validation
      @validation ||= VALIDATION_SCHEMA.call(options)
    end

    def validation_errors
      validation.messages(full: true).values.flatten.join(", ")
    end
  end
end
