<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Communities_New_Active_Volunteer_Welcome_Email_Alert</fullName>
        <description>Communities New Active Volunteer Welcome Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>User_Email_Hidden__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Communities_New_Active_Volunteer_Welcome_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Start_Date_to_Today</fullName>
        <description>Sets the Affiliation Start Date to Today's date.</description>
        <field>npe5__StartDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Start Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Volunteer Start Date</fullName>
        <actions>
            <name>Update_Start_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Affiliation Start Date to Today's Date when the status moves from 'Pending' to 'Active'</description>
        <formula>ISPICKVAL(npe5__Status__c, "Active") &amp;&amp; ISPICKVAL(PRIORVALUE(npe5__Status__c), "Pending") &amp;&amp; ISPICKVAL(Constituent_Code__c, "Volunteer")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Affiliation_ET_Welcome_to_the_Make_A_Wish_Volunteer_Center</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Affiliation ET : Welcome to the Make-A-Wish Volunteer Center</subject>
    </tasks>
</Workflow>
