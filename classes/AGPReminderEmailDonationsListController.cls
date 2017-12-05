/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AGPReminderEmailDonationsListController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Used to render a list of upcoming donations for a hard credit contact
 * Created Date : 06/21/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/21/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AGPReminderEmailDonationsListController 
{
    public List<Opportunity> donations{get;set;}
    
    public string hardCreditContactId
    {
        get;
        set
        {
    		date fiveDaysFromToday = date.today().addDays(5);
            
            this.donations = [select id,
                             Amount,
                             Product_Sub_Type__c,
                             rC_Giving__Payment_Method_Selected__r.RecordType.Name,
                             rC_Giving__Payment_Method_Selected__r.rC_Giving__Account_Number_Last_4__c,
                             rC_Giving__Parent__r.Participant__r.Short_Name__c,
                             rC_Giving__Parent__r.rC_Giving__Giving_Frequency__c
                             from Opportunity
                             where RecordType.Name = 'Transaction'
                             and rC_Giving__Hard_Credit_Contact__c = :value
                             and rC_Giving__Parent__r.AGP_Method__c = true
                             and rC_Giving__Parent__r.rC_Giving__Giving_Frequency__c in ('Annually','Semi-Annually','Quarterly')
                             and CloseDate = :fiveDaysFromToday
                             and StageName != 'Completed'];        
        }
    }
    
}