# coding: utf-8
require 'spec_helper'

describe 'SUSE Conversion' do
  it 'should accept a DocBook 5 header' do
    input = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="urn:x-suse:xslt:profiling:docbook50-profile.xsl"
                 type="text/xml" 
                 title="Profiling step"?>
<!DOCTYPE set
[
  <!ENTITY % entities SYSTEM "entity-decl.ent">
    %entities;
]>
<set version="5.0" xml:lang="en" xml:id="set.mgr" xmlns="http://docbook.org/ns/docbook"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xlink="http://www.w3.org/1999/xlink">
</set>
    EOS

    expected = <<-EOS.rstrip
EOS

    output = Docbookrx.convert input

    expect(output).to eq(expected)
  end

end # 'SUSE Conversion'