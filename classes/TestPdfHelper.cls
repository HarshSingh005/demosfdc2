/***************************************************************************************************
Class    :  TestPdfHelper.cls
Developer:  Raja, salesforce.com, inc.
Created  :  August 13, 2012
Modified :  June 18, 2013
Objective:  This class provides methods to test PdfHelper.cls.

***************************************************************************************************/

@isTest
public class TestPdfHelper
{
    static testMethod void testPositiveCase ()
    {
        Lead testLead = getTestLead ();
        PdfHelper plugin = new PdfHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', testLead.ID);
        inputParams.put ('pdfAttachmentName', 'PDF Attachment');
        inputParams.put ('pdfAttachmentContent', 'This is a test.');
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.OutputParameters.get ('Status'), 'SUCCESS');     
        Attachment attachment = [ select name, parentid from attachment where parentid = :testLead.ID ];
        System.AssertEquals (attachment.name, 'PDF Attachment');            

    }   //  testPositiveCase ()

    static testMethod void testNegativeCase ()
    {
        PdfHelper plugin = new PdfHelper ();
        Map <String, Object> inputParams = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();
        inputParams.put ('recordID', 'blah');
        inputParams.put ('pdfAttachmentName', 'PDF Attachment');
        inputParams.put ('pdfAttachmentContent', 'This is a test.');
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result = plugin.invoke (request);
        System.assertEquals (result.OutputParameters.get ('Status'), 'ERROR');     
        
    }   //  testNegativeCase ()

    static testMethod void testDescribe ()
    {
        PdfHelper plugin = new PdfHelper ();
        Process.PluginDescribeResult result = plugin.describe ();
        System.AssertEquals (result.inputParameters.size  (), 3);
        System.AssertEquals (result.OutputParameters.size (), 2);
 
    }   //  testDescribe ()

    private static Lead getTestLead ()
    {
        Lead testLead = new Lead (Company='Test Lead', FirstName='John', LastName='Doe', email='vrajaram@salesforce.com');
        insert testLead;

        return testLead;

    }   //  getTestLead ()

}