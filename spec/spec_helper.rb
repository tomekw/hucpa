$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hucpa"

RSpec.configure do |config|
  config.order = :random
end
