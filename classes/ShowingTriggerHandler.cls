/*
Trigger handler on the Showing object.
*/
public class ShowingTriggerHandler {
    public static void onAfterUpdate(List<Showing__c> shwList,Map<Id,Showing__c> shwMap){
        ticketSold(shwList,shwMap);
    }
    public static void onAfterInsert(Map<Id,Showing__c> shwMap){
        ticketSold(shwMap.Values(),null);
    }
    //Code to check the count of the ticket solds 
    private static void ticketSold(List<Showing__c> shwList,Map<Id,Showing__c> shwMap){
        Map<ID,Decimal> ftrTckt=new Map<ID,Decimal>();
        Decimal tktsold;
        List<Feature__C> ftrList=new List<Feature__C>();
        Set<Id> ftrIDs=new Set<Id>();
        //Calculating the ticket sold on the feature
        for(Showing__c show : shwList){
            ftrIDs.add(show.Feature__c);
        }
        for(Showing__c show : [Select Id,Tickets_Sold__c,Feature__c FROM Showing__c Where Feature__c in : ftrIDs]){
            if(ftrTckt.containsKey(show.Feature__c)){
                tktsold=ftrTckt.get(show.Feature__c)+show.Tickets_Sold__c ;
                ftrTckt.put(show.feature__c,tktsold);
            }else if(show.feature__c!=null){
                ftrTckt.put(show.feature__c,show.Tickets_Sold__c);
            }    
        }
        System.debug('---->'+ftrTckt);
        //Setting the trailer impression for the feature
        if(ftrTckt!=null){
            for(Feature__c ft : [SELECT ID ,Trailer_Impression__c FROM Feature__c Where Id in : ftrTckt.keySet()]){
                if(ftrTckt.containsKey(ft.Id)){
                    ft.Trailer_Impression__c=ftrTckt.get(ft.Id);
                }
                ftrList.add(ft);
            }
            if(ftrList!=null){
                update ftrList;
                System.debug('----->ftrTckt='+ftrTckt);
            }
        }    
    }
}