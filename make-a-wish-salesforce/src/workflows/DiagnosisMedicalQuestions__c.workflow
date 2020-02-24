<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_the_Question</fullName>
        <description>Copy the Question down to the Diagnosis Medical Question Record</description>
        <field>Question__c</field>
        <formula>Medical_Question__r.Question__c</formula>
        <name>Copy the Question</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Medical Question</fullName>
        <actions>
            <name>Copy_the_Question</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy Medical Question to the Diagnosis Medical Question</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
