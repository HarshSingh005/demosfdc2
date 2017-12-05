/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebChildInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class WebChildInfo
{
    webservice integer NatOfficeThreshold;
    webservice string NatOfficeUsed;
    webservice string ChildUsed;
    webservice integer ProjectThreshold;
    webservice string ProjectUsed;
    webservice integer noid;
    webservice integer childnbr;
    webservice string name;
    webservice string shortname;
    webservice integer projid;
    webservice integer chstaid;
    webservice string gender;
    webservice integer age;
    webservice string cifinfo;
    webservice string EnterpriseLegacyId;
    webservice string DOB;
    webservice string CountryName;
    webservice integer MonthlySponsorship;
    webservice boolean IsOriginalSearchCriteria;
}