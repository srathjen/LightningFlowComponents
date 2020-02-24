<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>cg__Preview_Callout</fullName>
        <apiVersion>38.0</apiVersion>
        <endpointUrl>https://portal.sdriveapp.com/preview/generate</endpointUrl>
        <fields>Id</fields>
        <fields>cg__Error_Count__c</fields>
        <fields>cg__Error_Message__c</fields>
        <fields>cg__File_Key__c</fields>
        <fields>cg__File_Name__c</fields>
        <fields>cg__File_Object_Id__c</fields>
        <fields>cg__File_Object_Type__c</fields>
        <fields>cg__File_Size__c</fields>
        <fields>cg__File_Url__c</fields>
        <fields>cg__Preview_Key__c</fields>
        <fields>cg__Preview_Name__c</fields>
        <fields>cg__Preview_State__c</fields>
        <fields>cg__S3_Signature__c</fields>
        <fields>cg__Thumbnail_Key__c</fields>
        <fields>cg__Thumbnail_Name__c</fields>
        <fields>cg__Thumbnail_State__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>chennareddy_maw@mstsolutions.com</integrationUser>
        <name>Preview Callout</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>cg__Preview Callout</fullName>
        <actions>
            <name>cg__Preview_Callout</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>cg__Preview__c.cg__File_Object_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
