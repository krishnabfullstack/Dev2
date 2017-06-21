<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Contact_Unique_Key</fullName>
        <description>Sets the Contact Unique Key based on the User__c field.</description>
        <field>Unique_Key__c</field>
        <formula>User__r.Id</formula>
        <name>Set Contact Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact%3A Create Update</fullName>
        <actions>
            <name>Set_Contact_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule is executed every time a Contact is created or updated.</description>
        <formula>NOT(ISBLANK(Id))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
