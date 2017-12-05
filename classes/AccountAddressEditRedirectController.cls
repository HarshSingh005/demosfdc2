/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountAddressEditRedirectController 
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Redirects to new Account Manage Address page from list button
 * Created Date : 04/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 04/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class AccountAddressEditRedirectController 
{
    public PageReference Redirect()
    {
        PageReference ref = Page.Account_ManageAddresses;
        ref.getParameters().put('id',Apexpages.currentPage().getParameters().get('id'));
        ref.getParameters().put('retURL',Apexpages.currentPage().getParameters().get('retURL'));
        return ref;    
    }
    
    public AccountAddressEditRedirectController(ApexPages.StandardSetController standardController){}
}