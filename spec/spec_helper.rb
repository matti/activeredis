# Use this to configure various configurable aspects of
# RSpec:
#
  Spec::Runner.configure do |config|
    # Configure RSpec here
    
    config.before(:each) do
      ActiveRedis::Base.connection.call_command [:flushall]
    end
  end
#
# The yielded <tt>configuration</tt> object is a
# Spec::Runner::Configuration instance. See its RDoc
# for details about what you can do with it.
#
