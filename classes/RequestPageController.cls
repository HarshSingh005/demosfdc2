public class RequestPageController {
    public boolean sucsMsg {get;set;}   
 public Exam__c usrReg {
    get {
      if (usrReg == null)
        usrReg = new Exam__c();
      return usrReg;
    }
    set;
  }
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
}