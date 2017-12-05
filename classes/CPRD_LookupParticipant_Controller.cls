public with sharing class CPRD_LookupParticipant_Controller {
    public String query { get; set; }
    public List<Contact> contacts { get; set; }
    public Boolean doneLookup { get; set; }

    public CPRD_LookupParticipant_Controller() {
        doneLookup = false;
    }

    public PageReference runQuery() {
        if (String.isBlank(query)) {
            return null;
        }
//        List<List<Contact>> searchResults = [FIND :query IN ALL FIELDS RETURNING Contact (Id, Name, Donor_Number__c)];
//        contacts = searchResults[0];
        String queryterm = '%' + query + '%';
        contacts = [SELECT Id, Name, Child_Number__c,National_Office_Number__c,Community_Number__c  FROM Contact WHERE RecordType.Name = 'Participant' AND (Name LIKE :queryterm OR Contact_Number__c LIKE :queryterm)];
        doneLookup = true;
        return null;
    }
}