<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Product_Code</fullName>
        <description>Sets the Product Code field on the Product</description>
        <field>ProductCode</field>
        <formula>Name</formula>
        <name>Set Product Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Product%3A Create Update</fullName>
        <actions>
            <name>Set_Product_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule runs whenever a product is created or updated.</description>
        <formula>NOT(ISBLANK(Id))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
