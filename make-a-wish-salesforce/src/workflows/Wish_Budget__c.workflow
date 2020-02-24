<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Wish_Budget_Approval_Status_Approved</fullName>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Wish Budget: Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Approval_Status_Rejected</fullName>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Wish Budget: Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Approval_Status_Submitted</fullName>
        <description>Changes the Budget Approval Status field on the Wish Budget to be &quot;Submitted&quot;.</description>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Wish Budget: Approval Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Approved_DateTime_Now</fullName>
        <field>Budget_Approved_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Wish Budget: Approved DateTime = Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Approved_Date_Today</fullName>
        <field>Budget_Approved_Date__c</field>
        <formula>Today()</formula>
        <name>Wish Budget: Approved Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Clear_Approval_Date</fullName>
        <description>Clear the value in the &quot;Budget Approved Date&quot; field when a budget is submitted, in order to eliminate any discrepancy between the approval status and the approval date.</description>
        <field>Budget_Approved_Date__c</field>
        <name>Wish Budget: Clear Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Clear_Approval_Status</fullName>
        <description>Clear the &quot;Budget Approval Status&quot; field. Used when the Wish Budget is recalled from approval.</description>
        <field>Budget_Approval_Status__c</field>
        <name>Wish Budget: Clear Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Clear_Submitted_Date</fullName>
        <field>Budget_Submitted_Date__c</field>
        <name>Wish Budget: Clear Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Budget_Submitted_Date_Today</fullName>
        <field>Budget_Submitted_Date__c</field>
        <formula>TODAY()</formula>
        <name>Wish Budget: Submitted Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <tasks>
        <fullName>Wish_Budget_needs_to_be_revised</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Wish Budget needs to be revised</subject>
    </tasks>
</Workflow>
