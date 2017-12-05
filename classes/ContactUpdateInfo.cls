/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactUpdateInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class ContactUpdateInfo 
{
    webservice string phoneareacode;
    webservice string phone;
    webservice integer phoneextension;
    webservice string errormessage;
    webservice integer id;
    webservice string name;
    webservice string ctrycode;
    webservice string street1;
    webservice string city;
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
    webservice string postalcode;
    webservice string email;
    webservice integer iaid;
    webservice date datemodified; //was object
    webservice string lastmodifiedby;
    webservice string iaacctno;
    webservice string oldaccountnbr;
    webservice integer qtysubshiftpending;
    webservice integer qtyrecentdelinquentcancels;
    webservice string indcorinthian;
    webservice string uname;
    webservice string ufirstname;
    webservice string ustreet1;
    webservice string ustreet2;
    webservice string uextraaddress1;
    webservice string uextraaddress2;
    webservice string uextraaddress3;
    webservice string ucity;
    webservice string upostalcode;
    webservice integer QuestionId;
    webservice string HashedAnswer;
    webservice string UserSalt;
    webservice long RecipientId;
}