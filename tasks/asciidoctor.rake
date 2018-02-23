
# run asciidoctor to convert .adoc to .xml
task :asciidoctor do
  `asciidoctor -b docbook5\
  -d book\
  -D #{File.join($testsuite, "asciidoctor", "xml")}\
  #{File.join($testsuite, "xml", "MAIN-set.adoc")}`
end
