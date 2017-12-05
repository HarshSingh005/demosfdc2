/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PaymentMethodTriggerHandler
 * Created By   : Ravi Chauhan
 * Purpose      : Handler class of PaymentMethodTrigger
 * Created Date : 08/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * * 14/09/2016                 Ashu Gupta              Added the null check for the Statement_Frequency__c field[I-235152]
 **********************************************************************************************************/
public class PaymentMethodTriggerHandler {
    
    private static final Id donorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    private static final Id EFTRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('EFT').getRecordTypeId();
    private static final Id ChargeCardRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Charge Card').getRecordTypeId();
    private static final Id PaypalRecordTypeId = Schema.SObjectType.rC_Giving__Payment_Method__c.getRecordTypeInfosByName().get('Paypal').getRecordTypeId();
    private static final String QUARTERLY = 'Quarterly';
    private static final String SPONSORSHIP = 'Sponsorship';
    private static final String RECURRINGGIFT = 'Recurring Gift';
    
    public static void OnAfterInsert(List<rC_Giving__Payment_Method__c> newPaymentMethods, Map<Id, rC_Giving__Payment_Method__c> paymentMethodNewMap) {
        updateStatementFrequencyOfDonor(newPaymentMethods);
    }
    
    public static void OnAfterUpdate(List<rC_Giving__Payment_Method__c> newPaymentMethods, Map<Id, rC_Giving__Payment_Method__c> PaymentMethodsOldMap, Map<Id, rC_Giving__Payment_Method__c> PaymentMethodsNewMap){
        markOpportunityForClawback(newPaymentMethods,PaymentMethodsOldMap,PaymentMethodsNewMap);
    }

    public static void OnBeforeInsert(List<rC_Giving__Payment_Method__c> newPaymentMethods)
    {
        DefaultAccountAndAddressInfo(newPaymentMethods);
    }

    //specify the Account for the Contact, if not already specified
    //populate the address info if not already populated.  
    //This is mostly for payment methods created from the website
    //because the UI for payment methods defaults this info already
    private static void DefaultAccountAndAddressInfo(List<rC_Giving__Payment_Method__c> newPaymentMethods)
    {
        set<Id> contactIds = new set<Id>();

        for(rC_Giving__Payment_Method__c method : newPaymentMethods)
            if(method.rC_Giving__Contact__c != null && (method.rc_Giving__Account__c == null || method.rC_Giving__Billing_Street__c == null))
                contactIds.add(method.rC_Giving__Contact__c);

        if(contactids.size() > 0)
        {
            Map<Id, Contact> contactMap = New Map<Id, Contact>([select Id, name, accountid, rC_Bios__Preferred_Mailing_Address__c, Phone,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_2__c,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c,
                                            rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c,
                                            rC_Bios__Preferred_Mailing_Address__r.Validated__c,
                                            rC_Bios__Preferred_Mailing_Address__r.Overridden__c
                                            from Contact
                                            where id in :contactIds]);

            for(rC_Giving__Payment_Method__c method : newPaymentMethods)
            {
                if(method.rC_Giving__Contact__c != null && (method.rc_Giving__Account__c == null || method.rC_Giving__Billing_Street__c == null))
                {
                    Contact contact = contactMap.get(method.rC_Giving__Contact__c);
                    method.rC_Giving__Card_Holder_Name__c = contact.name;
                    method.rC_Connect__Billing_Phone__c = contact.Phone;
                    method.rC_Giving__Account__c = contact.accountid;
                    method.rC_Giving__Billing_Contact_Name__c = contact.name;
                    method.rC_Giving__Billing_Street__c = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Street_Line_1__c;
                    method.rC_Giving__Billing_City__c = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__City__c;
                    method.rC_Giving__Billing_Postal_Code__c = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Postal_Code__c;
                    method.rC_Giving__Billing_State__c = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__State__c;
                    //system.assert(false, '==>' + CountriesRefCodes__c.getAll().values());
                    if(contact.rC_Bios__Preferred_Mailing_Address__c != null && contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c != null)// Ravi Chauhan | To handle null pointer exception
                        System.debug('country' +contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c);
                        method.rC_Giving__Billing_Country__c = LookupService.GetCountryISO2Code(contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c);
                    method.Billing_Country_ISO3__c = contact.rC_Bios__Preferred_Mailing_Address__r.rC_Bios__Country__c;
                    method.Validated_Address__c = contact.rC_Bios__Preferred_Mailing_Address__r.Validated__c;
                    method.Overridden_Address__c = contact.rC_Bios__Preferred_Mailing_Address__r.Overridden__c;
                }
            }
        } 

    }

    /**
    * The method updates the Statement Frequency of Donor Contact when a Payment method of record type (EFT OR Charge_Card OR Paypal)
    * is inserted.
    * 
    * @param  newPaymentMethods  List<rC_Giving__Payment_Method__c>
    * 
    */
    private static void updateStatementFrequencyOfDonor(List<rC_Giving__Payment_Method__c> newPaymentMethods){

        Set<Id> setDonors = new Set<Id>();
        List<Contact> donorContactListToBeUpadted = new List<Contact>();
        
        // Filtering only those Payment Methods whose record type is EFT OR Charge_Card OR Paypal
        for(rC_Giving__Payment_Method__c paymentMethod : newPaymentMethods){
            if((paymentMethod.RecordTypeId == EFTRecordTypeId || paymentMethod.RecordTypeId == ChargeCardRecordTypeId ||
                paymentMethod.RecordTypeId == PaypalRecordTypeId) && paymentMethod.rC_Giving__Contact__c != null)
                setDonors.add(paymentMethod.rC_Giving__Contact__c);
        }

        // If the setDonors list is empty then return form the method
        if(setDonors.size() == 0)
            return;
        
        // Fetching the Statement Frequency Picklist for the donors and update the value to 'Quarterly'
        for(Contact donor : [SELECT Statement_Frequency__c
                             FROM Contact 
                             WHERE Id IN :setDonors 
                             AND RecordTypeId = :donorRecordTypeId]){
             //Ashu Gupta : Sept 14,2016 
            //Added the null check below for the Statement_Frequency__c field--I-235152--
                                 if(donor.Statement_Frequency__c != null){
            donor.Statement_Frequency__c = QUARTERLY ;
            donorContactListToBeUpadted.add(donor);
            }        
         }
        
        if(donorContactListToBeUpadted.size() > 0)
            update donorContactListToBeUpadted;
        
    }
    
    /**
    * The method updates the Identified_for_Clawback__c to True of Sponsership Opportunity related to Payment Method 
    * when Payment method is deactivated.
    * 
    * @param  newPaymentMethods     List<rC_Giving__Payment_Method__c>
    * @param  paymentMethodsOldMap  Map<Id, rC_Giving__Payment_Method__c>
    * @param  paymentMethodsNewMap  Map<Id, rC_Giving__Payment_Method__c>
    * 
    */
    private static void markOpportunityForClawback(List<rC_Giving__Payment_Method__c> newPaymentMethods, Map<Id, rC_Giving__Payment_Method__c> paymentMethodsOldMap, Map<Id, rC_Giving__Payment_Method__c> paymentMethodsNewMap){

        List<Id>  filteredPaymentMethods = new List<Id>();
        List<Opportunity> opportunitiesListToBeUpadted = new List<Opportunity>();
        
        // Filtering only those Payment Methods based on the criteria that IsActive field has been changed from True to False
        for(rC_Giving__Payment_Method__c paymentMethod : newPaymentMethods){
            if(paymentMethodsOldMap.get(paymentMethod.Id).rC_Giving__Is_Active__c && !paymentMethodsNewMap.get(paymentMethod.Id).rC_Giving__Is_Active__c)
                 filteredPaymentMethods.add(paymentMethod.Id);
        }

        // If there is no Payment Method satisfying the above criteria then return from here
        if(filteredPaymentMethods.size() == 0)
            return;
            
        // Fetching those sponsership opportunities who are eligible for Clawback
        for(Opportunity opp : [SELECT Identified_for_Clawback__c, Start_Date__c, Date_Presponsorship_Started__c, Product_Type__c
                               FROM Opportunity 
                               WHERE rC_Giving__Payment_Method_Selected__c IN :filteredPaymentMethods
                               AND (Product_Type__c = :SPONSORSHIP OR Product_Type__c = :RECURRINGGIFT)
                               AND Vendor_Name__c != null
                               AND (Start_Date__c != null OR Date_Presponsorship_Started__c != null)
                               AND Identified_for_Clawback__c = false]){
            if(opp.Product_Type__c == RECURRINGGIFT && opp.Start_Date__c != null && (opp.Start_Date__c.daysBetween(System.today())) < 140){
                opp.Identified_for_Clawback__c = true ;
                opp.Identified_for_Clawback_Date__c = DateTime.now();// MR I-240744 I-240748 Identified for Clawback date field is not updating when Identified for Clawback field is updated to true
                opportunitiesListToBeUpadted.add(opp);
            }
            else if(opp.Product_Type__c == SPONSORSHIP && opp.Date_Presponsorship_Started__c != null && (opp.Date_Presponsorship_Started__c.daysBetween(System.today())) < 140){
                opp.Identified_for_Clawback__c = true ;
                opp.Identified_for_Clawback_Date__c = DateTime.now();// MR I-240744 I-240748 Identified for Clawback date field is not updating when Identified for Clawback field is updated to true
                opportunitiesListToBeUpadted.add(opp);
            }
            else if(opp.Product_Type__c == SPONSORSHIP && opp.Start_Date__c != null && (opp.Start_Date__c.daysBetween(System.today())) < 140){
                opp.Identified_for_Clawback__c = true ;
                opp.Identified_for_Clawback_Date__c = DateTime.now(); // MR I-240744 I-240748 Identified for Clawback date field is not updating when Identified for Clawback field is updated to true
                opportunitiesListToBeUpadted.add(opp);
            }
        }
        
        if(opportunitiesListToBeUpadted.size() > 0)
            update opportunitiesListToBeUpadted;
            
    }

}