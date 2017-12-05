public class ActionFunctionCLS {
  public Account actObj{get;set;}
   PageReference prf= null;
    public ActionFunctionCLS(){
      actObj = new Account();
    }
 
   
    public pagereference Saverec(){
        System.debug('Changes have been done for the account');
   if(actobj.Name !=''){
    insert actobj;
   
   }
   else{
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please Enter Name.');
     ApexPages.addMessage(myMsg);
   
   }
   if(actobj.id !=null){
  
      // Send the user to the detail page for the new account.
      prf = new PageReference('/'+actobj.id);
      prf.setRedirect(true);
   
   }
   return prf;
    }

}