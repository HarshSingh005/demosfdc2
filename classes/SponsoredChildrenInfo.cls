/***********************************************************************************************************
 * Appirio, Inc
 * Name         : SponsoredChildrenInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 03/11/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/11/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class SponsoredChildrenInfo 
{
    webservice string AccountNum;
    webservice string CardType;
    webservice string ContType;
    webservice integer ContId;
    webservice string AgpType;
    webservice integer AgpId;
    webservice integer PymtId;
    webservice string AcctType;
    webservice integer FinCode;
    webservice string Description;
    webservice decimal Amount; //was float
    webservice string Freq;
    webservice integer sponsorshipId;
    webservice integer NoId;
    webservice integer ChildNbr;
    webservice integer CaseNbr;
    webservice string ChildName;
    webservice string Birthday;
    webservice integer AgeYear;
    webservice integer AgeMonth;
    webservice string CtryCode;
    webservice string CtryDesc;
    webservice integer ProjId;
    webservice string ProjDesc;
    webservice string Address;
    webservice string Status;
    webservice string DueDate;
    webservice string PaIdThru;
    webservice decimal AmtDue; //was float
    webservice integer AgpReadOnly;
    webservice integer birthdayMonth;
    webservice string SponsorshipType;
    webservice string ShortName;
    webservice integer MktacId;
    webservice blob ChildPhoto;
    webservice boolean LTEOptIn;
}