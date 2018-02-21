dirname = File.dirname(__FILE__)

task :daps do
  `daps -m #{File.join(dirname, "..", "testsuite", "xml", "MAIN-set.xml")} --styleroot /usr/share/xml/docbook/stylesheet/suse2013-ns html`
end
