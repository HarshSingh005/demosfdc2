public class OppPredirectController {
    
    public OppPredirectController(ApexPages.standardController std){
    }

    public PageReference predirectToOppRedirect(){
        PageReference result_page = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo');
        String currentID = ApexPages.currentPage().getParameters().get('RecordType');
        List<String> availableOppTypes = 
            GetEnabledRecordTypeUtility.GetAvailableRecordTypeIDsForSObject(Opportunity.SObjectType);
        If(currentID != null && currentID.length() > 1){
            PageReference result_page1 = new PageReference(
                '/apex/rC_Giving__Opportunity_RedirectRecordType?retURL=%2F006%2Fo&RecordType='+ currentID +'&ent=Opportunity&save_new=1&sfdc.override=1');
            return result_page1;
        }
        else if (availableOppTypes.size() == 1){
            String rtid = availableOppTypes[0];
            PageReference result_page2 = new PageReference(
                '/apex/rC_Giving__Opportunity_RedirectRecordType?retURL=%2F006%2Fo&RecordType='+ rtid +'&ent=Opportunity&save_new=1&sfdc.override=1');
            return result_page2;
        }else{
            return result_page;
        }
        
    }
}