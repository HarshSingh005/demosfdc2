/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CodeInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/24/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/24/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class CodeInfo 
{
	webservice string errormessage;
    webservice integer id;
    webservice string codetype;
    webservice string code;
    webservice string name;
    webservice string activestatus;
    webservice string createdby;
    webservice date datecreated;
    webservice string lastmodifiedby;
    webservice date datelastmodified;
    webservice string additionalinfo;
}