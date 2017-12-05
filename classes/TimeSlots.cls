public class TimeSlots {
    
   public TimeSlots(){
        
        
        
    }

    public class slotHouse{
        public DateTime startTime{get;set;}
        public DateTime endTime{get;set;}
        public String slotnum{get;set;}
        public Boolean isavailable{get;set;}
        public slotHouse(DateTime startTime,DateTime endTime,String slotnum, Boolean isavailable){
            startTime=this.startTime;
            endTime=this.endTime;
            slotnum=this.slotnum;
            isavailable=this.isavailable;
        }
    }
}