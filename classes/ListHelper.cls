/*****************************************************************************************************
Class    :  ListHelper.cls
Developer:  Vandarajan Rajaram, salesforce.com, inc.
Created  :  August 13, 2012
Modified :  June 19, 2013
Objective:  This class provides list services to Visual Flow.

Copyright (c) 2012, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.


This is a Flow Plug-in class which is itended to help the flow designer process
indivudial choices selected from a multi-select choice in a flow.

The class gets the first choice from the choice value and returns the remainder
choices along with a boolean flag to let the user know if the current choice 
is the last one.

   Inputs
      inputList (String): Multi-select choice Stored Value ( a ';' separeted choice value set)

   Outputs

      nextItem (String): A single choice from the list provided
      remainderList (String): Remainder of the list 
      lastItem (Boolean): Boolean flag to indicate if the item returned was the last one

*****************************************************************************************************/

global class ListHelper implements Process.Plugin
{
    //  public properties declared in alphabetical order
    public Boolean lastItem;
    public String  nextItem;
    public String  remainderList;

    //  global methods listed in alphabetical order

    global Process.PluginDescribeResult describe ()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult ();

        result.description = 'The ListHelper class is used as an iterator where it accepts a list '
                           + 'and outputs one item of the list and a reminder count.';
        result.tag = 'Utilities';

        result.inputParameters = new List <Process.PluginDescribeResult.InputParameter>
        {
            new Process.PluginDescribeResult.InputParameter
            ('inputList', Process.PluginDescribeResult.ParameterType.STRING, true)

        };

        result.outputParameters = new List <Process.PluginDescribeResult.OutputParameter>
        {
            new Process.PluginDescribeResult.OutputParameter('nextItem', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('remainderList', 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('lastItem', 
                Process.PluginDescribeResult.ParameterType.BOOLEAN)   

        };

        return result;

    }   //  describe ()

    global Process.PluginResult invoke (Process.PluginRequest request)
    {    
        String inputList = (String) request.inputParameters.get ('inputList');
        Map <String, Object> result = new Map <String, Object> ();

        if ( inputList == null
        ||   inputList == ''
           )
        {
            result.put ('lastItem', true); 
            result.put ('nextItem', null);
            result.put ('remainderList', null);

            return new Process.PluginResult (result); 

        }

        breakdownList (inputList);

        result.put ('lastItem', lastItem);
        result.put ('nextItem', nextItem);
        result.put ('remainderList', remainderList);

        return new Process.PluginResult (result); 

    }   //  invoke ()

    //  private methods listed in alphabetical order
    private void breakdownList (String itemList)
    {
        Integer firstIndex = itemList.indexOf (';');

        if ( firstIndex == -1 )
        {
            lastItem = true;
            nextItem = itemList;
            remainderList = null;

            return;

        }

        lastItem = false;
        nextItem = itemList.subStringBefore (';').trim ();
        remainderList = itemList.subStringAfter (';').trim ();

    }   //  breakdownList ()

}