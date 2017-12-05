public with sharing class CPRD_LookupDonor_Controller {
    public String query { get; set; }
    public List<Contact> contacts { get; set; }
    public Boolean doneLookup { get; set; }

    public CPRD_LookupDonor_Controller() {
        doneLookup = false;
    }

    public PageReference runQuery() {
        if(String.isBlank(query)){
            return null;
        }
//        List<List<Contact>> searchResults = [FIND :query IN ALL FIELDS RETURNING Contact (Id, Name, Donor_Number__c)];
//        contacts = searchResults[0];
        String queryterm = '%'+query+'%';
        contacts = [SELECT Id, Name, Donor_Number__c FROM Contact WHERE RecordType.Name='Household' AND (Name LIKE :queryterm OR Donor_Number__c LIKE :queryterm)];
        doneLookup = true;
        return null;
    }
}