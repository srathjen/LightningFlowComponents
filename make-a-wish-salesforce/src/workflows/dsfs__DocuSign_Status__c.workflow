<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_to_Case_Owner_When_Docusign_is_Completed</fullName>
        <description>Send Email to Case Owner When Docusign is Completed</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email_Hidden__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Docusign_Notification_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Case_Owner_Email</fullName>
        <field>Case_Owner_Email_Hidden__c</field>
        <formula>dsfs__Case__r.Owner:User.Email</formula>
        <name>Update Case Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner_Name</fullName>
        <field>Case_Owner_Name_Hidden__c</field>
        <formula>dsfs__Case__r.Contact.FirstName+&apos; &apos;+ LEFT(dsfs__Case__r.Contact.LastName,1)</formula>
        <name>Update Case Owner Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contact_Full_Name</fullName>
        <field>Contact_First_and_Last_Name__c</field>
        <formula>dsfs__Case__r.Contact.FirstName +&apos; &apos;+ dsfs__Case__r.Contact.LastName</formula>
        <name>Update Contact Full Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Docusign Completed Notification</fullName>
        <actions>
            <name>Send_Email_to_Case_Owner_When_Docusign_is_Completed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Owner_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Contact_Full_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>dsfs__DocuSign_Status__c.dsfs__Envelope_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Send DocuSign completed notification to case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
