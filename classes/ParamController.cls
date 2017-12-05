public class ParamController {
    @auraEnabled
    public static List<Account> accInfo(String nm){
        nm=nm.trim();
        String str='%'+nm+'%';
        return [SELECT Name ,Type,Active__c,Website,DunsNumber FROM Account where name Like : str];
    } 
     @auraEnabled
    public static boolean updtAcco(Account acct){
        try{
            update acct;
        }catch(Exception e){
            return false;
        }
        return true;
    }
}