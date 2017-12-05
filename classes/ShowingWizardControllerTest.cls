@isTest
public class ShowingWizardControllerTest {
    private static testMethod void trlrtest(){
        createData();//Set up data for the test class
        showing__c shw=[SELECT ID FROM Showing__c Limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(shw);
        ShowingWizardController swcont=new ShowingWizardController(sc);
        swcont.gernrelst='Animation';
        PageReference pr= swcont.sendGenre();
        PageReference svshwng= swcont.saveShowing();
        PageReference cnlshow= swcont.cancelShowing();
        
        swcont.showGenre();
        swcont.FirstPage();
/*        swcont.previous();        
        swcont.next();
        swcont.LastPage();*/
        Boolean prv= swcont.getprev();
        Boolean nxt= swcont.getnxt(); 
    }
    private static void createData(){
        List<Feature__c> ftrList=new List<Feature__c>();  //Creating the list of feature
        List<Showing__c> shwList=new List<Showing__c>();  //Creating the List of showing
        List<Trailer__c> trlList=new List<Trailer__c>();  //Creating the List of Trailer
        Integer i=0;
        for(i=0;i<3;i++){
            Feature__c testftr=new Feature__c(name='testfeature'+String.valueOf(i),Genre__c='Action',Release_Date__c=System.today(),Trailer_Impression__c=123);
            if(i/2==0){  
                testftr.Genre__c='Animation';
            }else{
                testftr.Genre__c='Comedy';
            }
            ftrList.add(testftr);           
        }
        insert ftrList;
        for(i=0;i<3;i++){
           Showing__c shw=new showing__c(name='testfeature'+String.valueOf(i),Date__c=System.today(),Screen_Number__c='test',Start_Time__c='test',Tickets_Sold__c=10); 
           
            shw.Feature__c=ftrList.get(i).ID;
            shwList.add(shw);
        }
        insert shwList; 
        for(i=0;i<3;i++){
        Trailer__c trl=new Trailer__c(name='testfeature'+String.valueOf(i),Feature__c=ftrList.get(i).ID,Showing__c=shwList.get(i).ID);
            trlList.add(trl);
            }
        Test.startTest();
        insert trlList;
        Test.stopTest();
    }
}