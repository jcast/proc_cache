require "digest/md5"
require File.dirname(__FILE__) + "/store_method/instance"

module ProcCache
  class Store
    
    include ProcCache::StoreMethod::Instance
    
    attr_accessor :keys
    
    def initialize(name, exp_condition=nil)
      @name = name
      @keys = {}
      @expired = false
      @last_arg_pattern = []
      
      @expire_condition = case exp_condition
      when Proc
        exp_condition
      when Hash
        expire_at_proc( exp_condition[:expires_at] || Time.now + exp_condition[:lifespan] )
      else
        proc{false}
      end
    end
    
    def get(arg_pattern)
      @last_arg_pattern = arg_pattern
      record_key = @keys[arg_pattern] || get_record_key(arg_pattern)
      get_proc_cache(record_key)
    end
    
    def set(arg_pattern, value)
      @last_arg_pattern = arg_pattern
      record_key = @keys[arg_pattern] || get_record_key(arg_pattern)
      set_proc_cache(record_key, value)
    end
    
    def expired?(arg_pattern=@last_arg_pattern)
      return true if @expired
      args = @expire_condition.arity < 0 ? arg_pattern : arg_pattern[0..@expire_condition.arity-1]
      @expired = @expire_condition.call( *args )
    end
    
    def self.valid_condition?(arg)
      return true if arg.is_a?(Proc)
      return arg.is_a?(Hash) && ( arg.has_key?(:lifespan) || arg.has_key?(:expires_at) )
    end
    
    private
    
    def get_record_key(obj)
      @keys[obj] = make_checksum([@name, obj])
    end
    
    def make_checksum(obj)
      d = Digest::MD5.new
      d << Marshal.dump(obj)
      d.hexdigest
    end
    
    def expire_at_proc(exp_time)
      proc{ Time.now > exp_time }
    end
    
  end
end