# copy all images to local-subdir
task :images do
  require 'find'
  sourcedir = File.join($testsuite, "images")
  destdir = File.join($testsuite, "asciidoctor","build","MAIN-set","single-html","MAIN-set", "images")
  Dir.mkdir(destdir) rescue nil
  Find.find(sourcedir) do |path|
    next unless path =~ /\.jpg/
    `cp #{path} #{destdir}`
  end
end
