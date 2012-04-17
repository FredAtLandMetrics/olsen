require 'pp'

def O( key, params=nil )
    
    instance = Sadie::getCurrentSadieInstance

    if ! defined? instance 
        puts "err: getCurrentSadieInstance returned nil"
        return nil
    end
      
    if defined? params
        if params.respond_to? "has_key?"
            if params.has_key? :filter
#                 puts "got filter!!!"
                filter = params[:filter]
                if filter.respond_to? "each"
                    ret = Olsen::filter instance.get( key ), filter
                    return ret
                else
                    ret = Olsen::filter instance.get( key ), [filter]
                    return ret
                end
            end
        end
    end
#     puts "O(#{key}): NO PARAMS?"
    instance.get( key )
    
end

class Olsen
    
    def self.filter( value, filters )
        
#         puts "filters: #{filters}"
        
        # validate filters
        defined? filters \
            or return value
        filters.respond_to? "each" \
            or return value
        
        instance = Sadie::getCurrentSadieInstance
        
        #pp(instance)
        
        fhnd = "filter.#{filters[0]}"
        f = instance.get fhnd
        
#         puts "f(#{fhnd}): #{f}"
        
        if filters.length > 1
            rem = filters[1..(filters.length-1)]
            ret = f.call value
            ret = Olsen.filter f.call(ret), rem
            return ret
        else
            ret = f.call value
            return ret
        end
    end
    
    def self.registerFilter( name, &block )
        instance = Sadie::getCurrentSadieInstance
        instance.set "filter.#{name}", block
#         if ! defined? @@filters
#             @@filters = { name => block }
#         else
#             @@filters[name] = block
#         end
    end
    
    def self.initSadie( params )
        sadieparams = {
            "sadie.primer_plugins_dirpath" => "lib/olsen/primer_plugins",
            "sadie.primers_dirpath" => "primers"
        }
        
        # if session and output dirs not defined, create temp dirs and use them
        if ! sadieparams.has_key? "sadie.sessions_dirpath"
            Dir.mktmpdir("olsen_tmp_sess") do | dir |
                sadieparams["sadie.sessions_dirpath"] =  dir
            end
        end
        if ! sadieparams.has_key? "olsen.output_dirpath"
            Dir.mktmpdir("olsen_output") do | dir |
                sadieparams["olsen.output_dirpath"] =  dir
            end
        end

        # process params
        if defined? params
            if params.respond_to? "each"
                params.each do |k,v|
                    sadieparams[k] = v
                end
            end
        end
        
        # init sadie
#         puts "init storage!"
        storage = Sadie::getSadieInstance( sadieparams )
        
        
    end
    
    def self.process( job, storage )
        
        if ( ! defined?( job ) )
            puts "job parameter was undefined.  must be hash or file.  returning nil."
            return nil
        end
        
        if ! job.respond_to? "each"
            if File.exists? job
                job = Sadie::iniFileToHash( job )
            else
                puts "job param was non-hash and was not a path to valid job file"
                return nil
            end
        end
        
        # validate job
        if ! job.has_key? "output"
            puts "job has no output definition"
            return nil
        end
        
#         sadieparams = {
#             "sadie.primer_plugins_dirpath" => "lib/olsen/primer_plugins",
#             "sadie.primers_dirpath" => "primers"
#         }
        
        # set keys from job
#         [ "sadie", "parameters","olsen" ].each do |ptype|
#             if job.has_key? ptype 
#                 job[ptype].each do |key,value|
#                     if ptype.eql? "sadie"
#                         sadieparams["sadie.#{key}"] = value
#                     else
#                         sadieparams["#{key}"] = value
#                     end
#                 end
#             end
#         end
        

        
        
        # call output triggers
        job["output"].each do |x,type|
            outputkey = "output.#{type}"
            puts "processing output trigger: #{outputkey}"
            storage.output outputkey
        end
        
        if block_given?
            yield storage
        end
        
    end

    def registerFilter( filter, &block )
        defined? @filters \
            or @filters = Hash.new
        
        @filters["filter"] = block
    end
    
    def filter( filter_name, value )
        defined? @filters \
            or return nil
        @filters.respond_to? "has_key?" \
            or return nil
        @filters.has_key? filter_name \
            or return nil
        f = @filters[filter_name]
        f.call value
    end
    
end