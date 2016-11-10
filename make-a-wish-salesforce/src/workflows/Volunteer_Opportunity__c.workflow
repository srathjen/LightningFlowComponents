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
    <rules>
        <fullName>Volunteer Opportunity %3A MyAssignment Removal</fullName>
        <actions>
            <name>VolunteerOpportunity_Uncheck_IsApprove</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Opportunity__c.isRejected__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used to remove volunteer opportunities rejected record from Volunteer My Assignment after 30 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
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
</Workflow>
