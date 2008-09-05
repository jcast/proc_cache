module ProcCache
  class Store
  
    def initialize(exp_condition=nil)
      @caches = {}
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
  
    def get(arg_pattern, block)
      @last_arg_pattern = arg_pattern
      @caches[arg_pattern] ||= block.call
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
  
    def expire_at_proc(exp_time)
      proc{ Time.now > exp_time }
    end
  
  end
end