// Purpose: read in MCS code, and if 'active' close.
//    If MCS found, display MCS metadata
//    If MCS is already 'closed' or 'cancelled' throw error.  
// Developer: Dirk Koechner, 12/8/15

public class MCSScanClose {

    public Mail_Control_Slip__c MCS { get; private set; }
    public String MCS_id {get; set;}

    public MCSScanClose () {  // 0 arguments for custom controller constructor
        //Id id = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference scan() {    
    
       List<Mail_Control_Slip__c> MCSs = [SELECT Name, Participant__r.Name, NO_Lookup__r.Name, Child_Number1__c, MCS_Letter_Type__c, 
           MCS_Status__c, Case_Nbr__c, Donor__r.Name, Comments__c, Date_Closed__c, DFC_Opportunity__c
           FROM Mail_Control_Slip__c WHERE Name = :MCS_id ];

       if(!MCSs .isEmpty()){
           MCS= MCSs[0];
       } else {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MCS code does not exist in database'));
           return null;
       }
    
       if (MCS.MCS_Status__c == 'Closed') {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MCS code has already been closed'));
           return null;
       } else if (MCS.MCS_Status__c == 'Cancel') {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MCS code has already been cancelled'));
           return null;
       } else {

           //If we are closing a DF TYL MCS, set the DF Transaction to 'Received by Child'

           if (MCS.DFC_Opportunity__c != null) {
                Opportunity DFCopp = [select dfc_status__c from Opportunity where id = :MCS.DFC_Opportunity__c];

                //system.debug('>>>>> DFCopp.dfc_status__c-'+DFCopp.dfc_status__c);

                DFCopp.dfc_status__c = 'Received by Child';
                update DFCopp;
           }

           MCS.MCS_Status__c = 'Closed';
           MCS.Date_Closed__c = date.today();
           update MCS;
           
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'MCS Successfully Closed'));
           return null;
       }
              
     }
}