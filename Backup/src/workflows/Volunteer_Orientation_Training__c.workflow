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
    <rules>
        <fullName>O%26T%3AOrientation Cancelled Workflow Rule</fullName>
        <actions>
            <name>O_T_Orientation_Cancelled_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Orientation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>This workflow will fire when the orientation is cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3AOrientation Completed Workflow Rule</fullName>
        <actions>
            <name>O_T_Orientation_Completed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
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
        <description>This workflow will fire when the orientation is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3AOrientation Registered Workflow Rule</fullName>
        <actions>
            <name>O_T_Orientation_Registered_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
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
        <description>This workflow will fire when the orientation is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Cancelled Workflow Rule</fullName>
        <actions>
            <name>O_T_Training_Cancelled_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Type__c</field>
            <operation>equals</operation>
            <value>Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Orientation_Training__c.Volunteer_Attendance__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>This workflow will fire when the training is cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Completed Workflow Rule</fullName>
        <actions>
            <name>O_T_Training_Completed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
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
        <description>This workflow will fire when the training is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>O%26T%3ATraining Registered Workflow Rule</fullName>
        <actions>
            <name>O_T_Training_Registered_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
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
        <description>This workflow will fire when the training is registered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
