/***********************************************************************************************************
 * Appirio, Inc
 * Name         : DonationHistoryInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 03/11/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/11/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class DonationHistoryInfo 
{
    webservice string errormessage;
    webservice DateTime TransDate;
    webservice decimal TransAmount; //was float
    webservice integer contid;
    webservice string dontype;
    webservice string amtyeartodate;
    webservice string amtpreviousyear;
    webservice string amtlifetime;
    webservice string updatedDate;
    webservice string description; //was desc - reserved word
    webservice string toDate;
    webservice string fromDate;
    webservice integer agpid;
}