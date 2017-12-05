public class ExperianRestTestController 
{
    public string Line1{get;set;}
    public string Line2{get;set;}
    public string Line3{get;set;}
    public string City{get;set;}
    public string State{get;set;}
    public string Zip{get;set;}
    public string AddressId{get;set;}
    public string Refinement{get;set;}
    public AddressValidateRestResponse result{get;set;}
    
    public void verifyAddress()
    {
        //ValidatedAddress address = new ValidatedAddress(Line1,Line2,Line3,City,State,Zip,'USA',null,false);
        ValidatedAddress address = new ValidatedAddress(Line1,Line2,Line3,City,State,Zip,'USA',null,true,false);
        this.result = AddressValidateRestApi.VerifyAddress(address); 
        
    }
    
    public void searchAddress()
    {
        //ValidatedAddress address = new ValidatedAddress(Line1,Line2,Line3,City,State,Zip,'USA',addressId,false);
        ValidatedAddress address = new ValidatedAddress(Line1,Line2,Line3,City,State,Zip,'USA',addressId,true,false);
        this.result = AddressValidateRestApi.SearchAddress(address);   
    }
    
    public void addressLayout()
    {
        this.result = AddressValidateRestApi.AddressLayout(this.AddressId);
    }
    
    public void refineAddress()
    {
        this.result = AddressValidateRestApi.RefineAddress(this.addressId, this.refinement, 'USA');
    }
}