<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>O_T_Orientation_Cancelled_Email_Alert</fullName>
        <description>O&amp;T:Orientation Cancelled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Orientation_Cancelled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>O_T_Orientation_Completed_Email_Alert</fullName>
        <description>O&amp;T:Orientation Completed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Orientation_Completed_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>O_T_Orientation_Registered_Email_Alert</fullName>
        <description>O&amp;T:Orientation Registered Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Orientation_Registered_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>O_T_Training_Cancelled_Email_Alert</fullName>
        <description>O&amp;T:Training Cancelled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Training_Cancelled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>O_T_Training_Completed_Email_Alert</fullName>
        <description>O&amp;T:Training Completed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Training_Completed_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>O_T_Training_Registered_Email_Alert</fullName>
        <description>O&amp;T:Training Registered Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Training_Registered_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Training_Pending_Volunteer_Virtual_Self_Paced_Registered_Email_Alert</fullName>
        <description>Training: Pending Volunteer, Virtual Self Paced Registered Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Training_Pending_Volunteer_Virtual_Self_Paced_Registered_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_O_T_Orienation_Registered_for_Virtual_Self_faced_Training</fullName>
        <description>Volunteer O&amp;T : Orienation Registered for Virtual Self faced Training</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Orientation_Virtual_Self_Paced_Registered_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_O_T_Registered_for_Virtual_Self_faced_Training</fullName>
        <description>Volunteer O&amp;T : Registered for Virtual Self faced Training</description>
        <protected>false</protected>
        <recipients>
            <field>VolunteerHidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Training_Virtual_Self_Paced_Registered_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Copy_Class_Date</fullName>
        <description>Copies class date from parent Class Offering record</description>
        <field>Class_Date__c</field>
        <formula>Class_Offering__r.Date__c</formula>
        <name>Copy Class Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VolunteerO_T_Completed_Date</fullName>
        <description>It update the Hidden Completed Date Field: if record type as Virtual_Self_Paced then value is Today()  other wise Class Offering Date.</description>
        <field>Hidden_Completed_Date__c</field>
        <formula>IF((Class_Offering__r.RecordType.DeveloperName ='Virtual_Self_Paced'), Today(), Class_Offering__r.Date__c)</formula>
        <name>VolunteerO&amp;T:Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Stamp Class Date</fullName>
        <actions>
            <name>Copy_Class_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule fires to populate the Class Date directly on the Volunteer Orientation &amp; Training record, so that it can be used in roll-up-summaries to the Contact.</description>
        <formula>!ISBLANK(Class_Offering__c) &amp;&amp;  ISBLANK(Class_Date__c) &amp;&amp;  !ISBLANK(Class_Offering__r.Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>VolunteerO%26T%3AUpdatecompletedDate</fullName>
        <actions>
            <name>VolunteerO_T_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>This Update the Hidden Completed  date when the Volunteer Attendance as Completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>O_T_ET_Orientation_Cancelled</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Orientation Cancelled</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Orientation_Completed</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Orientation Completed</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Successfully_Registered_for_Orientation</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Successfully Registered for Orientation</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Successfully_Registered_for_Orientation_VSF</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Successfully Registered for Orientation(VSF)</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Successfully_Registered_for_Training</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Successfully Registered for Training</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Successfully_Registered_for_Training_VSF</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Successfully Registered for Training (VSF)</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Training_Cancelled</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Training Cancelled</subject>
    </tasks>
    <tasks>
        <fullName>O_T_ET_Training_Completed</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>O&amp;T ET : Training Completed</subject>
    </tasks>
</Workflow>
