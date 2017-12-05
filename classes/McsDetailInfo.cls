/***********************************************************************************************************
 * Appirio, Inc
 * Name         : McsDetailInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For LTE web services
 * Created Date : 03/16/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/16/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class McsDetailInfo 
{
	webservice integer NoId;
    webservice integer McsSlip;
    webservice integer LetterTypeId;
    webservice string LetterTypeName;
    webservice string NationalOfficeName;
    webservice integer ContactId;
    webservice integer ChildNbr;
    webservice string ContactName;
    webservice string ChildName;
    webservice string ContactEmail;
    webservice string RequestDate; 
    webservice string DueDate;
    webservice integer IaId;
    webservice string PartnerName;
    webservice integer ProjId;
    webservice string McsStatus;
    webservice integer CaseNbr;
    webservice string Gender;
    webservice integer VillageId;
    webservice string VillageName;
    webservice string ContactCountry;
    webservice long DfId;
    webservice double DfAmount;
    webservice string DfAddlMsg;
    webservice string McsCategory;
    webservice string McsCategoryDesc;
    webservice string McsAddlMessage; 
    webservice string BirthDate;
    webservice integer ErrorCode;
    webservice string ErrorMessage;
    webservice string PreferredLanguage;
}