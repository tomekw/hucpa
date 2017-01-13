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

        if !adapter.empty?
          config.data_source_class_name = ADAPTERS.fetch(adapter)
        elsif !jdbc_url.empty?
          config.jdbc_url = jdbc_url
        end

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
                :"adapter/jdbc_url options" => "are invalid. Either adapter or jdbc_url has to be provided"
              }
            }
          )
        end
      end

      required(:password).value(:str?)
      required(:username).value(:str?)

      optional(:adapter).value(included_in?: ADAPTERS.keys)
      optional(:jdbc_url).value(:str?)

      optional(:database_name).value(:str?)
      optional(:server_name).value(:str?)

      rule(:"adapter/jdbc_url options" => %i[adapter jdbc_url]) do |adapter, jdbc_url|
        adapter.filled? ^ jdbc_url.filled?
      end
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
