public class AccountTriggerHandler {
    public static void  CreateAccounts(List<Account> accList){
        List<Account> accTOInsert=new List<Account>();
        For(Account ac : accList){
            if(ac.ShippingState!=ac.BillingState){
                ac.ShippingState=ac.BillingState;
            }
        }
    }
}