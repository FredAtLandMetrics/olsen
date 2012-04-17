Sadie::registerPrimerPlugin( { "match" => /\.filter.rb$/,
                               "accepts-block" => false,
                               "prime-on-init" => false } ) do |sadie, key_prefix, primer_file_filepath|
    
    # basically, just loading a ruby file
    load primer_file_filepath
    
#     primer_file_basename = File.basename( primer_file_filepath )
#     output_filename = primer_file_basename
#     output_filename.gsub(/\.erb$/,"")
#     sadie_key = key_prefix + '.' + primer_file_basename
#     sadie_key = sadie_key.gsub(/^\./,"")
#     sadie_key = sadie_key.gsub(/\.erb$/,"")
#     Sadie::prime( { "provides" => sadie_key } ) do |sadie|
#         
#         # run erb
#         input_contents = File.open(primer_file_filepath, 'r') { |f| f.read }
#         template = ERB.new( input_contents )
#         output_contents = template.result
#         
#         # write results to output file
#         output_dirpath = sadie.get "olsen.output_dirpath"
#         File.open( File.join(output_dirpath,output_filename), "w" ) do |f|
#             f.print output_contents
#         end
#         
#         # set output filepath to sadie_key
#         sadie.set( sadie_key, File.join(output_dirpath,output_filename) )
#     end
end