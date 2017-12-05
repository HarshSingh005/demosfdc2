/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactAddressEditRedirectController 
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Redirects to new Contact Manage Address page from list button
 * Created Date : 04/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class ContactAddressEditRedirectController 
{
    public PageReference Redirect()
    {
    	PageReference ref = Page.Contact_ManageAddresses;
        ref.getParameters().put('id',Apexpages.currentPage().getParameters().get('id'));
        ref.getParameters().put('retURL',Apexpages.currentPage().getParameters().get('retURL'));
        return ref;    
    }
    
    public ContactAddressEditRedirectController(ApexPages.StandardSetController standardController){}
}