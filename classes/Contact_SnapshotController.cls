public with sharing class Contact_SnapshotController {
    public String controllerId { get; set; }
    public Contact contact { get; set; }
    public List<Contact> contactDetailList;
    public List<Contact> revenueDetailList;
    public List<Opportunity> prospectPlanList;
    public List<Opportunity> sponsorshipList;
    public List<Opportunity> fundingOpportunityList;
    public List<rC_Giving__Planned_Giving__c> plannedGivingList;
    public List<Modeling_and_Propensity__c> modelingAndPropensityList;
    
    //Static variable
    public static final String SPONSORSHIP = 'Sponsorship';
    public static final String CHILD_SPONSORSHIP = 'Child Sponsorship';
    public static final String PHILANTHROPY = 'Philanthropy';
    
    //get Opportunity Record type Map
    public static final Map<String, Schema.RecordTypeInfo> OPPORTUNITY_RT = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static final String OPPORTUNITY_RECORDTYPE_PROSPECTPLAN = OPPORTUNITY_RT.get('Prospect Plan').getRecordTypeId();
    
    //get Planned Giving Record type Map
    public static final Map<String, Schema.RecordTypeInfo> PLANNED_GIVING_RT = rC_Giving__Planned_Giving__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static final String PLANNED_GIVING_RECORDTYPE_BEQUEST = PLANNED_GIVING_RT.get('Bequest').getRecordTypeId();
    public static final String PLANNED_GIVING_RECORDTYPE_CHARITABLE_GIFT_ANNUITY = PLANNED_GIVING_RT.get('Charitable Gift Annuity').getRecordTypeId();
    
    public static final Map<String, Schema.RecordTypeInfo> RELATIONSHIP_RT = rC_Bios__Relationship__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static final String RELATIONSHIP_RECORDTYPE_CONTACT_GIVING = RELATIONSHIP_RT.get('Contact - Giving').getRecordTypeId();
    
    public static final Map<String, Schema.RecordTypeInfo> CONTACT_RT = Contact.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static final String CONTACT_RECORDTYPE_HOUSEHOLD = CONTACT_RT.get('Household').getRecordTypeId();
    public static final String CONTACT_RECORDTYPE_PARTICIPANT = CONTACT_RT.get('Participant').getRecordTypeId();
    
    public static final Map<String, Schema.RecordTypeInfo> ACCOUNT_RT = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static final String ACCOUNT_RECORDTYPE_HOUSEHOLD = ACCOUNT_RT.get('Household').getRecordTypeId();
    
    //wrapper class 
    /*public class opportunityToRelationship {
        public String Id { get; set; }
        list<rC_Bios__Relationships__c> relationshipList { get; set; }
    }*/
    
    //constructor
    public Contact_SnapshotController(ApexPages.StandardController controller) {
        this.contact = (Contact) controller.getRecord();
        controllerId = contact.Id;
    }
    
    public List<Contact> getContactDetailList() {
        contactDetailList = [
            SELECT Name
                 , Contact_Number__c 
                 , rC_Bios__Preferred_Mailing_Address__c
                 , rC_Bios__Preferred_Mailing_Address__r.Name
                 , rC_Bios__Preferred_Phone__c
                 , HomePhone
                 , rC_Bios__Work_Phone__c
                 , MobilePhone
                 , AssistantPhone
                 , OtherPhone
                 , rC_Bios__Preferred_Email__c
                 , rC_Bios__Home_Email__c
                 , rC_Bios__Work_Email__c
                 , rC_Bios__Assistant_Email__c
                 , rC_Bios__Other_Email__c
              FROM Contact
             WHERE Id = :controllerId
        ];
        
        return contactDetailList;
    }
    
    public List<Contact> getRevenueDetailList() {
        revenueDetailList = [
            SELECT Lifetime_Amount__c
                 , Last_Gift_Amount__c
                 , Last_gift_date__c
                 , Largest_Gift_Amount__c
                 , Largest_Gift_Date__c
              FROM Contact
             WHERE Id = :controllerId
        ];
        
        return revenueDetailList;
    }
    
    public List<Opportunity> getProspectPlanList() {
        prospectPlanList = [
            SELECT Name
                 , Prospect_Plan_type__c
                 , StageName
              FROM Opportunity
             WHERE RecordTypeId = :OPPORTUNITY_RECORDTYPE_PROSPECTPLAN 
               AND OwnerId = :UserInfo.getUserId()
               AND rC_Giving__Hard_Credit_Contact__c = :controllerId
        ];
        
        return prospectPlanList;
    }
    
    
     public List<Opportunity> getSponsorshipList() {
        // I-253896 | Updated the query. Now fetching participant details from Participant lookup rather than the relationship record 
        sponsorshipList = [
            SELECT o.rC_Sponsorship__Sponsorship_Status__c
                 , o.Opportunity_Group_Id_Start_Date__c
                 , o.Participant__c
                 , o.Participant__r.National_Office__c
                 , o.Participant__r.Name
                 , o.Participant__r.rC_Bios__Gender__c
                 , o.Participant__r.rC_Bios__Age__c
                 , o.Participant__r.National_Office__r.BillingCountry
              FROM Opportunity o
             WHERE rC_Giving__Hard_Credit_Contact__c = :controllerId
               AND Product_Type__c = :Contact_SnapshotController.SPONSORSHIP 
               AND Product_Sub_Type__c = :Contact_SnapshotController.CHILD_SPONSORSHIP
        ];
        
        //for(Opportunity)
        
        return sponsorshipList;
    }
    
    
    public List<Opportunity> getFundingOpportunityList() {
        fundingOpportunityList = [
            SELECT Opportunity_Type__c
                 , Prospect_Designation__c
                 , Prospect_Designation__r.Name
                 , StageName
                 , Expected_Ask_Amount__c
                 , Expected_Ask_Date__c
                 , Submitted_Donor_Amount__c
                 , Ask_Date__c
                 , Approved_Donor_Amount__c
                 , CloseDate
              FROM Opportunity
             WHERE Opportunity_Type__c = :Contact_SnapshotController.PHILANTHROPY
               AND rC_Giving__Hard_Credit_Contact__c = :controllerId
               AND OwnerId = :UserInfo.getUserId()
        ];
        
        return fundingOpportunityList;
    }
    
    public List<rC_Giving__Planned_Giving__c> getPlannedGivingList() {
        plannedGivingList = [
            SELECT rC_Giving__Stage__c
                 , RecordTypeId
                 , RecordType.Name
                 , Name
              FROM rC_Giving__Planned_Giving__c
             WHERE ( RecordTypeId = :Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_BEQUEST
                  OR RecordTypeId = :Contact_SnapshotController.PLANNED_GIVING_RECORDTYPE_CHARITABLE_GIFT_ANNUITY)
               AND rC_Giving__Contact__c = :controllerId
        ];
        
        return plannedGivingList;
    }
    
    public List<Modeling_and_Propensity__c> getModelingAndPropensityList() {
        modelingAndPropensityList = [
            SELECT Age__c
                 , Marital_Status__c
                 , Planned_Giving_Likelihood__c
              FROM Modeling_and_Propensity__c
             WHERE Contact__c = :controllerId
        ];
        
        return modelingAndPropensityList;
    }
    
}