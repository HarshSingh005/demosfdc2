public class Pagination_min {

    Public Integer noofRecords {get; set;}
    public integer size {get; set;}
   
    public Apexpages.standardsetController setcon{
        get{
            if(setCon == null){
                size = 5;
                String queryString = 'Select Name, Type, BillingCity, BillingState, BillingCountry from Account order by Name';
                setcon = new apexpages.standardsetController(Database.getquerylocator(queryString));
                setcon.setpagesize(size);
                noofRecords = setcon.getResultsize();
            }
            return setcon;
        }
         set;
    }
    Public list<Account> getAccounts(){
        list<Account> acclist = new list<Account>();
         for(Account ac : (list<Account>)setcon.getrecords()){
             acclist.add(ac);
         }
        return accList;
       
      
    }
   
}