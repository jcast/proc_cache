module ProcCache::StoreMethod
  module Instance
    
    @__proc_cache_store = {}
    
    def get_proc_cache(key)
      @__proc_cache_store ||= {}
      @__proc_cache_store[key]
    end
    
    def set_proc_cache(key, value)
      @__proc_cache_store ||= {}
      @__proc_cache_store[key] = value
    end
    
    def delete_proc_cache(key)
      @__proc_cache_store.delete(key)
    end
    
  end
end