/***********************************************************************************************************
 * Appirio, Inc
 * Name         : NationalOfficeInfo
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : For ChildFund.org web services
 * Created Date : 04/14/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/14/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class NationalOfficeInfo 
{
	webservice string errormessage;
    webservice string ctrydesc;
    webservice integer id;
    webservice integer lastchildnbr;
    webservice date datelastmodified;
    webservice string lastmodifiedby;
    webservice string ctrycode;
    webservice string name;
    webservice integer enrollmentquota;
    webservice integer quotaexcesspercent;
    webservice date datestart;
    webservice string directorname;
    webservice string phonenbrs;
    webservice string addlphonenbrs;
    webservice integer stateid;
    webservice integer defaultprojid;
    webservice string addr1;
    webservice string addr2;
    webservice string addr3;
    webservice string addr4;
    webservice string addr5;
    webservice string addr6;
    webservice string city;
    webservice string zip;
    webservice string projaddformail;
    webservice string emailaddress;
    webservice string faxnbr;
    webservice integer noidaddressedby;
    webservice integer noidadminby;
    webservice date dateclose;
    webservice string status;
    webservice string iosupported;
    webservice string usedinweb;
    webservice integer reciprocaliaid;
    webservice string indchildcomments;
}