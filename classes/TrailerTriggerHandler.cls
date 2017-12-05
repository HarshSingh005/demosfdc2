public class TrailerTriggerHandler {
    public static void onAfterUpdate(List<Trailer__c> trlList,Map<Id,Trailer__c> trlMap){
        //Need to remove just for testing purpose
        mostUsedGenre(trlMap);
    }
    public static void onAfterInsert(Map<Id,Trailer__c> trlMap){
        mostUsedGenre(trlMap);
    }
    //Method to get most common string in a List
    private static String maxUsedString(List<String> strList){
        Map<String,Integer> strMap=new Map<String,Integer>();
        List<String> strlst=new List<String>();
        Integer counter,max=0;
        for(String str : strList){
            if(strMap.containsKey(str)){
                counter=strMap.get(str)+1;
                strMap.put(str,counter);
                if(counter>=max){
                    max=counter;}
            }else{
                strMap.put(str,0);}
        }     
        for(String str : strList){
            if(strMap.containsKey(str)){
                if(strMap.get(str)==Max){
                    strlst.add(str);
                }
            }
        }
        strlst.sort();
        System.debug('Maximum occuring string ===>'+strlst[0]);
        if(strlst!=null){
            return strlst[0];
        }else{
            return '';
        }
    }
    private static void mostUsedGenre(Map<ID,Trailer__c> trlMap){
        Map<ID,List<String>> ftrGenrMap=new Map<ID,List<String>>();
        Map<ID,String> showPrimGenMap=new Map<ID,String>();
        List<String> genrList=new List<String>();
        List<Showing__c> lstShowing=new List<Showing__c>();
        Set<ID> shwIds=new Set<ID>();
        //Logic to add the feature genre List into Map of Showing 
        For(Trailer__c trailer : trlMap.values()){
            shwIds.add(trailer.Showing__c);
        }
        For(Trailer__c tlr :[SELECT Feature__c,Showing__c,Feature__r.Genre__c FROM Trailer__c Where Showing__c in : shwIds]){
            genrList=new List<String>();
            if(tlr.Feature__r.Genre__c!=''){
                if(ftrGenrMap.containsKey(tlr.Showing__c)){
                    genrList=ftrGenrMap.get(tlr.Showing__c);
                    genrList.add(tlr.Feature__r.Genre__c);
                    ftrGenrMap.put(tlr.Showing__c,genrList);
                }else{
                    genrList.add(tlr.Feature__r.Genre__c);
                    ftrGenrMap.put(tlr.Showing__c,genrList);
                    showPrimGenMap.put(tlr.Showing__c,'');
                }
            }   
            System.debug('Genre List'+genrList);
        }
        System.debug('feature Genre Map ======>'+ftrGenrMap);        
        //Logic to find Genre with maximum occurence
        For(Id showIDs : showPrimGenMap.keySet()){
            if(ftrGenrMap.containsKey(showIDs)){
                //calling maxUsedString to set showPrimeGenMap
                showPrimGenMap.put(showIDs,maxUsedString(ftrGenrMap.get(showIDs)));
            }
        }
        System.debug('Show Prime Genre Map ======>'+showPrimGenMap);
        if(showPrimGenMap!=null){
            For(Showing__c shwing : [SELECT Id, Primary_Genre__c FROM Showing__c Where Id in :showPrimGenMap.keySet()]){
                if(showPrimGenMap.containsKey(shwing.ID)){
                    shwing.Primary_Genre__c=showPrimGenMap.get(shwing.Id);
                }
                lstShowing.add(shwing);
            }
        }
        if(lstShowing!=null){
            update lstShowing;
        }
    }
}