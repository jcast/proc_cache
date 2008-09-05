module ProcCache::StoreMethod
  module Instance
  
    def get_proc_cache(key)
      @__proc_cache ||= {}
      @__proc_cache[key]
    end
    
    def set_proc_cache(key, value)
      @__proc_cache ||= {}
      @__proc_cache[key] = value
    end
    
    def delete_proc_cache(key)
      @__proc_cache.delete(key)
    end
    
  end
end