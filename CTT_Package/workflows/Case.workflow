<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_For_Guided_Script</fullName>
        <description>Send Email For Guided Script</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Privacy_Act_Notice_Contact_Tracing</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Interview_Completed_Date</fullName>
        <description>Add timestamp of when the interview was completed by the agent.</description>
        <field>Interview_Completed_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Interview Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Outcome_to_DIED</fullName>
        <field>Outcome__c</field>
        <formula>&quot;DIED&quot;</formula>
        <name>Update Case Outcome to DIED</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Presumptive</fullName>
        <field>Presumptive__c</field>
        <literalValue>0</literalValue>
        <name>Update Case Presumptive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Subject</fullName>
        <field>Subject</field>
        <formula>&quot;Self-Reported Positive&quot;</formula>
        <name>Update Case Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Positive_Outreach_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Positive_Outreach</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to Positive Outreach Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check Case is Posititve</fullName>
        <actions>
            <name>Update_Case_Presumptive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Test_Status__c</field>
            <operation>equals</operation>
            <value>Positive</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Complete Interview</fullName>
        <actions>
            <name>Set_Interview_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Outreach_Outcome__c),ISPICKVAL(Outreach_Outcome__c,&apos;Completed&apos;), ISBLANK(Interview_Completed_Date__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Convert Contact Outreach to Positive Outreach</fullName>
        <actions>
            <name>Update_Case_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_Positive_Outreach_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TEXT(Self_Reported_Test_Outcome__c) = &quot;Positive&quot; &amp;&amp; ISCHANGED( Self_Reported_Test_Outcome__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Handle Case Deaths</fullName>
        <actions>
            <name>Update_Case_Outcome_to_DIED</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Case.Outcome__c to DIED When Closed Reason == &apos;Died</description>
        <formula>TEXT(Close_Reason__c) == &apos;Died&apos; &amp;&amp; ISBLANK(Outcome__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
