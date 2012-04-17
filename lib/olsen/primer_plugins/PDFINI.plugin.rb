require 'pp'
Sadie::registerPrimerPlugin( {  "match" => /\.pdf\.ini$/,
                                "accepts-block" => false,
                                "prime-on-init" => true } ) do |sadie, key_prefix, primer_file_filepath|
    
    puts "processing pdf ini file: #{primer_file_filepath}"
    
    ini_file_basename = File.basename primer_file_filepath
    ini_file_root = ini_file_basename.gsub( /\.pdf\.ini$/, "" )
    
    output_filename = "#{ini_file_root}.pdf"
    
    sadie_key = "output.#{output_filename}"
    
    if pdfparams = Sadie::iniFileToHash( primer_file_filepath )
        
        # validate pdfparams
        if ! defined? pdfparams
            puts "iniFileToHash returned nil...aborting"
            return nil
        end
        
        if ! pdfparams.respond_to? "has_key?"
            puts "initFileToHash returned unusable param set...aborting"
            return nil
        end
        
        if pdfparams.has_key? "pdf"
            secpdf = pdfparams["pdf"]
            if secpdf.respond_to? "has_key?"
                if secpdf.has_key? "type"
                    case secpdf["type"]
                    when "latexmk"
                        
                        # determine bin to latexmk
                        cmd = "/usr/bin/latexmk"
                        template = "output.#{ini_file_root}.tex"
                        if pdfparams.has_key? "latexmk"
                            
                            latexmkparams = pdfparams["latexmk"]
                            if latexmkparams.has_key? "path_to_latexmk"
                                if "#{latexmkparams['path_to_latexmk']}" !~ /^\s*$/
                                    cmd = latexmkparams['path_to_latexmk']
                                end
                            end
                            if latexmkparams.has_key? "template"
                                if "#{latexmkparams['template']}" !~ /^\s*$/
                                    template = latexmkparams['template']
                                end
                            end
                        end
                        
                        Sadie::prime( { "provides" => [ sadie_key ] } ) do |sadie|
                            
                            # gen output
                            template_filepath = sadie.get( template )
                            dirpath = File.dirname template_filepath
                            puts "dirpath: #{dirpath}"
                            filepath = File.basename template_filepath
                            system "cd #{dirpath}; #{cmd} -f -pdf #{filepath};"
                            
                            outpath = File.join dirpath, output_filename 
                            
                            puts "setting s[#{sadie_key}]: #{outpath}"
                            sadie.set sadie_key, outpath
                            
                        end
                    else
                        puts "unsupported pdf type: #{secpdf['type']}"
                        return nil
                    end
                end
            end
        end
    end    
    
end