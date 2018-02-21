dirname = File.dirname(__FILE__)

task :daps do
  `daps -m #{File.join(dirname, "..", "testsuite", "xml", "MAIN-set.xml")} html`
end