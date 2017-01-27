module Hucpa
  class ConnectionPool
    java_import com.zaxxer.hikari.HikariDataSource

    def initialize(options)
      @options = options
      @hikari_config = Configuration.new(options).to_hikari_config
    end

    def open
      datasource
    end

    def close
      datasource.close
    end

    def with_connection
      conn = datasource.connection

      yield conn
    ensure
      conn.close
    end

    private

    attr_reader :hikari_config, :options

    def datasource
      @datasource ||= HikariDataSource.new(hikari_config)
    end
  end
end
