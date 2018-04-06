# coding: utf-8
require 'rspec'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
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

    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

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

  it 'should accept a <keycombo> with <mousebutton> node' do
    input = <<-EOS
     <para>
      Once you have finished your capture re-open terminal 1 and stop the
      capture of data with: <keycombo> <keycap>CTRL</keycap> <keycap>c</keycap> <mousebutton>Button2</mousebutton>
      </keycombo>
     </para>
    EOS
    expected = <<-EOS.rstrip

Once you have finished your capture re-open terminal 1 and stop the capture of data with: kbd:[CTRL+c]-Button2
EOS
    output = Docbookrx.convert input

    expect(output).to eq(expected)
  end

  it 'should accept a <keycombo> with <mousebutton> in the middle node' do
    input = <<-EOS
     <para>
      Once you have finished your capture re-open terminal 1 and stop the
      capture of data with: <keycombo> <keycap>CTRL</keycap> <keycap>c</keycap> <mousebutton>Button2</mousebutton> <keycap>F1</keycap>
      </keycombo>
     </para>
    EOS
    expected = <<-EOS.rstrip

Once you have finished your capture re-open terminal 1 and stop the capture of data with: kbd:[CTRL+c]-Button2-kbd:[F1]
EOS
    output = Docbookrx.convert input

    expect(output).to eq(expected)
  end

  it 'should handle entity' do
    input = <<-EOS
<!DOCTYPE book [ <!ENTITY lala "tux"> ]><para>bar &lala; </para>
EOS
    expected = <<-EOS.rstrip


bar {lala}
EOS
    output = Docbookrx.convert input, strict: true

    expect(output).to eq(expected)
  end

  it 'should handle entity in xml' do
    input = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE book [ <!ENTITY lala "tux"> ]><para>bar &lala; </para>
EOS
    expected = <<-EOS.rstrip


bar {lala}
EOS
    output = Docbookrx.convert input, strict: true

    expect(output).to eq(expected)
  end

  it 'should handle internal entities' do
    input = <<-EOS
<?xml-stylesheet href="urn:x-suse:xslt:profiling:docbook50-profile.xsl"
                 type="text/xml" 
                 title="Profiling step"?>
<!DOCTYPE EXAMPLE SYSTEM "suse.dtd" [
  <!ENTITY productnumber "42.0">
]>
<book xmlns="http://docbook.org/ns/docbook">
<info>
<title>SUSE Manager &productnumber;</title>
</info>
</book>
    EOS

    expected = <<-EOS.rstrip
= SUSE Manager 42.0
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
mailto:doc-team@suse.de[<doc-team@suse.de>]
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
  it 'should preserve ids' do
    input = <<-EOS.rstrip
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="urn:x-suse:xslt:profiling:docbook50-profile.xsl"
                 type="text/xml" 
                 title="Profiling step"?>
<chapter xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xlink="http://www.w3.org/1999/xlink" version="5.0">
    <title>xml:id test</title>
    <para xml:id="id">foo</para>
</chapter>
EOS
    expected = <<-EOS.rstrip
= xml:id test
:doctype: book
:sectnums:
:toc: left
:icons: font
:experimental:
:sourcedir: .

[[_id]]

foo
EOS
    dirname = File.dirname(__FILE__)
    output = Docbookrx.convert input, cwd: dirname

    expect(output).to eq(expected)

  end
  it 'should convert quandaset without qandadiv elements to Q and A list' do
    input = <<-EOS
<article>
  <qandaset>
      <title>Various Questions</title>
      <qandaentry xml:id="some-question">
        <question>
          <para>My question?</para>
        </question>
        <answer>
          <para>My answer!</para>
        </answer>
      </qandaentry>
      <qandaentry>
        <question>
          <para>Another question?</para>
        </question>
        <answer>
          <para>Another answer!</para>
        </answer>
      </qandaentry>
  </qandaset>
  <para>A paragraph</para>
</article>
    EOS

    expected = <<-EOS.rstrip
.Various Questions

[qanda]
[[_some_question]]
My question?::

My answer!

Another question?::

Another answer!


A paragraph
    EOS

    output = Docbookrx.convert input

    expect(output).to include(expected)
  end
  it 'should convert members to listitems' do
    input = <<-EOS
    <simplelist>
      <member>Item One</member>
      <member>Item Two</member>
    </simplelist>
EOS
    expected = <<-EOS.rstrip
* Item One
* Item Two
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end
  it 'should properly close <screen>' do
    input = <<-EOS
  <variablelist>
  <varlistentry>
  <term>Clients (using <package>zypp-plugin-spacewalk</package>) - <filename>/etc/zypp/zypp.conf</filename>:</term>
  <listitem>
  <screen>## Valid values:  [0,3600]
## Default value: 180
download.transfer_timeout = 180</screen>
       <para>
          foo
       </para>
  </screen>
  </listitem>
  </varlistentry>
  </variablelist>
EOS
    expected = "
Clients (using [package]#zypp-plugin-spacewalk# ) - [path]``/etc/zypp/zypp.conf`` :::
+

----
## Valid values:  [0,3600]
## Default value: 180
download.transfer_timeout = 180
----
foo"
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end
  it "should parse embedded tags in screen" do
    input = <<-EOS
<screen><prompt># </prompt><command>cat <replaceable>MODIFIED-SCRIPT.SH</replaceable> \
  | ssh root@example.com /bin/bash</command>
</screen>
EOS
    expected = <<-EOS.rstrip

----
# ``cat MODIFIED-SCRIPT.SH   | ssh root@example.com /bin/bash`` 
----
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end
  
  it "should parse procedure content" do
    input = <<-EOS
    <procedure xml:id="at.manager.proxy.install.prep">
     <title>Registering the Proxy</title>

   <important>
    <para>
     First completly download the channels (SLE 12 SP3) and then create the
     activation key. Only then you can select the correct child channels.
    </para>
   </important>
   
   <step>
    <para>
     Create an activation key based on the SLE 12 SP3 base channel. For more
     information about activation keys, see
     <xref
        linkend="create.act.keys"/>.
    </para>
  </step>
  </procedure>
EOS
    expected = <<-EOS.rstrip

[[_at.manager.proxy.install.prep]]
.Procedure: Registering the Proxy


IMPORTANT: First completly download the channels (SLE 12 SP3) and then create the activation key.
Only then you can select the correct child channels. 
. Create an activation key based on the SLE 12 SP3 base channel. For more information about activation keys, see <<_create.act.keys>>. 
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should listitem titles" do
    input = <<-EOS
    <itemizedlist>
     <title>Github Path Options</title>
     <listitem>
      <para>Github Single User Project Repository:</para>
     </listitem>
    </itemizedlist>
EOS
    expected = <<-EOS.rstrip

.Github Path Options
* Github Single User Project Repository:
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end
  it "should list titles within procedure steps" do
    input = <<-EOS
<procedure>
   <step>
    <para>Enter a Github or Gitlab repositiory URL (http/https/token authentication) in the
      <guimenu>Path</guimenu> field using one of the following formats: </para>
    <itemizedlist>
     <title>Github Path Options</title>
     <para></para>
     <listitem>
      <para>Github Single User Project Repository:</para>
      <screen>https://github.com/USER/project.git#branchname:folder</screen>
     </listitem>
    </itemizedlist>
  </step>
</procedure>
EOS
    expected = <<-EOS


. Enter a Github or Gitlab repositiory URL (http/https/token authentication) in the menu:Path[] field using one of the following formats: 

.Github Path Options
** Github Single User Project Repository:
+

----
https://github.com/USER/project.git#branchname:folder
----
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle screen within a procedure step" do
    input = <<-EOS
<procedure>
            <title>Performing a Hot Backup</title>
            <step>
                <para> If you want to create a backup for the first time, run: </para>
                <screen><command>smdba</command> backup-hot --enable=on --backup-dir=/var/spacewalk/db-backup</screen>

                <para> This command performs a restart of the postgresql database. If you want to
                    renew the basic backup, use the same command. </para>
            </step>
</procedure>
EOS
    expected = <<-EOS.rstrip

.Procedure: Performing a Hot Backup
. If you want to create a backup for the first time, run: 
+

----
``smdba`` backup-hot --enable=on --backup-dir=/var/spacewalk/db-backup
----
+
This command performs a restart of the postgresql database.
If you want to renew the basic backup, use the same command.
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it 'should properly handle <listitem> notes' do
    input = <<-EOS
  <variablelist>
  <varlistentry>
    <term>Manage System Completely via SSH (Will not Install an Agent)</term>
    <listitem>
     <note>
      <title>Technology Preview</title>
      <para>
       This feature is a Technology preview.
      </para>
     </note>
     <para>
      If selected a system will automatically be configured to use SSH. No
      other connection method will be configured.
     </para>
    </listitem>
  </varlistentry>
  </variablelist>
EOS
    expected = <<-EOS.rstrip

Manage System Completely via SSH (Will not Install an Agent)::
+

.Technology Preview
[NOTE]
====
This feature is a Technology preview. 
====
If selected a system will automatically be configured to use SSH.
No other connection method will be configured. 
EOS

    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle replaceable within option" do
    input = <<-EOS
<para>
   The <option>--name=</option><replaceable>string</replaceable> option is a
   label used to differentiate one distribution choice from another (for
   example, <literal>sles12server</literal>).
  </para>
EOS
    expected = <<-EOS.rstrip

The [option]``--name=``[replaceable]``string`` option is a label used to differentiate one distribution choice from another (for example, ``sles12server``).
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle urls as filename" do
    input = <<-EOS
<para>
<filename>http://&lt;EXAMPLE-MANAGER-FQDN.com/pub&gt;</filename>
</para>
EOS
    expected = <<-EOS.rstrip
[path]``http://<EXAMPLE-MANAGER-FQDN.com/pub>``
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle qoutes in titles" do
    input = <<-EOS
<section>
<title>Registering <quote>Traditional</quote> Clients</title>
</section>
EOS
    expected = <<-EOS.rstrip
= Registering "`Traditional`" Clients
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle imagedata inside variablelist" do
    input = <<-EOS
     <variablelist>
     <varlistentry>
      <term>Centrally-Managed Files</term>
      <listitem>
       <informalfigure>
        <mediaobject>
         <imageobject role="fo">
          <imagedata fileref="system_details_traditional_configuration_view_mod_central_paths.png"
           width="400"/>
         </imageobject>
         <imageobject role="html">
          <imagedata fileref="system_details_traditional_configuration_view_mod_central_paths.png"
           width="80%"/>
         </imageobject>
        </mediaobject>
       </informalfigure>
       <para>
        Centrally-managed configuration files are provided by global
       </para>
      </listitem>
     </varlistentry>
    </variablelist>
EOS
    expected = <<-EOS.rstrip

Centrally-Managed Files::
+
image::system_details_traditional_configuration_view_mod_central_paths.png[]
Centrally-managed configuration files are provided by global 
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should not add '+' between screen and para in a list" do
    input = <<-EOS
<variablelist>
 <varlistentry>
  <term>General Targeting</term>
  <listitem>
   <para> List available grains on all minions: </para>
   <screen><prompt># </prompt>salt '*' grains.ls</screen>
   <para> Ping a specific minion: </para>
   <screen><prompt># </prompt>salt 'web1.example.com' test.ping</screen>
  </listitem>
 </varlistentry>
</variablelist>
EOS
    expected = <<-EOS.rstrip

General Targeting::
List available grains on all minions: 
+

----
# salt '*' grains.ls
----
+
Ping a specific minion: 
+

----
# salt 'web1.example.com' test.ping
----
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  it "should handle notes without title" do
    input = <<-EOS
<itemizedlist>
<listitem>
<para>blah</para>
<note>
<para>note</para>
</note>
</listitem>
</itemizedlist>
EOS
    expected = <<-EOS.rstrip

* blah
+

NOTE: note
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end

  # DON'T DROP - copy & paste new tests from here
  it "should provide a template" do
    input = <<-EOS
<para>template</para>
EOS
    expected = <<-EOS.rstrip
template
EOS
    output = Docbookrx.convert input

    expect(output).to include(expected)
  end


end # 'SUSE Conversion'
