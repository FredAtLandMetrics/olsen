$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift ENV["GEM_HOME"]

require "test/unit"
require "sadie"
require "olsen"
require "tmpdir"

class TestPDFOutput < Test::Unit::TestCase
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

            # --------------- test pdf ---------------
            # process some olsenry
            output = nil
            Olsen::process( File.join( ofdir, "jobs/outputtest_pdf.job" ),s  ) do |sadie|
            
            
                # test
                output_path = sadie.get( "output.outputtest_pdf.pdf" )
                output = File.exists? output_path
            end
            assert_equal( output, true   )

        end
    end
end