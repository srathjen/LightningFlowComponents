<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Abandoned_Wish_Alert</fullName>
        <description>Case : Abandoned Wish Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Airport Greeter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Celebrity Host</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Translator &amp; Interpreter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Volunteer Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Assist Phone Greeter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Coordinator</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Granter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Granter Mentor</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Abandoned_Wish_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Unassigned_Wish_Email_Alert</fullName>
        <description>Case : Unassigned Wish Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Volunteer_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Unassigned_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>National_MAC_Team_Email_Alert</fullName>
        <description>National MAC Team Email Alert.</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mawamericaprod@gmail.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Send_Email_to_National_MAC_Team</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_MAC_Team</fullName>
        <description>Send Email to MAC Team</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mawamericaprod@gmail.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Email_to_Loacl_MAC_Team_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Reply_email_to_MAC_team</fullName>
        <description>Send Reply email to MAC team</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>mawamericaprod@gmail.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Reply_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>This_Email_alert_will_send_when_the_case_sub_status_is_changed_as</fullName>
        <description>This Email alert will send when the case sub status is changed as &quot;Abandoned&quot;.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Airport Greeter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Celebrity Host</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Translator &amp; Interpreter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Volunteer Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Assist Phone Greeter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Coordinator</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Granter</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Wish Granter Mentor</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Abandoned_Wish_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Approve_Field</fullName>
        <description>Used to update isApprovefield</description>
        <field>isApprove__c</field>
        <literalValue>1</literalValue>
        <name>Update Approve Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_isEmail</fullName>
        <description>This field update is used to update the isEmail field to false</description>
        <field>isEmail__c</field>
        <literalValue>0</literalValue>
        <name>Update isEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_is_National_in_Case</fullName>
        <description>This field update is used to when the IsNational check box is selected in case. it update as false.</description>
        <field>isNational__c</field>
        <literalValue>0</literalValue>
        <name>Update is National in Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wish_Approved</fullName>
        <field>isApprove__c</field>
        <literalValue>1</literalValue>
        <name>Wish Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case %3A Abandoned Wish Rule</fullName>
        <actions>
            <name>Case_Abandoned_Wish_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>This_Email_alert_will_send_when_the_case_sub_status_is_changed_as</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule will fire when the case sub status is changed as &quot;Abandoned&quot;.</description>
        <formula>AND(ISCHANGED(Sub_Status__c),ISPICKVAL(Sub_Status__c, &apos;Abandoned&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case %3A Unassigned  Wish Workflow Rule</fullName>
        <actions>
            <name>Case_Unassigned_Wish_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Case_Member_Count__c</field>
            <operation>lessThan</operation>
            <value>2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Case_Member_Count__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.isEmail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will fire when the wish is not assigned for particular time period</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Email to MAC Team</fullName>
        <actions>
            <name>Send_Email_to_MAC_Team</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_isEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(isEmail__c  = TRUE,ISCHANGED(isEmail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3ABirthday Task</fullName>
        <active>true</active>
        <description>This workflow will create Task to Volunteer for Wish Child Birthday</description>
        <formula>(DATE(YEAR(Today()),Month(Birthdate__c),Day(Birthdate__c)) &gt; (Today()) ) &amp;&amp; (Text(Status) != &apos;Closed&apos;) &amp;&amp; (RecordType.DeveloperName = &apos;Wish&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Birthday_Task</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Birthdate__c</offsetFromField>
            <timeLength>-21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Email to National Team</fullName>
        <actions>
            <name>National_MAC_Team_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_is_National_in_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will fire when the isNational check box is checked.</description>
        <formula>AND(isNational__c = TRUE,ISCHANGED(isNational__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Reply email to MAC team</fullName>
        <actions>
            <name>Send_Reply_email_to_MAC_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This work flow rule is used to send replay email to MAC team.</description>
        <formula>ISCHANGED(Case_Comment__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Wish Close</fullName>
        <actions>
            <name>Update_Approve_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Determination,Wish Planning &amp; Anticipation,Wish Assist,Wish Granted,Wish Effect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used update isApprove Field when the child case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Birthday_Task</fullName>
        <assignedTo>sailappa_maw@mstsolutions.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>21</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Wish Child Birthday Reminder</subject>
    </tasks>
</Workflow>
