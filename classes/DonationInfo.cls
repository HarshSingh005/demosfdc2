/***********************************************************************************************************
 * Appirio, Inc
 * Name         : DonationInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class DonationInfo
{
    webservice integer PaySchedId;
    webservice boolean HasAnchor;
    webservice List<string> EmailSubscriptions;
    webservice boolean isVerified;
    webservice decimal Amount;
    webservice integer FinCode;
    webservice integer NationalOffice;
    webservice integer ChildNumber;
    webservice ContactInfo Contact;
    webservice integer SponsorshipId;
    webservice integer mktacid;
    webservice string PaymentFrequency;
    webservice integer ProjectId;
    webservice integer TransType;
    webservice string Title;
    webservice List<string> ErrorList;
    webservice string DFMessage;
    webservice Enums.EffDateType DFEffectiveDateType;
    webservice boolean DeactivatePaySched;
    webservice boolean TransferAGP;
    webservice integer CartQuantity;
}