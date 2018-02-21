require 'rake/clean'
CLEAN.include("**/*~", "testsuite/build", "testsuite/asciidoctor", "testsuite/xml/*.adoc", "testsuite/xml/*.html")
