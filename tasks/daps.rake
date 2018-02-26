
task :daps => [:daps_html, :daps_pdf]

task :daps_html do
  err = %x(daps -m #{File.join($testsuite, "xml", "MAIN-set.xml")}\
     --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns\
     html --single 2>&1)
  fail "daps html failed with #{err}" unless $?.exitstatus == 0
  puts "DAPS generated html: testsuite/build/MAIN-set/single-html/MAIN-set/index.html"
end

task :daps_pdf do
  %x(daps -m #{File.join($testsuite, "xml", "MAIN-set.xml")}\
     --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns\
     pdf 2>&1)
  fail "daps pdf failed with #{err}" unless $?.exitstatus == 0
  puts "DAPS generated pdf: testsuite/build/MAIN-set/MAIN-set_color_en.pdf"
end
