@isTest
public class AccountTriggerTest {
    public static testMethod  void insRec(){
       List<Account> acList=new List<Account>();
       for(integer i=0;i<200;i++){
       acList.add(new Account(name='test'+String.valueOf(i),ShippingState='CA',BillingState='BA'));
       }
       test.startTest();
       insert acList;
       test.stopTest();
    }    
}