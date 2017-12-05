/*****************************************************************************************************
Class    :  SObjectHelper.cls
Developer:  Mickey Murphy, Blue Wolf Group LLC
Created  :  May 31, 2013

   Inputs
      inputRecordId   (String) :  15- or 18-character SFDC Id

   Outputs
      isCustomSetting (Boolean):  Returns true where object type is a Custom Setting.
      sobjectId       (String) :  Returns 18-character representation of inputRecordId.
      sobjectName     (String) :  Returns name of the SFDC object type referenced by inputRecordId.

*****************************************************************************************************/

global class SObjectHelper implements Process.Plugin
{
    //  public properties declared in alphabetical order
    public Boolean isCustomSetting = false;
    public String  sobjectId       = null;
    public String  sobjectName     = null;

    //  global methods listed in alphabetical order
    global Process.PluginDescribeResult describe ()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult ();

        result.description = 'SObjectHelper class accepts a 15- or 18-character SFDC ID '
                           + '("inputRecordId") and returns (a) true where "inputRecordId" '
                           + 'is a Custom Setting:  "isCustomSetting"; (b) the 18-character '
                           + 'SFDC Id representation of "inputRecordId:"  "sobjectId"; and (c) '
                           + 'the name of the SFDC Class from which an instance of the class '
                           + 'is referenced by "sobjectId:"  "sobjectName."';

        result.tag = 'Utilities';

        result.inputParameters = new List <Process.PluginDescribeResult.InputParameter>
        {
            new Process.PluginDescribeResult.InputParameter
            ('inputRecordId', Process.PluginDescribeResult.ParameterType.STRING, true)

        };

        result.outputParameters = new List <Process.PluginDescribeResult.OutputParameter>
        {
            new Process.PluginDescribeResult.OutputParameter('isCustomSetting', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN), 
            new Process.PluginDescribeResult.OutputParameter('sobjectId', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('sobjectName', 
                Process.PluginDescribeResult.ParameterType.STRING)

        };

        return result;

    }   //  describe ()

    global Process.PluginResult invoke (Process.PluginRequest request)
    {
        //  variables declared in alphabetical order
        Schema.DescribeSObjectResult objectDescription = null;
        Schema.Sobjecttype objectType = null;
        Id recordId = null;
        Map <String, Object> result = new Map <String, Object> ();
        String sObjectName = null;
        String sRecordId = (String) request.inputParameters.get ('inputRecordId');

        recordId = Id.valueOf (sRecordId);
        objectType = recordId.getSObjectType ();
        objectDescription = objectType.getDescribe ();
        isCustomSetting = objectDescription.isCustomSetting ();
        sObjectName = objectDescription.getName ();
        sRecordId = (String) recordId;

        result.put ('isCustomSetting', isCustomSetting);
        result.put ('sobjectId'      , sRecordId      );
        result.put ('sobjectName'    , sObjectName    );

        return new Process.PluginResult (result); 

    }   //  invoke ()

}