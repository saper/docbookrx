dirname = File.dirname(__FILE__)
testsuite = File.expand_path(File.join(dirname, "..", "testsuite"))

task :asciidoctor => [:docbookrx] do
  `asciidoctor -b docbook5\
  -d book\
  -D #{File.join(testsuite, "asciidoctor", "xml")}\
  #{File.join(testsuite, "xml", "MAIN-set.adoc")}`
  `daps -m #{File.join(testsuite, "asciidoctor", "xml", "MAIN-set.xml")} --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns html`
end
