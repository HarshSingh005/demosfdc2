/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ChildFilter
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Input filter for ChildFund.org web services
 * Created Date : 02/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 02/08/2016                   Karl Houseknecht        Created
 * 17/Feb/2016                  Rohit B.                Changes type of CountryCode from integer to string.
 * 02/25/2016                   Karl Houseknecht        Changed countrycode back to integer. - Note: as designed.
 **********************************************************************************************************/
global class ChildFilter
{
    webservice integer NoId;
    webservice integer CountryCode;
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