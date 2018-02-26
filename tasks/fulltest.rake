#
# run full visual tests
#
# 1. convert xml (via daps) to html and pdf
# 2. convert xml (via docbookrx) to adoc (via asciidoctor) to xml (via daps) to html and pdf
#

task :fulltest => [:daps, :fullasciidoctor, :testsuite]

task :fullasciidoctor => [:docbookrx, :asciidoctor, :adocxml_html, :images, :adocxml_pdf]

# convert adoc-generated-xml to html
task :adocxml_html do
  err = %x(daps -m #{File.join($testsuite, "asciidoctor", "xml", "MAIN-set.xml")}\
     --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns\
     html --single 2>&1)
  fail "daps html failed with #{err}" unless $?.exitstatus == 0
  puts "Asciidoc generated HTML: testsuite/asciidoctor/build/MAIN-set/single-html/MAIN-set/index.html"
end

# convert adoc-generated-xml to pdf
task :adocxml_pdf do
  err = %x(daps -m #{File.join($testsuite, "asciidoctor", "xml", "MAIN-set.xml")}\
           --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns\
           pdf 2>&1)
  fail "daps pdf failed with #{err}" unless $?.exitstatus == 0
  puts "Asciidoc generated PDF: testsuite/asciidoctor/build/MAIN-set/MAIN-set_color_en.pdf"
end
