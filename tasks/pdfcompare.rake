#

task :pdfcompare do
  `pdfcompare testsuite/build/MAIN-set/MAIN-set_color_en.pdf testsuite/asciidoctor/build/MAIN-set/MAIN-set_color_en.pdf`
end
