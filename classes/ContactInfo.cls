/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
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
    webservice string deliverypoint;
    webservice date datemodified; //was object
    webservice string lastmodifiedby;
    webservice string uspschangecode;
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
    webservice string acceptdffee; //was object - Y/N
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