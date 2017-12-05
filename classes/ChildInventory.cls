/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildInventory
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Prototype child inventory web service for website consumption
 * Created Date : 12/16/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/15/2015                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class ChildInventory 
{
    global class ChildFilter
    {
        webservice integer NoId;
        webservice integer CountryCode ;
        webservice integer CountryCodeFromAge;
        webservice integer FromAge;
        webservice integer ToAge;
        webservice string Gender;
        webservice string IpAddress;
        webservice string Birthday;
        webservice string BirthMonth;
        webservice integer ProjectId;
        webservice integer KidsReturned;
    }
    
    global class Envelope
    {
        webservice List<string> ErrorList;
        webservice integer NewID;
        webservice string NewValue;
        webservice blob NewOutput; //was byte[]
        webservice integer NumberOfRecordsAffected;
        webservice ReturnMsg ReturnMessage;
        webservice string ErrorMessage;
        webservice string StackTrace;
        webservice integer ReturnCode;
        webservice TransactionInfo TransOut;
        webservice AgpInfo AgpOut;
        webservice List<ContactInfo> HouseholdMatches;
        webservice List<WebChildInfo> AvailableKids;
    }
    
    global enum ReturnMsg
    {
        Success,
        Failure,
        Unknown
    }
    
    global class TransactionInfo
    {
        webservice ReturnMsg ReturnMessage;
        webservice List<string> TransactionExceptionSummary;
        webservice string TransactionCreateDate;
        webservice string TransactionModifiedDate;
        webservice string TransactionUserCreate;
        webservice string TransactionUserModified;
        webservice string TransactionBetweenDate;
        webservice string TransactionUserComments;
        webservice string TransactionStatus;
        webservice string MessageId;
        webservice integer TransactionId;
        webservice string DonorContactType;
        webservice integer DonorId;
        webservice string DonorOriginCode;
        webservice integer DonorMarketingId;
        webservice string DonorFirstName;
        webservice string DonorLastName;
        webservice integer DonorSuffixId;
        webservice integer DonorTitleId;
        webservice string DonorCareOf;
        webservice string DonorStreet1;
        webservice string DonorStreet2;
        webservice string DonorExtraAddress1;
        webservice string DonorExtraAddress2;
        webservice string DonorExtraAddress3;
        webservice string DonorPostalCode;
        webservice string DonorCity;
		webservice integer DonorState;
        webservice string DonorCountryCode;
        webservice string DonorPhoneAreaCode;
        webservice string DonorPhone;
        webservice integer DonorPhoneExtension;
        webservice string DonorEmail;
        webservice integer DonorMotivatedById;
        webservice Envelope Errors;
        webservice List<string> ContactErrorList;
        webservice integer PaymentId;
        webservice string PaymentType;
        webservice string PaymentAccountNumber;
        webservice integer PaymentDonorId;
        webservice string PaymentCardType;
        webservice string PaymentCardholderFullName;
        webservice string PaymentCardholderZipcode;
        webservice string PaymentDateExpiration;
        webservice string PaymentDateDfTaken;
        webservice string TransactionType;
        webservice List<string> PaymentErrorList;
        webservice string CVV;
        webservice string BankName;
        webservice string MaskedAccountNum;
        webservice List<DonationInfo> PurchasedDonations;
        webservice string PaymentTransitNumber;
        webservice string QueueID;
        webservice long AdminContactId;
        webservice boolean doesAcceptTerms;
        webservice boolean doesAcceptACHTerms;
        webservice boolean isReactivating;
        webservice boolean isVerifiedDonor;
        webservice boolean isVerifiedPayment;
        webservice boolean isVerifiedDonations;
        webservice boolean isDirtyDonor;
        webservice boolean isDirtyPayment;
        webservice boolean doesAcceptDfFee;
        webservice boolean validateForSponsorship;
        webservice boolean BypassHouseHoldMatch;
        webservice boolean CanSponsorChildren;
        webservice boolean IsEncrypted;
        webservice boolean IsAgpTransferred;
        webservice boolean IsDeactivatePaySched;
        webservice string ContactMatchType;
        webservice boolean IsGuest;
        webservice boolean IsAdmin;
        webservice boolean IsImpersonate;
        webservice boolean HasAGPs;
        webservice boolean TransactionSuccessful;
        webservice boolean CreateEktronAccount;
        webservice string EktronPassword;
    }
    
    global class AgpInfo
    {
        webservice string AccountNumberE;
        webservice integer Id;
        webservice string AgpType;
        webservice string AccountNumber;
        webservice string DateCreated;
        webservice string Active;
        webservice integer ContactId;
        webservice integer MktacId;
        webservice integer BkId;
        webservice string CardType;
        webservice string FullName;
        webservice string CardholderZipcode;
        webservice string DateExpiration;
        webservice string TransitNumber;
        webservice string BankName;
        webservice string PreNoteFlag;
        webservice string DateDfTaken;
        webservice string IndHidden;
        webservice string CardName;
        webservice boolean doesAcceptACHTerms;
    }
    
    global class ContactInfo
    {
        webservice boolean validateForSponsorship;
        webservice boolean isverifiedcontact;
        webservice boolean cansponsorchildren;
        webservice boolean isdirty;
        webservice string errormessage;
        webservice string contacctid;
        webservice string begindate;
        webservice string enddate;
        webservice integer modelscore;
        webservice integer id;
        webservice string conttype;
        webservice string name;
        webservice string ctrycode;
        webservice integer freqgrpid;
        webservice date datecreated; //was object
        webservice string origincode;
        webservice string inddeceased;
        webservice string inddonotcall;
        webservice string namesoundx; //was object
        webservice string prefcorrmethod;
        webservice string indreturnedmail;
        webservice string indsupervisorhandling;
        webservice string indundesirable;
        webservice string indvip;
        webservice integer amtlargestcontribution;
        webservice integer mktacid;
        webservice string bypassncoa;
        webservice string street1;
        webservice string city;
        webservice string indannualreport;
        webservice string indanonymoussponsor;
        webservice string indbillingaddresssame;
        webservice string indchildworld;
        webservice string indincludeonannualreport;
        webservice string indiocorrespond;
        webservice string indpullstatement;
        webservice string indphoneunpublished;
        webservice string indreminderupcomingdonation;
        webservice string indstatement;
        webservice string indstuffer;
        webservice string firstname;
        webservice string middlename;
        webservice integer clstnmsuffixid;
        webservice integer clstnmtitleid;
        webservice string salutation;
        webservice string careof;
        webservice string envelopeline;
        webservice integer cdesstatprovterrid;
        webservice string street2;
        webservice string extraaddress1;
        webservice string extraaddress2;
        webservice string extraaddress3;
        webservice string urbanization;
        webservice string postalcode;
        webservice string phoneareacode;
        webservice string phone;
        webservice integer phoneextension;
        webservice string faxareacode;
        webservice string phonefax;
        webservice string email;
        webservice string indboardmember;
        webservice string phonedayareacode;
        webservice string phoneday;
        webservice integer phonedayextension;
        webservice string indphonedayunpublished;
        webservice integer qtyactiveprespns;
        webservice integer qtyprespnscancels;
        webservice integer qtyprespnsdrops;
        webservice integer qtyactivespns;
        webservice integer qtyonholdspns;
        webservice integer qtyrequestedspnscancel;
        webservice integer qtydelinquencycanceledspns;
        webservice integer ccfindvid;
        webservice integer ccfindvsubshiftredirectid;
        webservice date dateanniversary; //was object
        webservice integer orgtypid;
        webservice string indallowsponsorship;
        webservice integer contcorrespondencerepid;
        webservice integer contfinancialrepid;
        webservice date datelastcontribution; //was object
        webservice integer iaid;
        webservice integer contreferredbyid;
        webservice integer contmotivatedbyid;
        webservice date datestartstmtpull; //was object
        webservice date dateendstmtpull; //was object
        webservice date datestartiocorrespond; //was object
        webservice date datestopiocorrespond; //was object
        webservice date dateundesirable; //was object
        webservice string undesirablecomment;
        webservice string carrierroute;
        webservice string deliverypointeger;
        webservice date datemodified; //was object
        webservice string lastmodifiedby;
        webservice string uspschangecode;
        webservice string iaacctno;
        webservice string oldaccountnbr;
        webservice integer qtysubshiftpending;
        webservice integer qtyrecentdelinquentcancels;
        webservice string indcorintegerhian;
        webservice string uname;
        webservice string ufirstname;
        webservice string ustreet1;
        webservice string ustreet2;
        webservice string uextraaddress1;
        webservice string uextraaddress2;
        webservice string uextraaddress3;
        webservice string ucity;
        webservice string upostalcode;
        webservice boolean acceptdffee; //was object
        webservice string indreceiveacks;
        webservice string indchildrenscirclenews;
        webservice string state;
        webservice string GiftMessage;
        webservice string GiftOccasion;
        webservice long GiftTransactionId;
        webservice long GiftTranType;
        webservice string GiftTitle;
        webservice long GiftQuantity;
        webservice decimal GiftUnitCost; //was float
        webservice long GiftPaySchedId;
        webservice boolean doesAcceptTerms;
        webservice boolean IsValidAddress;
    }
    
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
        webservice blob childphoto; //was byte[]
        webservice string DOB;
        webservice string CountryName;
        webservice integer MonthlySponsorship;
        webservice boolean IsOriginalSearchCriteria;
    }
    
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
    
	webservice static Envelope GetAvailableKidsForWeb(ChildFilter filter)
    {
        Envelope response = new Envelope();
        
        response.ReturnMessage = ReturnMsg.Success; 
        response.AvailableKids = new List<WebChildInfo>();
        
        WebChildInfo kid = new WebChildinfo();
        kid.name = 'Joe Child';
        kid.shortname = 'Joey';
        kid.gender = 'M';
        kid.age = 9;
        response.AvailableKids.add(kid);
        
        return response;
    }
}