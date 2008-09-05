require File.dirname(__FILE__) + "/proc_cache/store"
require File.dirname(__FILE__) + "/proc_cache/store_method"

module ProcCache
  
	def proc_cache(key, *args, &block)
	  expiration_condition, cached_args = parse_args(args)
    cached_proc = store_method[:get].call(key)
  	cached_proc = ProcCache::Store.new(expiration_condition) if !cached_proc || cached_proc.expired?(cached_args)
  	value = cached_proc.get(cached_args, block)
  	store_method[:set].call(key, cached_proc)
  	return value
  end
  
  # def proc_caches
  #   @@__proc_cache
  # end
  
  def proc_cached?(key)
    !store_method[:get].call(key).nil?
  end
  
  
  # Allow user to define where and how procs are cached per instance use
	def store_method
    @__proc_store_method ||= ProcCache.store_method || ProcCache::StoreMethod.instance(self)
  end
  
  def store_method=(hash)
    @__proc_store_method = hash
  end
  
  def proc_uncache(key)
	  store_method[:delete].call(key)
  end
  
  # Allow user to define where and how procs are cached globally / by default
  @@store_method = nil
  
  def self.store_method
    @@store_method
  end

  def self.set_method(*args, &block)
    @@store_method[:set] = block if block_given?
  end

  def self.get_method(*args, &block)
    @@store_method[:get] = block if block_given?
  end
  
  def self.delete_method(*args, &block)
    @@store_method[:delete] = block if block_given?
  end
  
  private
  
  def parse_args(args)
    condition = nil
    condition = args.shift if ProcCache::Store.valid_condition?(args[0])
    return condition, args
  end
	
end
