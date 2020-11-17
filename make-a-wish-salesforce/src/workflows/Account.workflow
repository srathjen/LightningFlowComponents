<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_In_Kind_Donor_Account_For_Approval_Email_Alert</fullName>
        <description>Account:In Kind Donor Account For Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Wish_Co_ordinator_Hidden_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Wish_Granting_Email_Templates/Account_In_Kind_Donors_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Fire_New_HTF_Owner_Alert</fullName>
        <description>Fire New HTF Owner Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>salesforce@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Automated_Wish_Granting_Email_Templates/Account_HTF_Owner_Changed_Update_New_Owner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Duplicate_Bypass_Equals_False</fullName>
        <description>Reset the account HTF Duplicate Rule Bypass checkbox</description>
        <field>Bypass_HTF_Duplicate_Check__c</field>
        <literalValue>0</literalValue>
        <name>Account Duplicate Bypass Equals False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Kind_Approval_Field_Status_Update</fullName>
        <description>Used to set rejected value to approval field</description>
        <field>In_Kind_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>In-Kind Approval Field Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Is_Approved_Field_Update</fullName>
        <description>This field update is used to update the is approved field in in kind donors record</description>
        <field>Is_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Is Approved Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_In_Kind_Approval_Status</fullName>
        <description>Used to update in kind account status</description>
        <field>In_Kind_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update In-Kind Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account%3A Alert New HTF Owner</fullName>
        <actions>
            <name>Fire_New_HTF_Owner_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Fires an alert to the Intake Manager when an HTF is assigned to their chapter.</description>
        <formula>!ISNEW()
&amp;&amp;
ISCHANGED(Chapter_Name__c)
&amp;&amp;
!ISBLANK(Chapter_Name__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Remove Duplicate Bypass After Create</fullName>
        <actions>
            <name>Account_Duplicate_Bypass_Equals_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Bypass_HTF_Duplicate_Check__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Hospital Treatment Facility</value>
        </criteriaItems>
        <description>Used to remove the HTF Duplicate Rule Bypass leveraged in the M&amp;M function to ensure duplicate checks run on additional updates to the HTF record created.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
