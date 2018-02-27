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

  it 'should accept a <set> construct' do
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


    <info>
        <title>SUSE Manager &productnumber;</title>
        <productname>&susemgr;</productname>
        <productnumber>&productnumber;</productnumber>
        <dm:docmanager xmlns:dm="urn:x-suse:ns:docmanager">
          <dm:bugtracker>
            <dm:url>https://github.com/SUSE/doc-susemanager/issues/new</dm:url>
            <dm:labels>buglink</dm:labels>
          </dm:bugtracker>
        </dm:docmanager>
    </info>
    <?dbjsp filename="index.jsp"?>

    <xi:include href="suse_book.xml"/>

</set>
    EOS

    expected = <<-EOS
= SUSE Manager


include::suse_book.adoc[]

EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should convert an included file' do
    dirname = File.dirname(__FILE__)
    expect(File.read(File.join(dirname,"suse_book.expected"))).to eq(File.read(File.join(dirname,"suse_book.adoc")))
  end

  it 'should accept a <keycombo> node' do
    input = <<-EOS
     <para>
      Once you have finished your capture re-open terminal 1 and stop the
      capture of data with: <keycombo> <keycap>CTRL</keycap> <keycap>c</keycap>
      </keycombo>
     </para>
    EOS
    expected = <<-EOS.rstrip

Once you have finished your capture re-open terminal 1 and stop the capture of data with: kbd:[CTRL+c] 
EOS
    output = Docbookrx.convert input

    expect(output).to eq(expected)
  end

  it 'should handle entities' do
    input = <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="urn:x-suse:xslt:profiling:docbook50-profile.xsl"
                 type="text/xml" 
                 title="Profiling step"?>
<!DOCTYPE EXAMPLE SYSTEM "suse.dtd" [
  <!ENTITY productnumber "{productnumber}">
]>
<book xmlns="http://docbook.org/ns/docbook">
<info>
<title>SUSE Manager &productnumber;</title>
</info>
</book>
    EOS

    expected = <<-EOS.rstrip
= SUSE Manager
:doctype: book
:sectnums:
:toc: left
:icons: font
:experimental:
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should handle email' do
    input = <<-EOS
<email>doc-team@suse.de</email>
EOS

    expected = <<-EOS.rstrip
mailto:doc-team@suse.de[doc-team@suse.de]
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should handle calloutlist' do
    input = <<-EOS
    <calloutlist>
     <callout arearefs="co.s2-cobbler-dhcp.exist.bootp">
      <para>
       Enable network booting with the <systemitem>bootp</systemitem> protocol.
      </para>
     </callout>
     <callout arearefs="co.s2-cobbler-dhcp.exist.pxe">
      <para>
       Create a class called <literal>PXE</literal>.
      </para>
     </callout>
    </calloutlist>
EOS

    # this is ugly. docbookrx converts a trailing "." to ". "
    # expected would end in ". \n".
    # Doing EOS.rstrip would make this ".". But we need ". ".
    expected = <<-EOS[0..-2]
arearefs:co.s2-cobbler-dhcp.exist.bootp

Enable network booting with the [path]_bootp_
 protocol. 
arearefs:co.s2-cobbler-dhcp.exist.pxe


Create a class called ``PXE``. 
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should handle simplelist' do
    input = <<-EOS
    <simplelist>
     <member>User name: <literal>admin</literal></member>
    </simplelist>
EOS

    expected = <<-EOS.rstrip

* User name: `admin`
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should handle nested simplelist' do
    input = <<-EOS.rstrip
    <itemizedlist>
      <listitem>
        <para>
          Itemized listitem para
        </para>
        <simplelist>
          <member>User name: <literal>admin</literal></member>
        </simplelist>
      </listitem>
    </itemizedlist>
EOS

    expected = <<-EOS

* Itemized listitem para 
+
* User name: `admin`
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end

  it 'should handle info abstracts' do
    input = <<-EOS.rstrip
    <book>
     <info>
      <title>
       Info title
      </title>
      <abstract>
       <para>
        Info abstract
       </para>
      </abstract>
     </info>
    </book>
EOS

    expected = <<-EOS.rstrip
= Info title

[abstract]
--
Info abstract 
--
:doctype: book
:sectnums:
:toc: left
:icons: font
:experimental:
EOS

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end
end # 'SUSE Conversion'
