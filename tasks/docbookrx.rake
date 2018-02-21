dirname = File.dirname(__FILE__)

task :docbookrx do
  `docbookrx #{File.join(dirname, "..", "testsuite", "xml", "MAIN-set.xml")}`
end
