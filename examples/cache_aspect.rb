class A
  def test
    puts 'test'
    1
  end
end

##############################

class SimpleCache
  @data = {}

  def self.cache key, ttl
    found = @data[key]  # found is like [time, value]

    if found
      insertion_time, value = *found

      if insertion_time < Time.now - ttl
        found = nil
      end
    end

    if found
      value
    else
      value = yield
      @data[key] = [Time.now, value]
      value
    end
  end
end


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspector'

class CacheAspect < Aspector::Base
  around deferred_option(:method), :context_arg => true do |context, &block|
    SimpleCache.cache 'test', context.options[:ttl] do
      block.call
    end
  end
end

CacheAspect.apply A, :method => :test, :ttl => 2 # 2 seconds

##############################

a = A.new
a.test
a.test
sleep 3
a.test
