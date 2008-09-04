require 'spec'
require File.join(File.dirname(__FILE__), "..", "lib", "proc_cache")

class TestObj
  include ProcCache
  
  def with_args(*args)
    set_start_time
    proc_cache(:test_long, *args) do
      sleep(1)
      args
    end
  end
  
  def with_expiration(*args)
    set_start_time
    proc_cache(:test_long, :lifespan => 5) do
      sleep(1)
      args
    end
  end
  
  def with_args_and_expiration(*args)
    set_start_time
    proc_cache(:test_long, :lifespan => 5, *args) do
      sleep(1)
      args
    end
  end
  
  def with_custom_expiration(block, *args)
    set_start_time
    proc_cache(:test_long, block, *args) do
      sleep(1)
      args
    end
  end
  
  def time_diff
    (Time.now - @start_time).to_i
  end
  
  private
  
  def set_start_time
    @start_time = Time.now
  end
  
end
