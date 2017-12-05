/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ValidatedAddress
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Represents an address to validate
 * Created Date : 07/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/01/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class ValidatedAddress 
{
    public string Line1{get;set;}
    public string Line2{get;set;}
    public string Line3{get;set;}
    public string City{get;set;}
    public string StateProv{get;set;}
    public string PostalCode{get;set;}
    public string Country{get;set;}
    public string AddressId{get;set;}
    public boolean IsValid
    {
        get
        {
            if(this.Country != 'USA')
                return true;
            else
                return IsValid;
        }
     	set;
    }
    public boolean IsOverridden{get;set;}
    public boolean IsChanged{get;set;}
    
    @TestVisible
    private rC_Bios__Address__c rcaddress;
    
    @TestVisible
    private rC_Bios__Contact_Address__c rcContactAddress;
    
    @TestVisible
    private rC_Bios__Account_Address__c rcAccountAddress;
    
    public rC_Bios__Address__c rcBiosAddress
    {
        get
        {      
            if(this.isChanged)
            {
                this.rcaddress.rC_Bios__Street_Line_1__c = this.Line1;
                this.rcaddress.rC_Bios__Street_Line_2__c = this.Line2;
                this.rcaddress.Extra_Address_1__c = this.Line3;
                this.rcaddress.rC_Bios__City__c = this.City;
                this.rcaddress.rC_Bios__State__c = this.StateProv;
                this.rcaddress.rC_Bios__Postal_Code__c = this.PostalCode;
                this.rcaddress.rC_Bios__Country__c = this.Country;
                this.rcaddress.Validated__c = this.IsValid;
                this.rcaddress.Overridden__c = this.IsOverridden;
            }
            
            return this.rcaddress;
        }
        set
        {
            rcaddress = value;
        }
    }
    
    public rC_Bios__Contact_Address__c rcBiosContactAddress
    {
        get
        {      
            if(this.isChanged)
            {
                this.rcContactAddress.rC_Bios__Original_Street_Line_1__c = this.Line1;
                this.rcContactAddress.rC_Bios__Original_Street_Line_2__c = this.Line2;
                this.rcContactAddress.rC_Bios__Additional_Line_1__c = this.Line3;
                this.rcContactAddress.rC_Bios__Original_City__c = this.City;
                this.rcContactAddress.rC_Bios__Original_State__c = this.StateProv;
                this.rcContactAddress.rC_Bios__Original_Postal_Code__c = this.PostalCode;
                this.rcContactAddress.rC_Bios__Original_Country__c = this.Country;
                this.rcContactAddress.rC_Bios__Verified__c = this.IsValid;
                this.rcContactAddress.Overridden__c = this.IsOverridden;
            }
            
            return this.rcContactAddress;
        }
        set
        {
            rcContactAddress = value;
        }
    }
    
    public rC_Bios__Account_Address__c rcBiosAccountAddress
    {
        get
        {      
            if(this.isChanged)
            {
                this.rcAccountAddress.rC_Bios__Original_Street_Line_1__c = this.Line1;
                this.rcAccountAddress.rC_Bios__Original_Street_Line_2__c = this.Line2;
                this.rcAccountAddress.rC_Bios__Additional_Line_1__c = this.Line3;
                this.rcAccountAddress.rC_Bios__Original_City__c = this.City;
                this.rcAccountAddress.rC_Bios__Original_State__c = this.StateProv;
                this.rcAccountAddress.rC_Bios__Original_Postal_Code__c = this.PostalCode;
                this.rcAccountAddress.rC_Bios__Original_Country__c = this.Country;
                this.rcAccountAddress.rC_Bios__Verified__c = this.IsValid;
                this.rcAccountAddress.Overridden__c = this.IsOverridden;
            }
            
            return this.rcAccountAddress;
        }
        set
        {
            rcAccountAddress = value;
        }
    }
    
    public ValidatedAddress()
    {
        this.IsChanged = false;
        this.IsValid = false;
    }
    
    public ValidatedAddress(string line1, string line2, string line3, string city, 
                            string stateProv, string postalCode, string country, string addressId, boolean isValid, boolean isOverridden)
    {
        this.Line1 = line1;
        this.Line2 = line2;
        this.Line3 = line3;
        this.City = city;
        this.StateProv = stateProv;
        this.PostalCode = postalCode;
        this.Country = country;
        this.AddressId = addressId;
        this.IsValid = isValid;
        this.IsChanged = false;
        this.IsOverridden = isOverridden;
    }
    
    public ValidatedAddress(rC_Bios__Address__c address)
    {
    	this.rcBiosAddress = address;
        this.Line1 = address.rC_Bios__Street_Line_1__c;
        this.Line2 = address.rC_Bios__Street_Line_2__c;
        this.Line3 = address.Extra_Address_1__c;
        this.City = address.rC_Bios__City__c;
        this.StateProv = address.rC_Bios__State__c;
        this.PostalCode = address.rC_Bios__Postal_Code__c;
        this.Country = address.rC_Bios__Country__c;
        this.IsValid = address.Validated__c;
        this.IsOverridden = address.Overridden__c;
        this.IsChanged = false;
    }
    
    public ValidatedAddress(rC_Bios__Contact_Address__c address)
    {
        this.rcContactAddress = address;
        this.Line1 = address.rC_Bios__Street_Line_1__c;
        this.Line2 = address.rC_Bios__Street_Line_2__c;
        this.Line3 = address.rC_Bios__Additional_Line_1__c;
        this.City = address.rC_Bios__City__c;
        this.StateProv = address.rC_Bios__State__c;
        this.PostalCode = address.rC_Bios__Postal_Code__c;
        this.Country = address.rC_Bios__Country__c;
        this.IsValid = address.rC_Bios__Verified__c;
        this.IsOverridden = address.Overridden__c;
        this.IsChanged = false;
    }
    
    public ValidatedAddress(rC_Bios__Account_Address__c address)
    {
        this.rcAccountAddress = address;
        this.Line1 = address.rC_Bios__Street_Line_1__c;
        this.Line2 = address.rC_Bios__Street_Line_2__c;
        this.Line3 = address.rC_Bios__Additional_Line_1__c;
        this.City = address.rC_Bios__City__c;
        this.StateProv = address.rC_Bios__State__c;
        this.PostalCode = address.rC_Bios__Postal_Code__c;
        this.Country = address.rC_Bios__Country__c;
        this.IsValid = address.rC_Bios__Verified__c;
        this.IsOverridden = address.Overridden__c;
        this.IsChanged = false;
    }
}