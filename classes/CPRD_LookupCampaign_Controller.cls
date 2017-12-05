public with sharing class CPRD_LookupCampaign_Controller {

    public String query { get; set; }
    public List<Campaign> campaigns { get; set; }
    public Boolean doneLookup { get; set; }

    public CPRD_LookupCampaign_Controller() {
        doneLookup = false;
    }

    public PageReference runQuery() {
        if (String.isBlank(query)) {
            return null;
        }
        String queryterm = '%' + query + '%';
        campaigns = [SELECT Id, Name, Source_Code_Autonumber__c
                    FROM Campaign 
                    WHERE (Name LIKE :queryterm OR Source_Code_AutoNumber__c LIKE :queryterm)];
        doneLookup = true;
        return null;
    }
}