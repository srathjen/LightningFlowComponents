<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>AttachmentSync_Callout</fullName>
        <apiVersion>29.0</apiVersion>
        <endpointUrl>https://portal.sdriveapp.com/sync/sdriveSyncV2</endpointUrl>
        <fields>AttachmentId__c</fields>
        <fields>AttachmentObjectFileName__c</fields>
        <fields>AttachmentParentId__c</fields>
        <fields>AttachmentParentObjectName__c</fields>
        <fields>AttachmentRelationshipName__c</fields>
        <fields>CreatedDate</fields>
        <fields>FailedMessage__c</fields>
        <fields>FailedStatus__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>sailappa_maw@mstsolutions.com</integrationUser>
        <name>AttachmentSync Callout</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>AttachmentSync Callout</fullName>
        <actions>
            <name>AttachmentSync_Callout</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>AttachmentSync__c.AttachmentId__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>AttachmentSync__c.FailedStatus__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
