/***********************************************************************************************************
 * Appirio, Inc
 * Name         : createReciprocalAllianceController
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Controller class of createReciprocalAlliancePage Page
 * Created Date : 16/Aug/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
public class createReciprocalAllianceController { 
	public Reciprocal_Alliance_File_Queue__c rpfq {get; Set;}
	public String retURL;

	/**
     *  @Method : createReciprocalAllianceController
     *  @Param : none
     *  @description :  constructor of class.
     *  @return : None
     */
	public createReciprocalAllianceController() {
        rpfq = new Reciprocal_Alliance_File_Queue__c();
		retURL = Apexpages.currentPage().getParameters().get('id');
    }

	/**
     *  @Method : save
     *  @Param : none
     *  @description : method for save button on page which saves the Reciprocal Alliance File Queue record.
     *  @return : PageReference
     */
	public PageReference save() {
		try {
			insert rpfq;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Record Saved Successfully'));
			if(!string.isBlank(retURL))
				return (new PageReference('/' + retURL));
			else
				return (new PageReference('/' + rpfq.Id));
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
		}
		return null;
	}

	/**
     *  @Method : cancel
     *  @Param : none
     *  @description :  method of cancel button on page.
     *  @return : PageReference
     */
	public PageReference cancel() {
		if(!string.isBlank(retURL))
			return (new PageReference('/' + retURL));
		else 
			return (new PageReference('/home/home.jsp'));
	}
}