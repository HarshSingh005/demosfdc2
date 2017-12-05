/***********************************************************************************************************
 * Appirio, Inc
 * Name         : Envelope
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class Envelope
{
    webservice List<string> ErrorList;
    webservice integer NewID;
    webservice string NewValue;
    webservice blob NewOutput; //was byte[]
    webservice integer NumberOfRecordsAffected;
    webservice Enums.ReturnMsg ReturnMessage;
    webservice string ErrorMessage;
    webservice string StackTrace;
    webservice integer ReturnCode;
    webservice TransactionInfo TransOut;
    webservice AgpInfo AgpOut;
    webservice List<ContactInfo> HouseholdMatches;
    webservice List<WebChildInfo> AvailableKids;
}