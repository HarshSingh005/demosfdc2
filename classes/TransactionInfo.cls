/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TransactionInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class TransactionInfo
{
    webservice Enums.ReturnMsg ReturnMessage;
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