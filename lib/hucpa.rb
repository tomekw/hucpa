Dir["vendor/*"].each { |f| require File.join(Dir.pwd, f) }

require "hucpa/connection_pool"

module Hucpa
end
