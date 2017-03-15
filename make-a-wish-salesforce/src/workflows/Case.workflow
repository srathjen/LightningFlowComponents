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
        <fullName>Case_Email_Alert_to_Qualifying_Medical_Professional_when_wish_is_determined</fullName>
        <description>Case:Email Alert to Qualifying Medical Professional when wish is determined.</description>
        <protected>false</protected>
        <recipients>
            <field>Qualifying_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvcsupport@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Professional_Email_Templates/Med_Professional_Your_patient_decided_on_a_wish</template>
    </alerts>
    <alerts>
        <fullName>Case_Email_Alert_to_Qualifying_Medical_Professional_when_wish_is_granted</fullName>
        <description>Case:Email Alert to Qualifying Medical Professional when wish is granted</description>
        <protected>false</protected>
        <recipients>
            <field>Qualifying_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Professional_Email_Templates/Med_Professional_Your_patient_s_wish_has_been_fulfilled</template>
    </alerts>
    <alerts>
        <fullName>Case_Rush_Wish_Reminder_Alerts</fullName>
        <description>Case:Rush Wish Reminder &amp; Alerts</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Contact_Rush_Wish_Reminder_Alerts</template>
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
        <fullName>Rush_Wish_Child_Summary_Alert</fullName>
        <description>Rush Wish Child Summary Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Qualifying_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/RUSH_Child_Medical_Summary</template>
    </alerts>
    <alerts>
        <fullName>Rush_Wish_Clarence_Alert</fullName>
        <description>Rush Wish Clarence Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Qualifying_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/RUSH_Wish_Clearance</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_MAC_Team</fullName>
        <description>Send Email to MAC Team</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvcsupport@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Email_to_Loacl_MAC_Team_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Reply_Emal_to_National_MAC_team_Alert</fullName>
        <description>Send Reply Emal to National MAC team Alert</description>
        <protected>false</protected>
        <recipients>
            <field>MAC_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvcsupport@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Reply_Email_to_National_MAC_Team_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Reply_email_to_MAC_team</fullName>
        <description>Send Reply email to MAC team</description>
        <protected>false</protected>
        <recipients>
            <field>Chapter_MACEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvcsupport@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Reply_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Wish_Family_Form_Not_Submitted_Alert</fullName>
        <description>Wish Family Form Not Submitted Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Wish_Family_Form_Not_Submitted_Template</template>
    </alerts>
    <alerts>
        <fullName>Wish_Interview_Date_Not_Set_After_21_Days_Email_Alert</fullName>
        <ccEmails>chandrasekar@mstsolutions.com</ccEmails>
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
        <fullName>UpdateIsRushWishChild</fullName>
        <field>IsRushChildSummary__c</field>
        <literalValue>0</literalValue>
        <name>UpdateIsRushWishChild</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIsRushWishClearence</fullName>
        <field>IsRushWishClearence_ChildSummary__c</field>
        <literalValue>0</literalValue>
        <name>UpdateIsRushWishClearence</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
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
        <active>false</active>
        <formula>AND(isEmail__c  = TRUE,ISCHANGED(isEmail__c), Migrated_Record__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3ABirthday Task</fullName>
        <active>true</active>
        <description>This workflow will create Task to Volunteer for Wish Child Birthday</description>
        <formula>If( Month(Birthdate__c)==2 &amp;&amp; Day(Birthdate__c)==29 ,  	If((MOD(YEAR(Today()), 400 ) = 0 || ( MOD(YEAR(Today()),4) = 0 &amp;&amp; MOD(YEAR(Today()), 100 ) != 0) ),  		(DATE(YEAR(Today()),Month(Birthdate__c),Day(Birthdate__c)) &gt; (Today()) ) &amp;&amp; (Text(Status) != &apos;Closed&apos;) &amp;&amp; (RecordType.DeveloperName = &apos;Wish&apos;) , 			(DATE(YEAR(Today()),Month(Birthdate__c),Day(Birthdate__c-1)) &gt; (Today()) ) &amp;&amp; (Text(Status) != &apos;Closed&apos;) &amp;&amp; (RecordType.DeveloperName = &apos;Wish&apos;) ) , 	(DATE(YEAR(Today()),Month(Birthdate__c),Day(Birthdate__c)) &gt; (Today()) ) &amp;&amp; (Text(Status) != &apos;Closed&apos;) &amp;&amp; (RecordType.DeveloperName = &apos;Wish&apos;))</formula>
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
        <fullName>Case%3AFollow-up on wish clearance</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Wish_Clearance_Sent_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Wish_Clearance_Received_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Used to create a task to Chapter Staff if Wish Clearance received is null after 14 days the form sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Follow_up_on_wish_clearance</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Wish_Clearance_Sent_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case%3AQualifying Medical Professional when wish is determined</fullName>
        <actions>
            <name>Case_Email_Alert_to_Qualifying_Medical_Professional_when_wish_is_determined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Wish Determined</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>It send a email notification to Qualifying Medical Professional when wish is determined.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case%3AQualifying Medical Professional when wish is granted</fullName>
        <actions>
            <name>Case_Email_Alert_to_Qualifying_Medical_Professional_when_wish_is_granted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Granted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case%3ARush Wish Reminder %26 Alerts</fullName>
        <actions>
            <name>Case_Rush_Wish_Reminder_Alerts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Rush__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Used to send an alert for contact owner when the Rush field is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rush Wish Child Summary Rule</fullName>
        <actions>
            <name>Rush_Wish_Child_Summary_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateIsRushWishChild</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsRushChildSummary__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule will fire when rush is checked and if admin send the email to medical professional from wish medical summary.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Rush Wish Clarence Rule</fullName>
        <actions>
            <name>Rush_Wish_Clarence_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateIsRushWishClearence</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsRushWishClearence_ChildSummary__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule will fire when rush  is checked and if you send the email to medical professional  from wish clearence.</description>
        <triggerType>onAllChanges</triggerType>
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
        <active>false</active>
        <description>This rule will fire when the isNational check box is checked.</description>
        <formula>AND(isNational__c = TRUE,ISCHANGED(isNational__c), Migrated_Record__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Reply Email to National MAC Team</fullName>
        <actions>
            <name>Send_Reply_Emal_to_National_MAC_team_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This work flow will fire when the national mac team reply to the case comment.</description>
        <formula>AND(NOT(ISNULL(MAC_Email__c)),ISCHANGED(Case_Comment__c),(isNational__c = true),(isNationalReply__c = true),( Migrated_Record__c = false),RecordType.DeveloperName =&apos;Diagnosis_Verification_Review&apos;)</formula>
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
        <formula>AND(ISCHANGED(Case_Comment__c),isNational__c = false, isEmail__c = true,Migrated_Record__c = false, RecordType.DeveloperName =&apos;Diagnosis_Verification_Review&apos;)</formula>
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
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
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
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Migrated_Record__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This Email alert is used to send an email to wish granters</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
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
        <fullName>Wish%3AInterview Date Not Set After 21 Days</fullName>
        <actions>
            <name>Wish_Interview_Date_Not_Set_After_21_Days_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Interview_date_not_set</name>
            <type>Task</type>
        </actions>
        <active>false</active>
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
        <fullName>Follow_up_on_wish_clearance</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>17</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.Wish_Clearance_Sent_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow-up on wish clearance</subject>
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
</Workflow>