<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Diagnosis_Form_Email_Alert</fullName>
        <description>Diagnosis Form Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Treating_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Part_A_Form_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Lead_Email_Alert_for_Lead_Owner_Regarding_Chapter_Update</fullName>
        <description>Lead: Email Alert for Lead Owner Regarding Chapter Update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Lead_Email_Notification_for_Lead_Owner</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Office_Referrar_email_with_Wish_Referral_Form</fullName>
        <description>Send Email to Office Referrar email with Wish Referral Form</description>
        <protected>false</protected>
        <recipients>
            <recipient>furqan_maw@mstsolutions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sailappa_maw@mstsolutions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Send_Wish_Referral_Form_to_Non_Active_Chapter_Office</template>
    </alerts>
    <rules>
        <fullName>Lead%3A Email Notification for Lead Owner</fullName>
        <actions>
            <name>Lead_Email_Alert_for_Lead_Owner_Regarding_Chapter_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Whenever chapter updates based on the Postal Code, It will send an email notification to Lead Owner.</description>
        <formula>ISCHANGED( ChapterName__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
