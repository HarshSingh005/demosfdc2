<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>E</fullName>
        <description>E</description>
        <protected>false</protected>
        <recipients>
            <recipient>harshsingh1o@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Voucher_Request</template>
    </alerts>
    <outboundMessages>
        <fullName>Exam_email</fullName>
        <apiVersion>41.0</apiVersion>
        <endpointUrl>http://testsiteforapp-developer-edition.ap5.force.com/voucherPage</endpointUrl>
        <fields>Exam_Date__c</fields>
        <fields>Exam_Name__c</fields>
        <fields>Id</fields>
        <fields>User_Email__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>harshsingh1o@gmail.com</integrationUser>
        <name>Exam email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Email for exam</fullName>
        <actions>
            <name>E</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exam__c.User_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
