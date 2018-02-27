dirname = File.dirname(__FILE__)

task :docbookrx do
  err= %x(docbookrx\
    #{File.join(dirname, "..", "testsuite", "xml", "MAIN-set.xml")})
  fail "docbookrx failed with #{err}" unless $?.exitstatus == 0
end
