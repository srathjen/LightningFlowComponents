<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Diagnosis_Form_Email_Alert</fullName>
        <description>Diagnosis Form Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>HiddenMedicalProfessionalEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Part_A_Form_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Diagnosis_Form_Email_Alert_for_Best_Physician_contact</fullName>
        <description>Diagnosis Form Email Alert for Best Physician contact</description>
        <protected>false</protected>
        <recipients>
            <field>Best_contact_for_Physician_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Part_A_Form_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Duplicate_Lead_Referral_Inquiry_Alert</fullName>
        <description>Duplicate Lead Referral / Inquiry Alert</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <field>Intake_Manager_For_Dupe_Alert__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Eligibility_Emails/Duplicate_on_Referral_Inquiry_Email</template>
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
        <template>Automated_Wish_Granting_Email_Templates/Lead_Email_Notification_for_Lead_Owner</template>
    </alerts>
    <alerts>
        <fullName>Lead_Email_Alert_to_Qualifying_Medical_Professional_when_child_is_NOT_eligible</fullName>
        <description>Lead:Email Alert to Qualifying Medical Professional when child is NOT eligible</description>
        <protected>false</protected>
        <recipients>
            <field>Treating_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Professional_Email_Templates/Med_Professional_Your_patient_was_referred_for_a_wish</template>
    </alerts>
    <alerts>
        <fullName>Lead_Email_Alert_to_Qualifying_Medical_Professional_when_child_is_eligible</fullName>
        <description>Lead:Email Alert to Qualifying Medical Professional when child is eligible</description>
        <protected>false</protected>
        <recipients>
            <field>Best_contact_for_Physician_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Treating_Medical_Professional_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Professional_Email_Templates/Med_Professional_Your_patient_is_eligible_for_a_wish</template>
    </alerts>
    <alerts>
        <fullName>Lead_Notify_owner_Qualified_RUSH_lead</fullName>
        <description>Lead: Notify owner Qualified RUSH lead</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Eligibility_Emails/Lead_Notify_owner_Qualified_RUSH_lead</template>
    </alerts>
    <alerts>
        <fullName>Lead_Notify_owner_new_RUSH_lead</fullName>
        <description>Lead: Notify owner new RUSH lead</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Medical_Eligibility_Emails/Lead_Notify_owner_new_RUSH_lead</template>
    </alerts>
    <alerts>
        <fullName>Lead_Referral_Confirmation_Email_Sent_to_Referrer</fullName>
        <ccEmails>missionresources@wish.org</ccEmails>
        <description>Lead: Referral Confirmation Email Sent to Referrer</description>
        <protected>false</protected>
        <recipients>
            <field>Referrer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Wish_Granting_Email_Templates/Send_Referral_Confirmation_to_Referrer</template>
    </alerts>
    <alerts>
        <fullName>Lead_Send_Email_to_Lead_Owner_when_Child_turns_2_5</fullName>
        <ccEmails>salesforce@wish.org</ccEmails>
        <description>Lead: Send Email to Lead Owner when Child turns 2.5</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Wish_Granting_Email_Templates/Lead_Email_Notification_for_Lead_Owner_of_Lead_Age_2_5</template>
    </alerts>
    <alerts>
        <fullName>Send_DV_Signature_Reminder_to_Medical_Professional_Final_Notice</fullName>
        <description>Send DV Signature Reminder to Medical Professional- Final Notice</description>
        <protected>false</protected>
        <recipients>
            <field>HiddenMedicalProfessionalEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DV_Reminder_Form_Email_Template_Final</template>
    </alerts>
    <alerts>
        <fullName>Send_DV_Signature_Reminder_to_Medical_Professional_First_Notice</fullName>
        <description>Send DV Signature Reminder to Medical Professional- First Notice</description>
        <protected>false</protected>
        <recipients>
            <field>HiddenMedicalProfessionalEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DV_Reminder_Form_Email_Template_First</template>
    </alerts>
    <alerts>
        <fullName>Send_DV_Signature_Reminder_to_Medical_Professional_Intake_Manager</fullName>
        <description>Send DV Signature Alert to Intake Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DV_Reminder_Form_Email_Template_IntakeManager</template>
    </alerts>
    <alerts>
        <fullName>Send_DV_Signature_Reminder_to_Medical_Professional_Second_Notice</fullName>
        <description>Send DV Signature Reminder to Medical Professional- Second Notice</description>
        <protected>false</protected>
        <recipients>
            <field>HiddenMedicalProfessionalEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/DV_Reminder_Form_Email_Template_Second</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Office_Referrar_email_with_Wish_Referral_Form</fullName> <fieldUpdates>
        <fullName>Additional_Parent_Guardian_Phone</fullName>
        <field>Additional_Parent_Phone__c</field>
        <formula>IF(
ISBLANK(Additional_Parent_Phone__c),
&apos;&apos;,
IF(
LEN(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;))= 11,
&quot;(&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),2,3)&amp;
&quot;) &quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),5,3)&amp;
&quot;-&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),8,4),
&quot;(&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),1,3)&amp;
&quot;) &quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),4,3)&amp;
&quot;-&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Additional_Parent_Phone__c , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),7,4)
)
)</formula>
        <name>Additional Parent/Guardian Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_Phone_Update</fullName>
        <field>Alternate1MedProfessionalPhone__c</field>
        <formula>&apos;&apos;</formula>
        <name>Alt Phone Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Format_Standard_Lead_Phone</fullName>
        <description>SIW-147 this is to support the duplicate check to match with custom duplicate rules - format standard lead phone to (XXX) XXX-XXXX</description>
        <field>Phone</field>
        <formula>IF(
LEN(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;))= 11,
&quot;(&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),2,3)&amp;
&quot;) &quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),5,3)&amp;
&quot;-&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),8,4),
&quot;(&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),1,3)&amp;
&quot;) &quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),4,3)&amp;
&quot;-&quot;&amp;
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE( Phone , &quot;.&quot;, &apos;&apos;),&quot;-&quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;),7,4)
)</formula>
        <name>Update Standard Lead Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
        <ccEmails>missionresources@wish.org</ccEmails>
        <description>Send Email to Office Referrar email with Wish Referral Form</description>
        <protected>false</protected>
        <recipients>
            <field>Office_Referral_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Wish_Granting_Email_Templates/Send_Wish_Referral_Form_to_Non_Active_Chapter_Office</template>
    </alerts>

    <fieldUpdates>
        <fullName>Populate_Date_of_Birth_Lead</fullName>
        <description>SIW-147 - Duplicate logic</description>
        <field>DOB_Text__c</field>
        <formula>TEXT(DOB__c)</formula>
        <name>Populate Date of Birth- Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Untick_Duplicate_Referral_Email</fullName>
        <description>Untick the Duplicate Referral Email tickbox</description>
        <field>Lead_Owner_Dupe_Alert__c</field>
        <literalValue>0</literalValue>
        <name>Untick Duplicate Referral Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Email Notification for Wish Child Lead Owner</fullName>
        <actions>
            <name>Lead_Email_Alert_for_Lead_Owner_Regarding_Chapter_Update</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lead_ET_Chapter_has_been_changed</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Whenever chapter updates based on the Postal Code, It will send an email notification to the Wish Child Lead Owner.</description>
        <formula>(ISCHANGED(Hidden_Chapter_Change_Confirmation__c) &amp;&amp; NOT(ISCHANGED(ChapterName__c)) &amp;&amp; 
$Profile.Name != 'Integration')
&amp;&amp;
RecordType.Name = "Wish Child"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Email Notification to Referrer</fullName>
        <actions>
            <name>Lead_Referral_Confirmation_Email_Sent_to_Referrer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lead_ET_We_ve_Received_your_Referral_Inquiry</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Company</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.unique_wish_identifier__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Referrer_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>Send email confirmation of referral form submission to Referrer.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Email Notification when Wish Child turns 2%2E5</fullName>
        <actions>
            <name>Lead_Send_Email_to_Lead_Owner_when_Child_turns_2_5</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Inquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Age_Requirement_Met__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>When a wish child turns 2.5, a batch job leadChildAge will update the lead hidden AgeRequirementMet checkbox to TRUE for Leads in the Inquiry status it will send an email notification to the lead owner.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Lead Phone Number format</fullName>
        <actions>
            <name>Additional_Parent_Guardian_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Alt_Phone_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Format_Standard_Lead_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This is in place to update the phone to a standard phone format for Duplicate Rule Matching
Converts this: 6043458787 --&gt;  (604) 345-8787</description>
        <formula>(AND
(NOT(AND(LEN(Phone) == 14,
LEFT(Phone,1) == '(',       
ISNUMBER(LEFT(RIGHT(Phone,13),3)),       
LEFT(RIGHT(Phone,10),1) == ')',       
LEFT(RIGHT(Phone,9),1) == ' ',       
ISNUMBER(LEFT(RIGHT(Phone,8),3)),       
LEFT(RIGHT(Phone,5),1) == '-',       
ISNUMBER(RIGHT(Phone,4))     )   ),    
ISNUMBER(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone , ".", ''),"-",""),"+","")),    
OR(     
LEN(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone ,".",''),"-",""),"+",""))=10,     
AND(LEN(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone,".",''),"-",""),"+",""))=11,       
LEFT(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone ,".",''),"-",""),"+",""),1)="1"     )   ) )) 
&amp;&amp;  
RecordType.Name = "Wish Child"</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Notify new RUSH lead</fullName>
        <actions>
            <name>Lead_Notify_owner_new_RUSH_lead</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lead_ET_New_Rush_Referral</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Any_medical_reason_for_moving_quickly__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>Notify the lead owner whenever a lead is created with Is there a medical reason to move quickly field equal to 'Yes'</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Notify owner Qualified RUSH Lead</fullName>
        <actions>
            <name>Lead_Notify_owner_Qualified_RUSH_lead</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Any_medical_reason_for_moving_quickly__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>Notify the lead owner when a RUSH lead is qualified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Populate Date of Birth- Lead</fullName>
        <actions>
            <name>Populate_Date_of_Birth_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIW-147 This supports Duplication check: Capture Information when a duplicate referral is submitted- matching rules do not support date fields.</description>
        <formula>OR(ISNEW(), ISCHANGED(DOB__c)) &amp;&amp;  RecordType.Name = "Wish Child"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Qualifying Medical Professional when child is eligible</fullName>
        <actions>
            <name>Lead_Email_Alert_to_Qualifying_Medical_Professional_when_child_is_eligible</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lead_ET_Your_patient_is_eligible_for_a_wish</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.unique_wish_identifier__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>It send a email notification to  Qualifying Medical Professional when child is eligible</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead %28Wish Child%29%3A Send Duplicate Referral Email Alert</fullName>
        <actions>
            <name>Duplicate_Lead_Referral_Inquiry_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Untick_Duplicate_Referral_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Lead_Owner_Dupe_Alert__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wish Child</value>
        </criteriaItems>
        <description>Send Duplicate Referral Email Alert if Duplicate Lead Found</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead%3AQualifying Medical Professional when child is NOT eligible</fullName>
        <actions>
            <name>Send_DNQ_Notification_to_Qualifying_Medical_Professional</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>DNQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <description>It send a email notification to Qualifying Medical Professional when child is NOT eligible.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send DV Signature Reminder to Medical Professional</fullName>
        <active>true</active>
        <description>SIW-432</description>
        <formula>ISBLANK(Provider_Signature__c) &amp;&amp; DV_Present__c = True &amp;&amp; Chapter_Name__c != 'Make-A-Wish Arizona'</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_DV_Signature_Reminder_to_Medical_Professional_Second_Notice</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_DV_Signature_Reminder_to_Medical_Professional_Intake_Manager</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_DV_Signature_Reminder_to_Medical_Professional_Final_Notice</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_DV_Signature_Reminder_to_Medical_Professional_First_Notice</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Lead_ET_Chapter_has_been_changed</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Lead ET : Chapter has been changed</subject>
    </tasks>
    <tasks>
        <fullName>Lead_ET_New_Rush_Referral</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <description>New RUSH referral email alert has been sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Lead ET : New Rush Referral</subject>
    </tasks>
    <tasks>
        <fullName>Lead_ET_We_ve_Received_your_Referral_Inquiry</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Confirmation of Referral Form submission emailed to Referrer email.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Lead ET : We've Received your Referral Inquiry</subject>
    </tasks>
    <tasks>
        <fullName>Lead_ET_Your_patient_is_eligible_for_a_wish</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Lead ET : Your patient is eligible for a wish!</subject>
    </tasks>
    <tasks>
        <fullName>Lead_ET_Your_patient_was_referred_for_a_wish</fullName>
        <assignedTo>salesforce@wish.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>User.Today_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Lead ET : Your patient was referred for a wish</subject>
    </tasks>
    <tasks>
        <fullName>Send_DNQ_Notification_to_Qualifying_Medical_Professional</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send DNQ Notification to Qualifying Medical Professional</subject>
    </tasks>
</Workflow>
