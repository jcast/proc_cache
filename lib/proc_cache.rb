module ProcCache
  
	def proc_cache(key, *args, &block)
	  @__proc_cache ||= {}
	  expiration_condition, cached_args = parse_args(args)
  	if !@__proc_cache[key] || @__proc_cache[key].expired?(cached_args)
  	  @__proc_cache[key] = ProcCache::Store.new(key, expiration_condition)
  	  @__proc_cache[key].extend(store_method) if store_method
	  end
  	value = @__proc_cache[key].get(cached_args) || @__proc_cache[key].set(cached_args, block.call)
  	return value
  end
  
  def proc_cached?(key)
    !@__proc_cache[key].nil?
  end
  
  def proc_cache_keys
    @__proc_cache.keys
  end
  
  # Allow user to define where and how procs are cached per instance use
	def store_method
    @__proc_store_method || nil
  end
  
  def store_method=(mod)
    mod = ProcCache.load_store_method(mod)
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
    mod = load_store_method(mod)
    @@store_method = mod
    self.extend(mod)
  end
  
  def self.load_store_method(mod)
    return mod if mod.is_a? Module
    
    mod = mod.to_s.split("_").collect{|i|i.capitalize!}.join
    return const_get(mod) if const_defined?(mod)
    
    file_basename = mod.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
    file_path = File.dirname(__FILE__) + "/proc_cache/store_method/#{file_basename}.rb"
    require file_path if File.exist?(file_path)
    
    return StoreMethod.const_get(mod) if StoreMethod.const_defined?(mod)
  end
  
  private
  
  def parse_args(args)
    condition = nil
    condition = args.shift if ProcCache::Store.valid_condition?(args[0])
    return condition, args
  end
	
end

class ProcCacheException < Exception; end
require File.dirname(__FILE__) + "/proc_cache/store"
