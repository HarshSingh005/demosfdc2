/***********************************************************************************************************
 * Appirio, Inc
 * Name         : LockedChildrenViewerController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Controller class of Locked Children Viewer console page
 * 				: The page displays only Children in the Website Shopping Cart Reserve
 * Created Date : 05/06/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/06/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
public class LockedChildrenViewerController 
{
	public class ChildWrapper
    {
        public Contact Child{get;set;}
        public boolean Selected{get;set;}
    }
    
    public List<ChildWrapper> Children{get;set;}
    
    public LockedChildrenViewerController()
    {
        this.GetLockedChildrenList();
    }
    
    //populates the list of locked children in the UI
    public void GetLockedChildrenList()
    {
        this.Children = new List<ChildWrapper>();
        
        List<Contact> kids = [select id,
                             National_Office_Number__c,
                             Child_Number__c,
                             Name,
                             Short_Name__c,
                             rC_Bios__Gender__c,
                             rC_Bios__Age__c,
                             Birthdate,
                             National_Office__r.NO_Country__c,
                             rC_Sponsorship__Reserve__c
                             from Contact
                             where RecordType.Name = 'Participant'
                             and rC_Sponsorship__Reserve__r.Name = 'Website Shopping Cart Reserve'
                             order by name asc];
        
        for(Contact kid : kids)
        {
            ChildWrapper wrap = new ChildWrapper();
            wrap.Child = kid;
            wrap.Selected = false;
            this.Children.add(wrap);
        }
    }
    
    //unlock the selected children
    public void UnlockChildren()
    {
        try
        {
            //get a list of contacts to update
            List<Contact> kidsToUpdate = new List<Contact>();
            for(ChildWrapper wrap : this.Children)   
            {
                if(wrap.Selected)
                {
                    wrap.Child.rC_Sponsorship__Reserve__c = null;
                    kidsToUpdate.add(wrap.Child);
                }
            }
            
            if(kidsToUpdate.size() > 0)
            {
                update kidsToUpdate;
            	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Selected Children have been unlocked.'));
            }
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No Children selected.'));
                
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
        this.getLockedChildrenList();
    }
    
}