require 'erb'
Sadie::registerPrimerPlugin( { "match" => /\.erb$/,
                               "accepts-block" => false,
                               "prime-on-init" => false } ) do |sadie, key_prefix, primer_file_filepath|
    
    
    # determine output filename
    output_filename = File.basename( primer_file_filepath )
    output_filename = output_filename.gsub(/\.erb$/,"")
    
    # determine sadie key
    sadie_key = "#{key_prefix}.#{output_filename}"
    #puts "priming with primer file: #{primer_file_filepath}, sadie key: #{sadie_key}"
    
    Sadie::prime( { "provides" => [ sadie_key ] } ) do |sadie|
        
        output_contents = Sadie::templatedFileToString( primer_file_filepath )
        
        # write results to output file
        output_dirpath = sadie.get "olsen.output_dirpath"
        output_filepath = File.join(output_dirpath,output_filename)
        File.open( output_filepath, "w" ) do |f|
            f.print output_contents
#             puts "contents: #{output_contents}"
        end
        
        # set a sadie key/val for output file path
        puts "setting erb output key: #{sadie_key} to value: #{output_filepath}"
        sadie.set( sadie_key, output_filepath )
    end
    
end