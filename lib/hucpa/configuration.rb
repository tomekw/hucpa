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
      derby: "org.apache.derby.jdbc.ClientDataSource",
      firebird: "org.firebirdsql.pool.FBSimpleDataSource",
      db2: "com.ibm.db2.jcc.DB2SimpleDataSource",
      h2: "org.h2.jdbcx.JdbcDataSource",
      hsqldb: "org.hsqldb.jdbc.JDBCDataSource",
      mariadb: "org.mariadb.jdbc.MySQLDataSource",
      mysql: "com.mysql.jdbc.jdbc2.optional.MysqlDataSource",
      sqlserver_jtds: "net.sourceforge.jtds.jdbcx.JtdsDataSource",
      sqlserver: "com.microsoft.sqlserver.jdbc.SQLServerDataSource",
      oracle: "oracle.jdbc.pool.OracleDataSource",
      pgjdbc_ng: "com.impossibl.postgres.jdbc.PGDataSource",
      postgresql: "org.postgresql.ds.PGSimpleDataSource",
      fdbsql: "com.foundationdb.sql.jdbc.ds.FDBSimpleDataSource",
      sybase: "com.sybase.jdbcx.SybDataSource",
      sqlite: "org.sqlite.JDBC"
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
