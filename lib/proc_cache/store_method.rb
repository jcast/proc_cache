module ProcCache
  module StoreMethod
  
    class << self
    
      def instance(inst)
        {
          :get => proc{ |key| inst.instance_variable_set("@__proc_cache", {}) if !inst.instance_variable_defined?("@__proc_cache")
                              inst.instance_variable_get("@__proc_cache")[key] },
          :set => proc{ |key, value| inst.instance_variable_set("@__proc_cache", {}) if !inst.instance_variable_defined?("@__proc_cache")
                              inst.instance_variable_get("@__proc_cache")[key] = value },
          :delete => proc{ |key| inst.instance_variable_get("@__proc_cache").delete(key) if inst.instance_variable_defined?("@__proc_cache") }
        }
      end
    
    end
  
  end
end