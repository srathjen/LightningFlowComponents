<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Rescheduled_Email_Alert</fullName>
        <description>Rescheduled Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Task_Interview_Task_Rescheduled_Email_Template</template>
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
        <template>unfiled$public/Task_Interview_Cancelled_Email_Template</template>
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
        <template>unfiled$public/Task_Interview_Completed_Email_Template</template>
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
        <template>unfiled$public/Task_Interview_Scheduled_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Interview_Task_Email_Notification</fullName>
        <description>Task: Interview Task Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Task_Interview_Task_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Volunteer_Email_Notification_for_Interview</fullName>
        <description>Task: Volunteer Email Notification for Interview</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Task_Volunteer_Email_Notification_for_Confirmation_Date</template>
    </alerts>
    <rules>
        <fullName>Task%3A Email Notification for Interivew Task</fullName>
        <actions>
            <name>Task_Interview_Task_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Interview</value>
        </criteriaItems>
        <description>When Interview task is created by Volunteer that time, It wil send an email notification to Interviewer.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Email Notification for InterviewTask Rescheduled Workflow Rule</fullName>
        <actions>
            <name>Rescheduled_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Rescheduled</value>
        </criteriaItems>
        <description>This workflow will send email alert to task owner when the status is Rescheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Volunteer Email for Confirm Date</fullName>
        <actions>
            <name>Task_Volunteer_Email_Notification_for_Interview</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When Interviewer confirmed the interview date, it will send an email notification to volunteer.</description>
        <formula>PRIORVALUE(Confirmed_Date__c) = Null &amp;&amp; (Confirmed_Date__c != Null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Task%3AInterview Cancelled Workflow Rule</fullName>
        <actions>
            <name>Task_Interview_Cancelled_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Rescheduled</value>
        </criteriaItems>
        <description>This workflow rule will fire when the interview is cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task%3AInterview Scheduled Workflow Rule</fullName>
        <actions>
            <name>Task_Interview_Scheduled_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <description>This workflow rule will fire when the interview is scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task%3AInterview completed Workflow Rule</fullName>
        <actions>
            <name>Task_Interview_Completed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This workflow rule will fire when the interview is complete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
