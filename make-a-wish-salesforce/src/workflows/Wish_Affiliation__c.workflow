<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Wish_Aff_Clear_Date_Participant_Removed</fullName>
        <field>Date_Participant_Removed__c</field>
        <name>Wish Aff: Clear Date Participant Removed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Aff_Set_Date_Participant_Removed</fullName>
        <field>Date_Participant_Removed__c</field>
        <formula>TODAY()</formula>
        <name>Wish Aff: Set Date Participant Removed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Wish Affiliation%3A Participant Re-Added</fullName>
        <actions>
            <name>Wish_Aff_Clear_Date_Participant_Removed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Intended to clear the Date Participant Removed if a participant is re-added to a wish.</description>
        <formula>(ISPICKVAL(Wish_Affiliation_Type__c,&quot;Approved Participant&quot;)  ||  ISPICKVAL(Wish_Affiliation_Type__c,&quot;Requested Participant&quot;)) &amp;&amp; !ISBLANK(Date_Participant_Removed__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Wish Affiliation%3A Participant Removed</fullName>
        <actions>
            <name>Wish_Aff_Set_Date_Participant_Removed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Intended to stamp a date to be used in reports and list views, as field history tracking reports are not currently available on detail objects.</description>
        <formula>(ISPICKVAL(PRIORVALUE(Wish_Affiliation_Type__c),&quot;Approved Participant&quot;)  ||  ISPICKVAL(PRIORVALUE(Wish_Affiliation_Type__c),&quot;Requested Participant&quot;)) &amp;&amp; !ISPICKVAL(Wish_Affiliation_Type__c,&quot;Approved Participant&quot;) &amp;&amp; !ISPICKVAL(Wish_Affiliation_Type__c,&quot;Requested Participant&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
