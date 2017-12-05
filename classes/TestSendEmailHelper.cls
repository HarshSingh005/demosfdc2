/***************************************************************************************************
Class    :  TestSendEmailHelper.cls 
Developer:  Raja, salesforce.com, inc.
Created  :  August 13, 2012
Modified :  June 18, 2013
Objective:  This class provides methods to test SendEmailHelper.cls.

***************************************************************************************************/

@isTest
public class TestSendEmailHelper
{
    public static final String SUBJECT = 'Subject of Test Email';
    public static final String SUBJECT1 = 'Subject of Test Email with Only Email Address';
    public static final String BODY = 'BODY of Test Email';
    public static final String EMAIL_ADDRESS = 'blah@blah.org';
    public static final String TEXT_ATTACHMENT_NAME = 'My Text Attachment';
    public static final String TEXT_ATTACHMENT_BODY = 'My Text Attachment BODY';
    public static final String PDF_ATTACHMENT_NAME = 'My PDF Attachment.pdf';
    public static final String PDF_ATTACHMENT_BODY = 'My PDF Attachment BODY';
    public static final String INVALIDID = '000000000000000';    

    static testMethod void testBasicCase ()
    {
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();

        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        inputParams.put('emailAddress','test123@gmail.com');
        inputParams.put('textAttachmentName','dummy');
        inputParams.put('textAttachmentContent','testContent');
        inputParams.put('pdfAttachmentName','test.pdf');
        inputParams.put('pdfAttachmentContent','Pdf content');
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.outputparameters.get ('Status'), 'SUCCESS');
        Task task = [ select subject from task where whoid = :testLead.ID ];
        System.AssertEquals (task.Subject, 'Email: Subject of Test Email');

    }   //  testBasicCase ()
    
    static testMethod void testTextAttachment ()
    {
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID',testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        inputParams.put ('textAttachmentName', TEXT_ATTACHMENT_NAME);
        inputParams.put ('textAttachmentContent', TEXT_ATTACHMENT_BODY);
        Map <String, Object> attachments = new Map <String, Object> ();
		attachments.put(PDF_ATTACHMENT_NAME,PDF_ATTACHMENT_BODY);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.OutputParameters.get ('Status'), 'SUCCESS');
        Attachment attachment = [ select id, name from attachment where parentid = :testLead.ID ];
        System.AssertEquals (attachment.Name, TEXT_ATTACHMENT_NAME);

    }   //  testTextAttachment ()

    static testMethod void testPdfAttachment ()
    {
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        inputParams.put ('pdfAttachmentName', PDF_ATTACHMENT_NAME);
        inputParams.put ('pdfAttachmentContent', PDF_ATTACHMENT_BODY);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.OutputParameters.get ('Status'),'SUCCESS');
        Attachment attachment = [ select id, name from attachment where parentid = :testLead.ID ];
        System.AssertEquals (attachment.Name, PDF_ATTACHMENT_NAME);

    }   //  testPdfAttachment ()

    static testMethod void testEmailWithCc ()
    {
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        inputParams.put ('emailAddress', EMAIL_ADDRESS);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.outputparameters.get ('Status'), 'SUCCESS');
      
    }   //  testEmailWithCc ()

    static testMethod void testAttachmentAndCc ()
    {
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        inputParams.put ('emailAddress', EMAIL_ADDRESS);
        inputParams.put ('textAttachmentName', TEXT_ATTACHMENT_NAME);
        inputParams.put ('textAttachmentContent', TEXT_ATTACHMENT_BODY);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals(result.OutputParameters.get ('Status'), 'SUCCESS');        
        Attachment attachment = [ select id, name from attachment where parentid = :testLead.ID ];
        System.AssertEquals (attachment.Name, TEXT_ATTACHMENT_NAME);

    }   //  testAttachmentAndCc ()

    static testMethod void testAttachment ()
    {
        Lead lead = null;
        Lead testLead = getTestLead ();
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map<String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('emailAddress','test123@gmai.com');
        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', 'testing body');
        inputParams.put ('textAttachmentName', 'textattach');
        inputParams.put ('textAttachmentContent', 'testing text content');
        inputParams.put ('pdfAttachmentName', 'pdfattach');
        inputParams.put ('pdfAttachmentContent', 'testing pdf content');
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginRequest request1 = new Process.PluginRequest (outputParams);
        Process.PluginResult result = plugin.invoke (request);
        Process.PluginResult result1 = plugin.invoke (request1);
        System.assertEquals ([ select count() from attachment where parentid = :testLead.ID ],2);
  //      String nameA = Lead.Attachments [0].Name;
  //      String nameB  =Lead.Attachments [1].Name;
        String nameA = [ select Name from attachment where name like '%text%'].Name;
        String nameB = [ select Name from attachment where name like '%pdf%'].Name;
        System.assert (nameA == 'textattach'    || nameB == 'textattach');
        System.assert (nameA == 'pdfattach.pdf' || nameB == 'pdfattach.pdf');

    }   //  testAttachment ()

    static testMethod void testNegativeCase ()
    {
        SendEmailHelper plugin = new SendEmailHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', INVALIDID);
        inputParams.put ('subject', SUBJECT);
        inputParams.put ('body', BODY);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.outputparameters.get ('Status'), 'ERROR');

    }   //  testNegativeCase ()

    static testMethod void testDescribe ()
    {
        SendEmailHelper plugin = new SendEmailHelper ();
        Process.PluginDescribeResult result = plugin.describe ();
                
        System.AssertEquals (result.InputParameters.size  (), 8);
        System.AssertEquals (result.OutputParameters.size (), 2);

    }   //  testDescribe ()

    private static Lead getTestLead ()
    {
        Lead testLead = new Lead (Company='Test Lead', FirstName='John', LastName='Doe', email='vrajaram@salesforce.com');
        insert testLead;
        return testLead;

    }   //  getTestLead ()

}