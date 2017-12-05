/***************************************************************************************************
Class    :  PdfHelper.cls
Developer:  Vandarajan Rajaram, salesforce.com, inc.
Created  :  August 13, 2012
Modified :  June 19, 2013
Objective:  This class provides Adobe Portable Document Format services to Visual Flow.

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

 * Salesforce version written for: Winter '12
 * This Apex plug-in for Visual Workflow creates a pdf document and attaches to the notes and attachmetns section of any record in salesforce.
 * Inputs: 
 *    Record ID (Required)
 *    Attachment Name (Required)
 *    Attachment content (Required)
 *
 * Outputs:
 *    Status = SUCCESS/ERROR if all is well or any Error
 *    ErrorMessage if status is ERROR with the apprporiate error message

***************************************************************************************************/

global with sharing class PdfHelper implements Process.Plugin
{
    public static final String ERROR_CODE = 'ERROR';
    public static final String SUCCESS_CODE = 'SUCCESS';
    public String Error = null;
    public String Status = null;

    global Process.PluginResult invoke ( Process.PluginRequest request )
    {    
        String recordID = (String) request.inputParameters.get ('recordID');
        String pdfAttachmentName = (String) request.inputParameters.get ('pdfAttachmentName');
        String pdfAttachmentContent = (String) request.inputParameters.get ('pdfAttachmentContent');
        Map <String, Object> result = new Map <String, Object> ();
        AttachPDF (recordID, pdfAttachmentName, pdfAttachmentContent);
        result.put ('Error', Error);
        result.put ('Status', Status);
        return new Process.PluginResult (result); 

    }   //  inovke ()

    global Process.PluginDescribeResult describe ()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'The createAndAttachPDF Flow Plug-in create a PDF document and attaches it to the specified record ID';
        result.tag = 'PDF Utils';
        result.inputParameters = new List <Process.PluginDescribeResult.InputParameter>
        {
            new Process.PluginDescribeResult.InputParameter
                ('recordID', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter
                ('pdfAttachmentName', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter
                ('pdfAttachmentContent', Process.PluginDescribeResult.ParameterType.STRING, true)
                                                                                                    
        };

        result.outputParameters = new List <Process.PluginDescribeResult.OutputParameter>
        {
            new Process.PluginDescribeResult.OutputParameter
                ('Status', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter
                ('Error', Process.PluginDescribeResult.ParameterType.STRING)    

        };     

        return result;

    }   //  describe ()
        
    public void attachPDF ( String recordID, String pdfAttachmentName, String pdfAttachmentContent )
    {
        Blob pdfattachment = null;

        try
        {
            pdfattachment = Blob.toPdf (pdfAttachmentContent);
            Attachment attachment = new Attachment ();
            attachment.ParentId = recordId;
            attachment.Name = pdfAttachmentName;
            attachment.Body = pdfattachment;
            insert attachment;
            Status = SUCCESS_CODE;

        }

        catch ( Exception e )
        {
            Error  = e.getMessage ();
            Status = ERROR_CODE;

        }

    }   //  attachPDF

}