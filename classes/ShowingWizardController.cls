public class ShowingWizardController {
    public String selectedGenre { get;set;}
    public String gernrelst{get;set;}
    public Showing__c showng{get;set;}
    public Boolean viewChart{get;set;}
    public String hdrName{get;set;}
    public Feature__c featur{get;set;}   
    public List<featurData> lstFeature{get;set;}
    public List<SelectOption> options{get;set;}
    public Map<String,Integer> mapData{get;set;}
    public List<PieWedgeData> data{get;set;}
    private Integer totalRecs=0;
    private Integer OffsetSize=0;
    private Integer LimitSize=4;
    public Integer currPage{get;set;}
    public Integer maxPage{get;set;}
    public String dbg{get;set;}
    
    //Constructor of the class
    public ShowingWizardController(ApexPages.StandardController controller){
        ID shwid = (Id)controller.getRecord().id;
        showng=[Select Name,Id,Date__c,Feature__c,Start_Time__c,Primary_Genre__c,Screen_Number__c,Tickets_Sold__c FROM Showing__c Where Id=:shwid];
        getshowFeatures('Any Type');
        currPage=1;   
         if(maxPage==0){
            currPage=0;
        }
        getMygenre();
        viewChart=false;
        //Setting the Genre option list.
        //  lstFeature=getshowFeatures();//creating the Feature datatable
    }
    public pagereference sendGenre(){
        system.debug('List of Genre---->'+gernrelst+'---'+viewChart);
        mapData=new Map<String,Integer>();
        Integer count=0;
        if(gernrelst!=''){
            String[] arrTest = gernrelst.split(',');
            viewChart=true;
            for(String st : arrTest){
                if(mapData.containsKey(st)){
                    count=mapData.get(st)+1;
                    mapData.put(st,count);
                }else{
                    mapData.put(st,1);
                }
            }
            getPieData();
            System.debug('List of the genre---->'+arrTest);            
        }else{
            viewChart=false;
        }
        return null;
    }
    public Pagereference saveShowing(){
        PageReference sve;
        try{
        update showng;
         sve= new PageReference('/'+showng.id);
         sve.setRedirect(true);
         return sve;
        }catch(Exception e){
         
         ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0) );
         ApexPages.addMessage(msg);
            System.debug('Exception' +e.getStackTraceString()+'Exception Message'+msg);
            sve=null;
        }
               return sve;
    }
    public Pagereference cancelShowing(){        
        PageReference sve = new PageReference('/'+showng.id);
        sve.setRedirect(true);
        return sve;  
    }
    public void showGenre(){
        System.debug('showing debug--->'+selectedGenre);
        if(mapData!=null){
        mapData.clear();//removing the chart content on select
        OffsetSize=0;
            lstFeature.clear();
        }  
        //Setting the fields to initial values
        viewChart=false;
        totalRecs=0;
        OffsetSize=0;
        LimitSize=4;
        
        getshowFeatures(selectedGenre);
        currPage=1;
        if(maxPage==0){
            currPage=0;
        }
    }
    private void getMygenre() {
        System.debug('------------->tester');
        options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Feature__c.Genre__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('Any Type', '--Any Type--'));
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
    }
    //Pagination Logic 
    private void getshowFeatures(String genreType){
        ID showId=showng.ID;
        
        if(showId!=null){
            lstFeature=new List<featurData>();
            List<Feature__c> ftrTemp=new List<Feature__c>();
            Set<ID> shwIds=new Set<ID>();     
            List<Trailer__c> shwList=    [SELECT Feature__c FROM Trailer__c Where Showing__c  =:showId ];
            System.debug('Showing List-->'+shwList);
            //Fetch Feature ID
            for(Trailer__c shwng : shwList){
                shwIds.add(shwng.Feature__c);
            }
            featurData fd;
            //Use the string to query from the database
            String strQuery ='SELECT Name ,Id,Release_Date__c,Trailer_Impression__c,Genre__c FROM Feature__c WHERE ID IN : shwIds';
            String qry='SELECT COUNT() FROM Feature__c WHERE ID IN : shwIds';
            if(genreType!='' &&  genreType!='Any Type'){
                strQuery+=' and Genre__c=:genreType';
                qry+=' and Genre__c=:genreType';
            }
            //totalRecs=Database.countQuery(strquery);
            strQuery += ' ORDER BY Name  ASC, CreatedDate DESC LIMIT :LimitSize OFFSET :OffsetSize';
            ftrTemp = Database.query(strQuery);
            totalRecs=Database.countquery(qry);//query to count all the records which is meeting the condition
            System.debug('Total Records from query'+totalRecs);
            for(Feature__c ftr: ftrTemp){
                lstFeature.add(new featurData(False,ftr)); 
            }
             maxPage=totalRecs/LimitSize;
            
             if(math.mod(totalRecs,LimitSize)>0){
                maxPage++;
             }
            
            System.debug('MAx Page--->'+maxPage+'Total Records'+totalRecs+'Limit Size'+LimitSize);
        }
    }
     
    public void FirstPage(){
        currPage=1;
        OffsetSize = 0;
        getshowFeatures(selectedGenre);
    }
    public void previous(){
        
        OffsetSize = (OffsetSize-LimitSize);
        getshowFeatures(selectedGenre);
        currPage--;
    }
    public void next(){
        OffsetSize = OffsetSize + LimitSize;
        getshowFeatures(selectedGenre);
        currPage++;
    }
    public void LastPage(){
        currPage=maxPage;
        System.debug('OffsetSize-->'+OffsetSize+'totalrecs-->'+totalrecs+'LimitSize-->'+LimitSize);             
         if(math.mod(totalRecs,LimitSize)>0){
        OffsetSize = totalrecs - 1;
        }else{
          OffsetSize = totalrecs ;  
        }  
        getshowFeatures(selectedGenre);
    }
    public boolean getprev(){        
        if(OffsetSize == 0){            
            return true;
        }   else {            
            return false;
        }
    }
    public boolean getnxt(){
        if((OffsetSize + LimitSize) >= totalRecs){            
            return true;
        }else {            
            return false;
        }
    }
    //Logic For Pagination button end.
    
    //Donut Chart logic 
    public List<PieWedgeData> getPieData() {
        data = new List<PieWedgeData>();
        if(mapData!=null){
            for(String str : mapData.keySet()){
                data.add(new PieWedgeData(str,mapData.get(str)));           
            }
        }
        return data;
    }
    // Wrapper class for Donut Chart
    public class PieWedgeData {
        public String caseType { get; set; }
        public Integer caseCount { get; set; }
        public PieWedgeData(String caseType, Integer caseCount) {
            this.caseType = caseType;
            this.caseCount = caseCount;
        }
    }
    // Wrapper class for the Feature datatable
    public class featurData{
        Public feature__c feature{get;set;}
        Public Boolean Slct{get;set;}
        public featurData(Boolean Slct,feature__c feature){
            this.feature=feature;
            this.slct=slct;
        }
    }
}