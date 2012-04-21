require 'pp'
require 'olsen/version'

def O( key, params=nil )
    
    instance = Sadie::getCurrentSadieInstance

    if ! defined? instance 
        puts "err: getCurrentSadieInstance returned nil"
        return nil
    end
      
    if defined? params
        if params.respond_to? "has_key?"
            if params.has_key? :filter
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
    instance.get( key )
    
end

class Olsen
    
    def self.filter( value, filters )
        
        # validate filters
        defined? filters \
            or return value
        filters.respond_to? "each" \
            or return value
        
        sadie = Sadie::getCurrentSadieInstance
        
        fhnd = "filter.#{filters[0]}"
        puts "fetching filter: #{fhnd}"
        
        sadie.isset? fhnd \
            or raise "olsen error: filter(#{fhnd}) does not exist"
        f = sadie.get fhnd
        
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
    
    def self.initFramework
        if ! defined? @@framework_dirpath
            puts "framework dirpath not set...aborting."
            return nil
        end        
        puts "initializing olsen framework in #{@@framework_dirpath}"
        [ "output", "jobs", "primers" ].each do |dir|
            Dir.mkdir File.join( @@framework_dirpath, dir )
        end
    end
    
    def self.setFrameworkDir( dirpath )
        @@framework_dirpath = dirpath
    end
    
    def self.registerFilter( name, &block )
        puts "registering filter: #{name}"
        instance = Sadie::getCurrentSadieInstance
        instance.set "filter.#{name}", block
    end
    
    def self.initSadie( params )
        sadieparams = {
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
        storage = Sadie::getSadieInstance( sadieparams )
        
        # add olsen plugin handlers
        plugins_dirpath = File.join(
            ENV['GEM_HOME'],
            "gems/olsen-#{Olsen::VERSION}",
            "lib/olsen/primer_plugins"
        )
        if ! File.exists? plugins_dirpath   # for dev
            plugins_dirpath = File.expand_path "lib/olsen/primer_plugins"
        end        
        if ! File.exists? plugins_dirpath   # for dev
            plugins_dirpath = File.join "/home/fred/Source/LMSys/olsen", "lib/olsen/primer_plugins"
        end        
        storage.addPrimerPluginsDirPath plugins_dirpath
        storage.initializePrimers
    end
    
    def self.process( job, storage )
        
        if ( ! defined?( job ) )
            puts "job parameter was undefined.  must be hash or file.  returning nil."
            return nil
        end
        
        # turn files into hashes
        if ! job.respond_to? "each"
            if File.exists? job
                job = Sadie::iniFileToHash( job )
            elsif defined? @@framework_dirpath
                jobdirpath = File.join( @@framework_dirpath, "jobs" )
                jobfile = File.join jobdirpath, "#{job}.job" 
                if File.exists? jobfile
                    job = Sadie::iniFileToHash( jobfile )
                end
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
                
        # call output triggers
        storage = Sadie::getCurrentSadieInstance
        job["output"].each do |x,type|
            outputkey = "output.#{type}"
            puts "processing output trigger: #{outputkey}"
            storage.output outputkey
        end
        
        if block_given?
            yield storage
        end
        
    end

#     def registerFilter( filter, &block )
#         defined? @filters \
#             or @filters = Hash.new
#         
#         @filters["filter"] = block
#     end
    
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