<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>This_Email_Alert_will_send_when_the_Non_Wish_volunteer_opportunity_is_Approved_b</fullName>
        <description>This Email Alert will send when the Non - Wish volunteer opportunity is Approved by the chapter staff</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Volunteer_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Volunteer_Opportunity_Non_Wish_Approved</template>
    </alerts>
    <alerts>
        <fullName>This_Email_Alert_will_send_when_the_Non_Wish_volunteer_opportunity_is_rejected_b</fullName>
        <description>This Email Alert will send when the Non - Wish volunteer opportunity is rejected by the chapter staff</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Volunteer_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Volunteer_Opportunity_Non_Wish_Rejected</template>
    </alerts>
    <alerts>
        <fullName>This_Email_Alert_will_send_when_the_Wish_volunteer_opportunity_is_Approved_by_th</fullName>
        <description>This Email Alert will send when the Wish volunteer opportunity is Approved by the chapter staff</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Volunteer_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Volunteer_Opportunity_Wish_Approved</template>
    </alerts>
    <alerts>
        <fullName>This_Email_Alert_will_send_when_the_Wish_volunteer_opportunity_is_rejected_by_th</fullName>
        <description>This Email Alert will send when the Wish volunteer opportunity is rejected by the chapter staff</description>
        <protected>false</protected>
        <recipients>
            <field>Hidden_Volunteer_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wvc@wish.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Volunteer_Opportunity_Wish_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Uncheck_Rejected</fullName>
        <description>Used to uncheck the rejected checkbox</description>
        <field>isRejected__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIsApprove</fullName>
        <description>This field update is used to check the IsApproved field.</description>
        <field>IsApproved__c</field>
        <literalValue>1</literalValue>
        <name>UpdateIsApprove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rejected_Field</fullName>
        <description>Check the isRejected field when the user Reject the Volunteer Role Approval Process.</description>
        <field>isRejected__c</field>
        <literalValue>1</literalValue>
        <name>Update Rejected Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VolunteerOpportunity_Uncheck_IsApprove</fullName>
        <description>It is used to uncheck the isApprove checkbox in volunteer Opportunity</description>
        <field>IsApproved__c</field>
        <literalValue>0</literalValue>
        <name>VolunteerOpportunity:Uncheck IsApprove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity</fullName>
        <description>This field update is used to update the Status field as Pending  When the volunteer registers for the Volunteer Opportunity from the community.</description>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>VolunteerOpportunity:ChangeStatusPending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_Approval_Initiated</fullName>
        <description>Volunteer Opportunity Approval Process initiated</description>
        <field>Approval_Status__c</field>
        <literalValue>Initiated</literalValue>
        <name>Volunteer Opportunity:Approval Initiated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_Approved</fullName>
        <description>Volunteer Opportunity is approved for volunteer</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Volunteer Opportunity : Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_ChangeStatusApprov</fullName>
        <description>This field update is used to update the Status field as Approved When the volunteer opportunity is approved by the chapter staff.</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>VolunteerOpportunity:ChangeStatusApprove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_ChangeStatusInacti</fullName>
        <description>This field update is used to set the status field value is Inactive when the user enter the reason for inactive.</description>
        <field>Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Volunteer Opportunity:ChangeStatusInacti</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_MyAssignment_Rem</fullName>
        <description>Used to remove the view access of rejected record under my assignment tab for volunteer</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Volunteer Opportunity : MyAssignment Rem</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Volunteer_Opportunity_Rejection_Period</fullName>
        <description>Volunteer opportunity not approved for volunteers</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejection Notification</literalValue>
        <name>Volunteer Opportunity : Rejection Period</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Volunteer Opportunity %3A MyAssignment Removal</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Opportunity__c.isRejected__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used to remove volunteer opportunities rejected record from Volunteer My Assignment after 30 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Volunteer_Opportunity_MyAssignment_Rem</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Volunteer Opportunity %3A Non - Wish Approved</fullName>
        <actions>
            <name>This_Email_Alert_will_send_when_the_Non_Wish_volunteer_opportunity_is_Approved_b</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Work flow rule will fire when the Volunteer opportunity Non - Wish is Approved by the chapter staff.</description>
        <formula>AND( Volunteer_Name__c != Null, Wish__c  == Null, Non_Wish_Event__c != Null, IsApproved__c  = true, ISCHANGED(IsApproved__c ),isRejected__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Volunteer Opportunity %3A Non - Wish Rejected</fullName>
        <actions>
            <name>This_Email_Alert_will_send_when_the_Non_Wish_volunteer_opportunity_is_rejected_b</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Work flow rule will fire when the Volunteer opportunity Non - Wish is rejected by the chapter staff.</description>
        <formula>AND( Volunteer_Name__c != Null, Wish__c  == Null, Non_Wish_Event__c != Null, IsApproved__c  = false, isRejected__c = true,ISCHANGED(isRejected__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Volunteer Opportunity %3A Wish Approved</fullName>
        <actions>
            <name>This_Email_Alert_will_send_when_the_Wish_volunteer_opportunity_is_Approved_by_th</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Work flow rule will fire when the Volunteer opportunity Wish is Approved by the chapter staff.</description>
        <formula>AND( Volunteer_Name__c != Null, Wish__c  != Null, Non_Wish_Event__c == Null, IsApproved__c  = true, ISCHANGED(IsApproved__c),isRejected__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Volunteer Opportunity %3A Wish Rejected</fullName>
        <actions>
            <name>This_Email_Alert_will_send_when_the_Wish_volunteer_opportunity_is_rejected_by_th</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Work flow rule will fire when the Volunteer opportunity Wish is Approved by the chapter staff.</description>
        <formula>AND( Volunteer_Name__c != Null, Wish__c  != Null, Non_Wish_Event__c == Null,IsApproved__c  = false, isRejected__c = true, ISCHANGED(isRejected__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Volunteer Opportunity%3AChangeStatusInactiveWorkflowRule</fullName>
        <actions>
            <name>Volunteer_Opportunity_ChangeStatusInacti</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Opportunity__c.Reason_Inactive__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Opportunity__c.Inactive__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow rule fire when inactive check box is checked and user enter the reason for inactive.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
