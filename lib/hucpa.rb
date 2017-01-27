Dir[File.expand_path("..", __FILE__) + "/*.jar"].each { |f| require f }

require "hucpa/configuration"
require "hucpa/connection_pool"

module Hucpa
end
