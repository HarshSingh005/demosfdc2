/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PasswordResetInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 04/14/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/14/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class PasswordResetInfo 
{
    webservice integer ResetId;
    webservice string Email;
    webservice string StaleDate;
    webservice string LinkHash;
    webservice boolean IsValid;
}