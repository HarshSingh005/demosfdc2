/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidateRestResponse
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Class representing JSON response from Experian Address Validate REST API
 * Created Date : 06/30/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/30/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AddressValidateRestResponse 
{
    public class result
    {
        public string id{get;set;}
        public string text{get;set;}
        public string grouped{get;set;}
        public string url{get;set;}
    }
    
    public class field
    {
        public string id{get;set;}
        public string label{get;set;}
        public string content{get;set;}
    }
    
    public string query{get;set;}
	public string prompt{get;set;}
    public string verifyLevel{get;set;}
    public integer count{get;set;}
    public List<field> fields{get;set;}
    public List<result> results{get;set;}
}