#
# convert .xml -[docbookrx]-> .adoc -[asciidoctor]-> .xml
# and check the generated xml (via testsuite)

task :test => [:docbookrx, :asciidoctor, :testsuite]
