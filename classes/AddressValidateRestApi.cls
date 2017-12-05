/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AddressValidateRestApi
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Class containing method calls to the Experian Address Validate REST API
 * Created Date : 06/30/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/30/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AddressValidateRestApi 
{
    //Searches for addresses based on an unstructured text query.
    //@param line1 - address line 1
    //@param line2 - address line 2
    //@param line3 - address line 3
    //@param city - the city
    //@param state - the state or province
    //@param postalCode - zip or postal code
    //@param country - USA or CAN (ISO CODE)
    //@param addressId - the id value of an address that is part of a grouped result for refinement (tower blocks)
    //@return see http://support.qas.com/ua/?lang=en-us&prod=capture&flav=apiv1#Methods/SearchAddress.htm%3FTocPath%3DMain%2520Methods%7C_____1
    //response is deserialized from JSON
	public static AddressValidateRestResponse SearchAddress(ValidatedAddress address)
    {
		AddressValidateRestResponse result;
        
        Experian_REST_API_Settings__c setting = Experian_REST_API_Settings__c.getInstance();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Auth-Token', setting.Auth_Token__c);
		
        string query = CreateAddressQuery(address);
        string endpoint = setting.Base_URL__c + setting.Search_Address_Endpoint__c + query;
        request.setEndpoint(endpoint);
        
        Http http = new Http();
        
        try
        {
            HttpResponse response = http.send(request);
            integer statusCode = response.getStatusCode();
            string body = response.getBody();
            result = 
                (AddressValidateRestResponse)JSON.deserialize(body, AddressValidateRestResponse.class);
        }
        catch(Exception ex) 
        {
            
        }
        
        return result;
    }
    
    //Verifies the address based on an unstructured text query
    //@param line1 - address line 1
    //@param line2 - address line 2
    //@param line3 - address line 3
    //@param city - the city
    //@param state - the state or province
    //@param postalCode - zip or postal code
    //@param country - USA or CAN (ISO CODE)
    //@param addressId - the id value of an address that is part of a grouped result for refinement (tower blocks)
    //@return see http://support.qas.com/ua/?lang=en-us&prod=capture&flav=apiv1#Methods/VerifyAddress.htm%3FTocPath%3DMain%2520Methods%7C_____2
    //response is deserialized from JSON
    public static AddressValidateRestResponse VerifyAddress(ValidatedAddress address)
    {
        AddressValidateRestResponse result;
        
        Experian_REST_API_Settings__c setting = Experian_REST_API_Settings__c.getInstance();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Auth-Token', setting.Auth_Token__c);
		
        string query = CreateAddressQuery(address);
        
        string endpoint = setting.Base_URL__c + setting.Verify_Address_Endpoint__c + query;
        request.setEndpoint(endpoint);
        
        Http http = new Http();
        
        try
        {
            HttpResponse response = http.send(request);
            integer statusCode = response.getStatusCode();
            string body = response.getBody();
            result = 
                (AddressValidateRestResponse)JSON.deserialize(body, AddressValidateRestResponse.class);
        }
        catch(Exception ex) 
        {
			
        }
        
        if(result == null)
            result = new AddressValidateRestResponse();
        
        result.query = endpoint + query;
        
        return result;
    }
    
    //refines the address when clarity is needed for street, apartment, or suite
    //@param addressId - the addressId returned from verifyAddress
    //@param refinement - string containing the apartment, street, or suite
    //@param country - the address country
    //@return AddressValidateRestResponse - a picklist
    public static AddressValidateRestResponse RefineAddress(string addressId, string refinement, string country)
    {
        AddressValidateRestResponse result;
        
        Experian_REST_API_Settings__c setting = Experian_REST_API_Settings__c.getInstance();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Auth-Token', setting.Auth_Token__c);
		
        string query = '?id=' + addressId + '&query=' + EncodingUtil.urlEncode(refinement, 'UTF-8') + '&country=' + country;
        
        string endpoint = setting.Base_URL__c + setting.Refine_Address_Endpoint__c + query;
        request.setEndpoint(endpoint);
        
        Http http = new Http();
        
        try
        {
            HttpResponse response = http.send(request);
            integer statusCode = response.getStatusCode();
            string body = response.getBody();
            result = 
                (AddressValidateRestResponse)JSON.deserialize(body, AddressValidateRestResponse.class);
        }
        catch(Exception ex) 
        {
			
        }
        
        if(result == null)
            result = new AddressValidateRestResponse();
        
        result.query = endpoint + query;
        
        return result;
    }
    
    //Returns a single, detailed address layout record for a supplied identifier.
    //@param addressId - the address id returned in a picklist entry from SearchAddress or ValidateAddress
    //@return see http://support.qas.com/ua/?lang=en-us&prod=capture&flav=apiv1#Methods/AddressLayout.htm%3FTocPath%3DMain%2520Methods%7C_____3
    //response is deserialized from JSON
    public static AddressValidateRestResponse AddressLayout(string addressId)
    {
        AddressValidateRestResponse result;
        
        Experian_REST_API_Settings__c setting = Experian_REST_API_Settings__c.getInstance();
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Auth-Token', setting.Auth_Token__c);
		
        string endpoint = setting.Base_URL__c + setting.Address_Layout_Endpoint__c  + '/' + addressId + '/';
        request.setEndpoint(endpoint);
        
        Http http = new Http();
        
        try
        {
            HttpResponse response = http.send(request);
            integer statusCode = response.getStatusCode();
            string body = response.getBody();
            result = 
                (AddressValidateRestResponse)JSON.deserialize(body, AddressValidateRestResponse.class);
        }
        catch(Exception ex) 
        {
            
        }
        
        return result;
        return null;
    }
    
    //formats the query string for address validation
    //@param line1 - address line 1
    //@param line2 - address line 2
    //@param line3 - address line 3
    //@param city - the city
    //@param state - the state or province
    //@param postalCode - zip or postal code
    //@param country - USA or CAN (ISO CODE)
    //@param addressId - the id value of an address that is part of a grouped result for refinement (tower blocks)
    private static string CreateAddressQuery(ValidatedAddress address)
    {
        string addressQuery = '';
        
        if(!string.isBlank(address.line1))
            addressQuery += address.line1 + ', ';
   
        if(!string.isBlank(address.line2))
            addressQuery += address.line2 + ', ';

        if(!string.isBlank(address.line3))
            addressQuery += address.line3 + ', ';
        
        if(!string.isBlank(address.city))
            addressQuery += address.city + ' ';
        
        if(!string.isBlank(address.stateprov))
            addressQuery += address.stateprov + '  ';
        
        if(!string.isBlank(address.postalCode))
            addressQuery += address.postalCode;
        
        if(addressQuery != null)
        	addressQuery = addressQuery.trim();
        
        string query = ''; 
        
        if(!string.isBlank(addressQuery))
        	query = '?query=' + EncodingUtil.urlEncode(addressQuery, 'UTF-8') + '&country=' + address.country;
       
        return query;
    }
}