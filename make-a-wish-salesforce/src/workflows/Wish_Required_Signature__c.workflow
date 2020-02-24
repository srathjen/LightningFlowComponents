<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>WishRequiredSignature_IsClearanceCopy</fullName>
        <description>If the parent Wish Signature Form field Is Clearance is true, then check the corresponding checkbox Is Clearance.</description>
        <field>Is_Clearance__c</field>
        <literalValue>1</literalValue>
        <name>WishRequiredSignature_IsClearanceCopy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WishRequiredSignature_IsMedicalSummary</fullName>
        <description>If the parent Wish Signature Form field Is Clearance is true, then check the corresponding checkbox Is Clearance.</description>
        <field>Is_Medical_Summary__c</field>
        <literalValue>1</literalValue>
        <name>WishRequiredSignature_IsMedicalSummary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WishRequiredSignature_UpdateFormNameText</fullName>
        <description>Stores a record of the Wish Signature Form name, in case the parent is later deleted or updated after the form has been signed.</description>
        <field>Wish_Signature_Form_Name_Text__c</field>
        <formula>Wish_Signature_Form__r.Name</formula>
        <name>WishRequiredSignature.UpdateFormNameText</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WishRequiredSignature%2EHasFormParent</fullName>
        <actions>
            <name>WishRequiredSignature_UpdateFormNameText</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If a Wish Signature Form is associated with this record, we need to make updates to stamp the name of the form, in case the parent is later deleted or updated after the form has been signed.</description>
        <formula>!ISBLANK(Wish_Signature_Form__c) &amp;&amp; ISBLANK(Signed_Date__c) &amp;&amp; (ISNEW()  ||  ISCHANGED(Wish_Signature_Form__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WishRequiredSignature%2EIsClearance</fullName>
        <actions>
            <name>WishRequiredSignature_IsClearanceCopy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Wish Signature Form associated with this record is wish clearance, then stamp the value of the clearance onto the checkbox, so that the checkbox (rather than a formula field) can be used for rollups.</description>
        <formula>!ISBLANK(Wish_Signature_Form__c) &amp;&amp; Wish_Signature_Form__r.Is_Clearance__c = TRUE &amp;&amp; (ISNEW()  ||  ISCHANGED(Wish_Signature_Form__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WishRequiredSignature%2EIsMedicalSummary</fullName>
        <actions>
            <name>WishRequiredSignature_IsMedicalSummary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Wish Signature Form associated with this record is a medical summary, then stamp the value of the WSF onto the WRS checkbox, so that the WRS checkbox can be used for rollups.</description>
        <formula>!ISBLANK(Wish_Signature_Form__c) &amp;&amp; Wish_Signature_Form__r.Is_Medical_Summary__c = TRUE &amp;&amp; (ISNEW()  ||  ISCHANGED(Wish_Signature_Form__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
