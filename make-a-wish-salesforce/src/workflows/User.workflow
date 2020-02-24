<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_After_7_Days_If_Volunteer_not_Registered</fullName>
        <description>Send Email After 7 Days If Volunteer not Registered</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Communities_New_Prospective_Volunteer_Welcome_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Welcome_Email_to_Prospective_volunteer_user</fullName>
        <description>Send Welcome Email to Prospective volunteer user</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Communities_New_Prospective_Volunteer_Welcome_Email_Template</template>
    </alerts>
    <rules>
        <fullName>Send Email After 7 Days and 30 Days If Volunteer Orientation Not Registered</fullName>
        <active>true</active>
        <description>Send Email After 7 Days and 30 Days If Volunteer Orientation Not Registered</description>
        <formula>Migrated_User__c = FALSE &amp;&amp; TEXT( Volunteer_Orientation_Status__c ) &lt;&gt; &quot;Registered&quot; &amp;&amp;  ProfileId = $Label.Prospective_Volunteer_Profile</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Email_After_7_Days_If_Volunteer_not_Registered</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Email_After_7_Days_If_Volunteer_not_Registered</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>User %3ASend Welcome Email to User</fullName>
        <actions>
            <name>Send_Welcome_Email_to_Prospective_volunteer_user</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Used to send welcome email for new prospective volunteer user</description>
        <formula>AND( Migrated_User__c = FALSE,  ProfileId = $Label.Prospective_Volunteer_Profile )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
