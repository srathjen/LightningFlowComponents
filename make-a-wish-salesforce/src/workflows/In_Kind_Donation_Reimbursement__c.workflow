<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_of_Request_Field_Update</fullName>
        <description>This field will update when submit the record for approval</description>
        <field>Date_of_request__c</field>
        <formula>TODAY()</formula>
        <name>Date of Request Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_of_Submission</fullName>
        <description>This field will update automatically when the record submit for approval</description>
        <field>Date_of_Submission__c</field>
        <formula>TODAY()</formula>
        <name>Date of Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Kind_Approved_Date</fullName>
        <field>Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>In-Kind Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
