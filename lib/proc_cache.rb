require File.dirname(__FILE__) + "/proc_cache/store"
Dir.foreach(File.dirname(__FILE__) + "/proc_cache/store_method") do |file|
  require File.dirname(__FILE__) + "/proc_cache/store_method/#{file}" if file =~ /\.rb$/
end

module ProcCache
  
	def proc_cache(key, *args, &block)
	  self.store_method ||= ProcCache.store_method || ProcCache::StoreMethod::Instance
	  
	  expiration_condition, cached_args = parse_args(args)
    cached_proc = self.get_proc_cache(key)
  	cached_proc = ProcCache::Store.new(expiration_condition) if !cached_proc || cached_proc.expired?(cached_args)
  	value = cached_proc.get(cached_args, block)
  	set_proc_cache(key, cached_proc)
  	return value
  end
  
  # def proc_caches
  #   @@__proc_cache
  # end
  
  def proc_cached?(key)
    !get_proc_cache(key).nil?
  end
  
  
  # Allow user to define where and how procs are cached per instance use
	def store_method
    @__proc_store_method
  end
  
  def store_method=(mod)
    @__proc_store_method = mod
    self.extend(mod)
  end
  
  def proc_uncache(key)
	  delete_proc_cache(key)
  end
  
  # Allow user to define where and how procs are cached globally / by default
  @@store_method = nil
  
  def self.store_method
    @@store_method
  end
  
  def self.store_method=(mod)
    @@store_method = mod
    self.extend(mod)
  end
  
  private
  
  def parse_args(args)
    condition = nil
    condition = args.shift if ProcCache::Store.valid_condition?(args[0])
    return condition, args
  end
	
end
