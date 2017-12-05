public class MultipleUserEvents {
    public class chkres{
         String name{get;set;}
         ID usrId{get;set;}
         ID csId{get;set;}
         public chkres(String name,ID usrId,ID csId){
            name=this.name;
            usrId=this.usrId;
            csId=this.csId;
        }
    }
    public static void crtEvents(){
        Map<ID,String> unmMap=new Map<ID,String>();
        Map<ID,String> grnmMap=new Map<ID,String>();
        Map<ID,String> grpNmMap=new Map<ID,String>();
        Map<Id,Set<Id>> grusrMap=new Map<Id,Set<Id>>();
        Set<ID> grpIds =new Set<Id>();
        Set<ID> usrIds =new Set<ID>();   
        String str;
        //Logic to set the values in the wrapper so that u can set the values into it.
        List<Case> ownrLst=[SELECT ID,Subject ,OwnerID FROM CASE WHERE STATUS='Escalated' and SLAViolation__c='Yes'];
        //Seperate Group and Users       
        for(Case cs : ownrLst){
            String chkId=String.valueOf(cs.OwnerID);
            if(chkId.startsWithIgnoreCase('00G')){
                grnmMap.put(cs.Id,cs.Subject+'-'+String.valueOf(cs.OwnerId));//Create Group Map
                grpIds.add(cs.OwnerId);//Create Group Set
            }
            else if(chkId.startsWithIgnoreCase('005')){
                unmMap.put(cs.Id,cs.Subject+'-'+String.valueOf(cs.OwnerId));//Create User Map
                usrIds.add(cs.OwnerId);//Create User Set
                System.debug('User Values'+cs.Subject+'-'+String.valueOf(cs.OwnerId));
            }    
        }
        Set<Id> usrSet=new Set<Id>();
        List<Event> eList1=new List<Event>();    
        //Fetch UserID from the group 
        if(!grpIds.isEmpty()){ 
            //logic to get the userId on the basis of the GroupId's
            for(GroupMember gm : [SELECT UserOrGroupId,GroupId FROM GroupMember WHERE GroupId =:grpIds]){
                usrSet=new Set<Id>();
                if(grusrMap.containsKey(gm.GroupId)){
                 usrSet= grusrMap.get(gm.GroupId);
                  usrSet.add(gm.UserOrGroupId);  
                  grusrMap.put(gm.GroupId,usrSet);                    
                }else{
                usrSet.add(gm.UserOrGroupId);
                grusrMap.put(gm.GroupId,usrSet);
              }
            }            
            DateTime strtdt = System.now().addMinutes(360);
            DateTime enddt = System.now().addMinutes(390);
            //Due functionality will be to check the event of the user and fetch the position of the calendar
              //Logic for the creation of the event from the given string 
              //logic for the  creation of the event      
            for(String grString : grnmMap.values()){
                usrSet=new Set<Id>();
                usrSet=grusrMap.get(Id.valueOf(grString.substringAfter('-')));
                for(Id usrId : usrSet){
                    Event event = new Event(OwnerId = usrId,StartDateTime = strtdt,EndDateTime = enddt , Subject = grString.substringBefore('-'));     
                    eList1.add(event);
               }
            } 
            insert eList1;
            System.debug('eList1--->'+eList1);
        }
            List<Event> eList=new List<Event>();    
            DateTime strtdt = System.now().addMinutes(360);
            DateTime enddt = System.now().addMinutes(390);
        if(!usrIds.isEmpty()){
            for(String unmString : unmMap.values()){
                if(unmString!=null){                    
              Event event = new Event(OwnerId = Id.valueOf(unmString.substringAfter('-'))
                                       ,StartDateTime = strtdt
                                       ,EndDateTime = enddt 
                                       , Subject = unmString.substringBefore('-'));     
               eList.add(event);
                }}
             } 
            insert eList;
            System.debug('eList1--->'+eList);
        }       
    }