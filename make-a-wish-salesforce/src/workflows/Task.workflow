<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Rescheduled_Email_Alert</fullName>
        <description>Rescheduled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Interview_Task_Rescheduled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Interview_Cancelled_Email_Alert</fullName>
        <description>Task:Interview Cancelled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Interview_Cancelled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Interview_Completed_Email_Alert</fullName>
        <description>Task:Interview Completed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Interview_Completed_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Interview_Scheduled_Email_Alert</fullName>
        <description>Task:Interview Scheduled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Interview_Scheduled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Interview_Task_Email_Notification</fullName>
        <description>Task: Interview Task Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Interview_Task_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Volunteer_Email_Notification_for_Interview</fullName>
        <description>Task: Volunteer Email Notification for Interview</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Volunteer_Templates/Task_Volunteer_Email_Notification_for_Confirmation_Date</template>
    </alerts>
    <fieldUpdates>
        <fullName>Close_Task</fullName>
        <description>Updates the task Status to Completed.</description>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>Close Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Default</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign Task to default</fullName>
        <actions>
            <name>Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>days Pending Clarification - MAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>days Pending Clarification - Chapter</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Close Task</fullName>
        <actions>
            <name>Close_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Close_Task__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used to close multiple tasks from a list view.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Task_ET_Interview_Cancelled</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview Cancelled</subject>
    </tasks>
    <tasks>
        <fullName>Task_ET_Interview_Completed</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview Completed</subject>
    </tasks>
    <tasks>
        <fullName>Task_ET_Interview_Confirmation_Date_and_Venue</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview Confirmation Date and Venue</subject>
    </tasks>
    <tasks>
        <fullName>Task_ET_Interview_Task_Rescheduled_for_You</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview Task Rescheduled for You</subject>
    </tasks>
    <tasks>
        <fullName>Task_ET_Interview_scheduled</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview scheduled</subject>
    </tasks>
    <tasks>
        <fullName>Task_ET_Task_ET_Interview_Task_Assigned_for_You</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Task ET : Interview Task Assigned for You</subject>
    </tasks>
</Workflow>
