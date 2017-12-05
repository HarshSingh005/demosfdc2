public class AccountUtils {
    public static List<Account> accountsByState(String stat){
        return [SELECT ID,Name FROM Account Where BillingState=:stat];
    }
}