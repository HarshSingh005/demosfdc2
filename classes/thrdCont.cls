public class thrdCont {

    @auraEnabled
    public static String multpcklst(){
        List<String> stList=new List<String>();
        stList.add('One');
        stList.add('Two');
        stList.add('Three');
        stList.add('Four');
        return JSON.serialize(stList);
    }
}