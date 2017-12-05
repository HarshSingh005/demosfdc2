public class secComp {
    //Getting picklist values from the Account SLA field in the JSON format
    @AuraEnabled
    public Static String getSLApickList(){
        List<String> pickvalList=new List<String>();    
        Schema.DescribeFieldResult fldResult=Account.SLA__c.getDescribe();     
        List<Schema.PicklistEntry> ple=fldResult.getPicklistValues();
        for(Schema.PicklistEntry pl : ple){
            pickvalList.add(pl.getLabel());
        }   
           return JSON.serialize(pickvalList);
           //return pickvalList;
    }

}