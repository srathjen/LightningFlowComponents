<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
        <formula>IF((Class_Offering__r.RecordType.DeveloperName =&apos;Virtual_Self_Paced&apos;), Today(), Class_Offering__r.Date__c)</formula>
        <name>VolunteerO&amp;T:Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>O%26T%3A Self Faced Orientation Registered Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Orientation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Class_Offering__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Virtual - Self Paced</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>This workflow will fire when the orientation is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>O%26T%3A Self Faced Training Registered Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Class_Offering__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Virtual - Self Paced</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.is_Active_Volunteer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will fire when the training is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3AOrientation Cancelled Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Orientation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Volunteer Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <description>This workflow will fire when the orientation is cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3AOrientation Completed Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Orientation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <description>This workflow will fire when the orientation is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3AOrientation Registered Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Orientation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Class_Offering__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Virtual - Self Paced</value>
        </criteriaItems>
        <description>This workflow will fire when the orientation is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Cancelled Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Volunteer Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <description>This workflow will fire when the training is cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Completed Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.is_Active_Volunteer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will fire when the training is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Registered Workflow Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Class_Offering__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Virtual - Self Paced</value>
        </criteriaItems>
        <description>This workflow will fire when the training is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
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
        <fullName>Training%3A Pending Volunteer%2C Virtual Self Paced Cancelled  Workflow</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Hidden_Volunteer_Training_Status__c</field>
            <operation>equals</operation>
            <value>Volunteer Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Hidden_Volunteer_User_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will fire when the volunteer cancelled the training and if there is not registered training</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Training%3A Pending Volunteer%2C Virtual Self Paced Registered Workflow</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>Integration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Class_Offering__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Virtual - Self Paced</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Hidden_Volunteer_User_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will fired when the prospective volunteer registered for virtual self paced training and not completed  7 &amp; 30 days  after registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
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
