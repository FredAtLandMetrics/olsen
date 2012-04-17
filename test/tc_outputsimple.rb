$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift ENV["GEM_HOME"]

require "test/unit"
require "sadie"
require "olsen"
require "tmpdir"

class TestSimpleOutput < Test::Unit::TestCase
    def test_simple
        ofdir = "test/olsen_framework_test"
        
        Dir.mktmpdir("olsen_testdir") do | dir |
        
            # create temp output and sessdirs
            outputdir = File.join( dir, "output" )
            Dir.mkdir outputdir
            sessdir = File.join( dir, "session" )
            Dir.mkdir sessdir
            
            s = Olsen::initSadie( "sadie.primers_dirpath" => "#{ofdir}/primers",
                                  "sadie.sessions_dirpath" => sessdir,
                                  "olsen.output_dirpath" => outputdir  )

            # --------------- test 1: simple ---------------
            # process some olsenry
            output = nil
            Olsen::process( File.join( ofdir, "jobs/outputtest_simple.job" ),s  ) do |sadie|
            
            
                # test
                output_path = sadie.get( "output.outputtest_simple.txt" )
                output = File.open( output_path, "r" ) { |f| f.read }
            end
            assert_equal( output, "item1: item txt 1\nitem2: item txt 2\n"    )

            # --------------- test 2: filter ---------------
            # process some olsenry
            Olsen::process( File.join( ofdir, "jobs/outputtest_filter.job" ),s ) do |sadie|
            
                # test
                output_path = sadie.get( "output.outputtest_filter.txt" )
                output = File.open( output_path, "r" ) { |f| f.read }
            end
            assert_equal( output, "item1: item txt 1\nitem2: item txt 2\nitem3: [item txt 1]\nitem4: {[[item txt 2]]}\n"    )
            
        end
    end
end