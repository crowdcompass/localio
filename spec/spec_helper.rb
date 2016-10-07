require 'bundler/setup'
require 'pry'
Bundler.setup

require 'localio'

RSpec.configure do |config|

end

# Localio is very verbose and it gets annoying in test runs :)
def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
