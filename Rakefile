require "bundler/gem_tasks"

require 'rake'
require 'rdoc/task'

task :test do
    ruby "test/tc_outputsimple.rb"
    ruby "test/tc_outputpdf.rb"
end

task :deploy => 'inc_version' do
    version = current_olsen_version
    sh "git push"
    sh "gem build olsen.gemspec"
    sh "gem push olsen-#{version}.gem"
end

task :inc_version do
    version = current_olsen_version
    if (matches = version.match(/^(\d+\.\d+\.)(\d+)$/))
        pre = matches[1]
        post = Integer(matches[2]) + 1
        version = "#{pre}#{post}"
    end
    fh = File.open("lib/olsen/version.rb","w")
    fh.puts "class Olsen"
    fh.puts '  VERSION = "' + version + '"'
    fh.puts "end"
    fh.close
    puts "incremented olsen version to #{version}"
end

Rake::RDocTask.new do |rdoc|
    rdoc.title = 'Olsen'
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('README','TODO','CHANGELOG')
    rdoc.main = 'README'
    rdoc.rdoc_dir = 'rdoc'
end

def current_olsen_version
    version = "0.0.0"
    File.open("lib/olsen/version.rb","r").each do |line|
        if matches = line.match(/version\s*\=\s*\"([^\"]+)\"/i)
            version = matches[1]
            break
        end
    end    
    version
end
