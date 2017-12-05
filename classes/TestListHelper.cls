/***************************************************************************************************
Class    :  TestListHelper.cls
Developer:  Raja, salesforce.com, inc.
Created  :  August 13, 2012
Modified :  June 18, 2013
Objective:  This class provides methods to test ListHelper.cls.

/**************************************************************************************************/

@isTest
public class TestListHelper
{
    //  methods listed in alphabetical order
    static testMethod void testDescribe ()
    {
        ListHelper plugin = new ListHelper ();
        Process.PluginDescribeResult result = plugin.describe ();

        System.AssertEquals (result.inputParameters.size  (), 1);
        System.AssertEquals (result.OutputParameters.size (), 3);

    }   //  testDescribe ()

    static testMethod void testInvoke ()
    {    
        ListHelper plugin = new ListHelper ();
        Map <String, Object> inputParams  = new Map <String, Object> ();
        Map <String, Object> outputParams = new Map <String, Object> ();

        //  0 items
        Process.PluginRequest request = new Process.PluginRequest (inputParams);
        Process.PluginResult result;
        result = plugin.invoke (request);

        System.assertEquals (result.outputparameters.get ('nextItem'), null);
        System.assertEquals (result.outputparameters.get ('remainderList'), null);
        System.assertEquals (result.outputparameters.get ('lastItem'), true);

        //  1 item       
        inputParams.clear  ();
        outputParams.clear ();        
        inputParams.put ('inputList', 'item1');
        request = new Process.PluginRequest (inputParams);
        result  = plugin.invoke (request);

        System.assertEquals (result.outputparameters.get ('nextItem'), 'item1');
        System.assertEquals (result.outputparameters.get ('remainderList'), null);
        System.assertEquals (result.outputparameters.get ('lastItem'), true);

        //  2 items
        inputParams.clear  ();
        outputParams.clear ();                
        inputParams.put ('inputList', 'item1;item2');
        request = new Process.PluginRequest (inputParams);
        result  = plugin.invoke (request);

        System.assertEquals (result.outputparameters.get ('nextItem'), 'item1');
        System.assertEquals (result.outputparameters.get ('remainderList'), 'item2');
        System.assertEquals (result.outputparameters.get ('lastItem'), false);

        //  3 items
        inputParams.clear  ();
        outputParams.clear ();             
        inputParams.put ('inputList', 'item1;item2;item3');
        request = new Process.PluginRequest (inputParams);
        result  = plugin.invoke (request);

        System.assertEquals (result.outputparameters.get ('nextItem'), 'item1');
        System.assertEquals (result.outputparameters.get ('remainderList'), 'item2;item3');
        System.assertEquals (result.outputparameters.get ('lastItem'), false);

        //  4 items
        inputParams.clear  ();
        outputParams.clear ();             
        inputParams.put ('inputList', 'item1 ;item2; item3; item4');
        request = new Process.PluginRequest (inputParams);
        result  = plugin.invoke (request);

        System.assertEquals (result.outputparameters.get ('nextItem'), 'item1');
        System.assertEquals (result.outputparameters.get ('remainderList'), 'item2; item3; item4');
        System.assertEquals (result.outputparameters.get ('lastItem'), false);

    }   //  testInvoke ()

}