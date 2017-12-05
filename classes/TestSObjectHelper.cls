/***************************************************************************************************
Class    :  TestSObjectHelper.cls
Developer:  Mickey Murphy, Blue Wolf Group LLC
Created  :  June 18, 2013
Modified :  July 18, 2013
Objective:  This class provides methods to test SObjectHelper.cls.

***************************************************************************************************/

@isTest
public class TestSObjectHelper
{
    //  methods listed in alphabetical order
    static testMethod void testDescribe ()
    {
        SObjectHelper plugin                = new SObjectHelper ();
        Process.PluginDescribeResult result = plugin.describe ();
        System.AssertEquals (result.inputParameters.size  (), 1);
        System.AssertEquals (result.OutputParameters.size (), 3);

    }   //  testDescribe ()

    static testMethod void testInvoke ()
    {
        Account account = new Account ();
        SObjectHelper plugin              = new SObjectHelper ();
        Map <String, Object> inputParams  = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();

        account.Name = 'Blue Wolf Group';
        insert account;
        inputParams.put ('inputRecordId', account.Id);
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult  result  = plugin.invoke (request);
        System.assertEquals (result.outputparameters.get ('isCustomSetting'), false);
        System.assertEquals (result.outputparameters.get ('sobjectId')      , account.Id);
        System.assertEquals (result.outputparameters.get ('sobjectName')    , 'Account');

    }   //  testInvoke ()

}