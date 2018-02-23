
task :daps => [:daps_html, :daps_pdf]

task :daps_html do
  `daps -m #{File.join($testsuite, "xml", "MAIN-set.xml")} --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns html --single`
  puts "DAPS generated html: testsuite/build/MAIN-set/single-html/MAIN-set/index.html"
end

task :daps_pdf do
  `daps -m #{File.join($testsuite, "xml", "MAIN-set.xml")} --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns pdf`
  puts "DAPS generated pdf: testsuite/build/MAIN-set/MAIN-set_color_en.pdf"
end
