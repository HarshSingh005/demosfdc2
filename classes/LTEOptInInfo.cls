/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LTEOptInInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 03/11/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/11/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class LTEOptInInfo 
{
    webservice integer Contactid;
    webservice integer Sponsorshipid;
    webservice integer Noid;
    webservice integer Childnumber;
    webservice boolean Isoptedin;
    webservice string Optindate;
    webservice string Status;
}