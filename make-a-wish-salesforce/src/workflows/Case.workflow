<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Budget_Submitted_Alert</fullName>
        <description>Budget Submitted Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Wish_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvcsupport@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Budget_Approval_Template</template>
    </alerts>
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
        <fullName>Case_Approval</fullName>
        <description>Case : Budget Approval Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Budget_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Budget_Submitted_Alert</fullName>
        <description>Case : Budget Submitted Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Wish_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Budget_Submitted_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Send_Email_to_Wish_Granter_Alert</fullName>
        <description>Case : Send Email to Wish Granter Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Wish Granter</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Send_Email_to_Wish_Granter_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Send_an_Email_Alert_to_Case_Owner_for_On_Hold_Status</fullName>
        <description>Case : Send an Email Alert to Case Owner for On Hold Status</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Email_Notification_to_Case_Owner_for_Hold_Status</template>
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
        <fullName>Email_Alert_To_Wish_Granter</fullName>
        <description>Case:Send email to both wish granters assigned to wish if 14 days from wish end date and wish granted tasks are open</description>
        <protected>false</protected>
        <recipients>
            <recipient>Wish Granter</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Email_alert_to_wish_granters</template>
    </alerts>
    <alerts>
        <fullName>Reminder_to_enter_the_Wish_Presentation_Date</fullName>
        <description>Reminder to enter the Wish Presentation Date</description>
        <protected>false</protected>
        <recipients>
            <recipient>Wish Granter</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Test_Email_Templete</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_MAC_Team</fullName>
        <description>Send Email to MAC Team</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Communication_with_the_Local_Medical_Advisor_Council</template>
    </alerts>
    <alerts>
        <fullName>Send_Reply_email_to_MAC_team</fullName>
        <description>Send Reply email to MAC team</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Reply_Email_template_to_MAC_Team</template>
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
    <alerts>
        <fullName>Wish_Family_Form_Not_Submitted_Alert</fullName>
        <description>Wish Family Form Not Submitted Alert</description>
        <protected>false</protected>
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
        <template>unfiled$public/Wish_Family_Form_Not_Submitted_Template</template>
    </alerts>
    <alerts>
        <fullName>Wish_Interview_21_days_alert</fullName>
        <description>Wish:Interview 21 days alert</description>
        <protected>false</protected>
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
        <template>unfiled$public/Wish_Interview_21_Days_Template</template>
    </alerts>
    <alerts>
        <fullName>Wish_Interview_Date_Not_Set_After_21_Days_Email_Alert</fullName>
        <description>Wish Interview Date Not Set After 21 Days Email Alert</description>
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
        <template>unfiled$public/Wish_Interview_21_Days_Template</template>
    </alerts>
    <alerts>
        <fullName>Wish_Presentation_Set_is_checked</fullName>
        <description>Wish Presentation Set is checked</description>
        <protected>false</protected>
        <recipients>
            <field>Dev_Staff_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Test_Email_Templete</template>
    </alerts>
    <alerts>
        <fullName>Wish_not_closed_Email_Alert</fullName>
        <description>Wish not closed-Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Test_Email_Templete</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Budget_Approved</fullName>
        <description>Used to update the approval status to approved</description>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Case:Budget Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Budget_Recalled</fullName>
        <description>Use to set the Budget Approval status picklist to none if the approval process is recalled</description>
        <field>Budget_Approval_Status__c</field>
        <name>Case:Budget Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Budget_Rejected</fullName>
        <description>This field update is used to when the chapter staff reject the budget form.</description>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Case: Budget Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Budget_Submitted</fullName>
        <description>Used to change the Budget approval status field to submitted</description>
        <field>Budget_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Case:Budget Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusDate</fullName>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>UpdateStatusDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
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
        <fullName>Update_Wish_Child_Form</fullName>
        <description>This field will update as True when the user approve the wish.</description>
        <field>Update_Wish_Child_Form_Info__c</field>
        <literalValue>1</literalValue>
        <name>Update Wish Child Form</name>
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
        <fullName>Case%3A Budget is submitted</fullName>
        <actions>
            <name>Case_Budget_Submitted_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Budget_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <description>This rule will fire when the budget is submitted for approval process.</description>
        <triggerType>onAllChanges</triggerType>
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
        <formula>OR(AND(isEmail__c  = TRUE,ISCHANGED(isEmail__c)),AND(ISCHANGED(isNational__c), isNational__c = TRUE))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A On Hold Email Notification for Wish Owner</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <description>Send an email alert to the wish owner 6 months after the Hold Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Send_an_Email_Alert_to_Case_Owner_for_On_Hold_Status</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Hold_Date__c</offsetFromField>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case%3A Wish Granted Task Open Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.isWishGrantTasksClosed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to both wish granters assigned to wish if 14 days from wish end date and wish granted tasks are open</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_To_Wish_Granter</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
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
        <fullName>InActive Wish Granter Alert Workflow Rule</fullName>
        <actions>
            <name>Case_Send_Email_to_Wish_Granter_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.isEmailWishGranter__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.InActiveWishGranter__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This Email alert is used to send an email to wish granters.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reminder to enter the Wish Presentation Date</fullName>
        <actions>
            <name>Reminder_to_enter_the_Wish_Presentation_Date</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Interview_Date_Not_Set__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Granted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Presentation_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send reply email to MAC team</fullName>
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
        <fullName>Update_DateStatus</fullName>
        <actions>
            <name>UpdateStatusDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( Status ),ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Wish %3A InActive Wish Granter Alert Workflow Rule</fullName>
        <actions>
            <name>Case_Send_Email_to_Wish_Granter_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.isEmailWishGranter__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.InActiveWishGranter__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>This Email alert is used to send an email to wish granters</description>
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
    <rules>
        <fullName>Wish Family Form Not Submitted Alert Rule</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Wish_Family_Form__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will fire when there is no wish family form submitted for particular time period</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_Family_Form_Not_Submitted_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Interview_date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Wish Presentation Set is checked</fullName>
        <actions>
            <name>Wish_Presentation_Set_is_checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Presentation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Wish_Presentation_Set__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send a auto email when Wish Presentation Set is checked and Wish Presentation Date is entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Wish not closed</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email to wish owner when case not closed after 90 days from wish end date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_not_closed_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>91</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Wish not closed in a specific time</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will fire if the case not closed after 90 days from the case end date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_not_closed</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>31</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_not_closed_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>91</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Wish%3A Task For Family Form Not Submitted</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Wish_Family_Form__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_Family_Packet_not_submitted</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Interview_date__c</offsetFromField>
            <timeLength>6</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Wish%3AConcept approval</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Update_Wish_Child_Form_Info__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Wish Determined</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>notEqual</operation>
            <value>Within Policy</value>
        </criteriaItems>
        <description>Generates task 5 days from when wish family packet is accepted and wish status not equal to Wish Determined - Within policy</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Wish_concept_approval</name>
                <type>Task</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Wish%3AInterview Date Not Set After 21 Days</fullName>
        <actions>
            <name>Wish_Interview_Date_Not_Set_After_21_Days_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Interview_date_not_set</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Interview_Date_Not_Set__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will fire if the interview date is not yet set after 21 days from the case created date</description>
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
    <tasks>
        <fullName>Budget_is_approved</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Budget is approved</subject>
    </tasks>
    <tasks>
        <fullName>Budget_needs_to_be_revised</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Budget needs to be revised</subject>
    </tasks>
    <tasks>
        <fullName>Interview_date_not_set</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Interview date not set</subject>
    </tasks>
    <tasks>
        <fullName>Wish_Family_Packet_not_submitted</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Wish Family Packet not submitted</subject>
    </tasks>
    <tasks>
        <fullName>Wish_concept_approval</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>6</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Wish concept approval</subject>
    </tasks>
    <tasks>
        <fullName>Wish_not_closed</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>32</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.End_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Wish not closed</subject>
    </tasks>
</Workflow>
