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