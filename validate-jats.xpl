<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" name="validate" version="1.0">
<!-- run with:  calabash -i source=xmlfile validate-jats.xpl-->
<p:validate-with-xml-schema>
    <p:input port="schema">
        <p:document href="assets/validation/jats-publishing-xsd-1.0/JATS-journalpublishing1.xsd"/>
    </p:input>

</p:validate-with-xml-schema>
</p:pipeline>
