# run asciidoctor to convert .adoc to .xml
task :asciidoctor do
  err= %x(asciidoctor\
  --trace\
  -b docbook5\
  -d book\
  -D #{File.join($testsuite, "asciidoctor", "xml")}\
  #{File.join($testsuite, "xml", "MAIN-set.adoc")})
  fail "asciidoctor failed with #{err}" unless $?.exitstatus == 0
  puts "Asciidoctor generated xml: testsuite/asciidoctor/xml/MAIN-set.xml"
end
