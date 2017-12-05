public with sharing class VouvherController {
     public Exam__c usrReg {
    get {
      if (usrReg == null)
        usrReg = new Exam__c();
      return usrReg;
    }
    set;
  }
    public Boolean sucsMsg{get;set;}
    public string selectedValue { get;set; }
    public List<SelectOption> statusOptions { get;set; }
    public integer maxval{get;set;}
    public Map<String,List<mrgrprt>> vmaps {get;set;}
    public Map<String, Integer> listSizeMap {get;set;}
    public VouvherController(){
     //   usrReg.Name='test';
        sucsMsg=false;
        maxval=0;
        selectedValue='Fail';
        checkValue();
    }
    
      // save button is clicked
  public PageReference save() {

    try {
      insert usrReg; // inserts the new record into the database
        sucsMsg=true;
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request submitted successfully'));

    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new exam Record.'));
      return null;
    }

    // if successfully inserted new contact, then displays the thank you page.
    return null;
  }
    
    
    
    public void setpickVal()
    {
        Schema.DescribeFieldResult statusFieldDescription = Voucher__c.Status__c.getDescribe();
        statusOptions = new list<SelectOption>(); 
        statusOptions.add(new SelectOption('None','--Select--'));
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues()){
            statusOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }
    public void checkValue(){
        vmaps=new Map<String,List<mrgrprt>>();  
        listSizeMap=new Map<String,Integer>();
        if(selectedValue!='None'){
            Integer countStatus;
            List<mrgrprt> tmpvlst;
            List<VOUCHER__C> vlst=[SELECT Drive_Name__c,Exam__c,Resource__c FROM VOUCHER__C WHERE STATUS__C=:selectedValue];
                for(Voucher__C vch : vlst){
                    tmpvlst=new List<mrgrprt>();
                    if(vmaps.containskey(vch.Drive_Name__c)){
                    tmpvlst=vmaps.get(vch.Drive_Name__c);
                    tmpvlst.add(new mrgrprt(vch.Exam__c,vch.Resource__c));
                    vmaps.put(vch.Drive_Name__c,tmpvlst);
                    }else{   
                      tmpvlst.add(new mrgrprt(vch.Exam__c,vch.Resource__c));	
                      vmaps.put(vch.Drive_Name__c,tmpvlst);
                     }            
                    }
                }
         for(String key : vmaps.keySet()){
            listSizeMap.put(key, vmaps.get(key).size());
        }
    }
    
    public List<VOUCHER__C> getfinalReport(){
        List<VOUCHER__C> vlist=new List<VOUCHER__C>(); 
         List<item> itlst=new List<item>();
        if(selectedValue!='None'){
        Integer countStatus;
        Map<String,Integer> vlmp=new Map<String,Integer>(); 
        vlist=[SELECT Drive_Name__c,Exam__c,Resource__c FROM VOUCHER__C WHERE STATUS__C=:selectedValue];
        }
        return vlist;
    }
    
    public List<item> getbarData(){
        List<item> itlst=new List<item>();
        if(selectedValue!='None'){
        Integer countStatus;
        Map<String,Integer> vlmp=new Map<String,Integer>(); 
        List<VOUCHER__C> vlst=[SELECT Drive_Name__c,Status__c FROM VOUCHER__C WHERE STATUS__C=:selectedValue];
        for(Voucher__C vch : vlst){
            if(vlmp.containskey(vch.Drive_Name__c)){
                countStatus=vlmp.get(vch.Drive_Name__c)+1;
                vlmp.put(vch.Drive_Name__c,countStatus);
            }else{   countStatus=1;            
                  vlmp.put(vch.Drive_Name__c,countStatus);
                 }
            if(countStatus>maxval){
                maxval=countStatus;}
        }
        for(String str : vlmp.keySet()){
            itlst.add(new item(str,vlmp.get(str)));
        }
        }
        return itlst;
    }
    public List<pieWedgeChart> getPieData() {
        List<pieWedgeChart> chrt = new List<pieWedgeChart>();
        Integer countExam;
        Map<String,Integer> piMp=new Map<String,Integer>(); 
        if(selectedValue!='None'){
        List<VOUCHER__C> vlst=[SELECT Exam__c,Status__c FROM VOUCHER__C WHERE STATUS__C=:selectedValue];
        for(Voucher__C vch : vlst){
            if(piMp.containskey(vch.Exam__c)){
                countExam=piMp.get(vch.Exam__c)+1;
                piMp.put(vch.Exam__c,countExam);
                
            }else{   countExam=1;            
                  piMp.put(vch.Exam__c,countExam);
                 }
        }
        for(String str : piMp.keySet()){
            chrt.add(new pieWedgeChart(str,piMp.get(str)));
        }
        }
        return chrt;
    }
    public class mrgrprt{
       public String exam{get;set;}
       public String resrc{get;set;}
        public mrgrprt(String exam,String resrc){
            this.exam=exam;
            this.resrc=resrc;
        }
        
    }
    public class Item {
        public String name;
        public Integer data;
        public Item(String name,Integer data){
            this.name=name;
            this.data=data;
        }
    }
    public class pieWedgeChart{
        public String name;
        public Integer wedge;
        public pieWedgeChart(String name,Integer wedge){
            this.name=name;
            this.wedge=wedge;
        }
    }
}