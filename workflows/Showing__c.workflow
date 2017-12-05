<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_the_Show_Name</fullName>
        <field>Name</field>
        <formula>Concatenated_Name__c</formula>
        <name>Set the Show Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Showing Name</fullName>
        <actions>
            <name>Set_the_Show_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the showing name as per the description</description>
        <formula>Name &lt;&gt;Concatenated_Name__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
