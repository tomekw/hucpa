import com.zaxxer.hikari.HikariDataSource

module Hucpa
  class ConnectionPool
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

    private

    attr_reader :hikari_config, :options

    def datasource
      @datasource ||= HikariDataSource.new(hikari_config)
    end
  end
end
