/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ViewReportController
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Redirects from a given report developername to the report id.  Used in custom links and buttons
 * to avoid hard coding the report id
 * Created Date : 01/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/26/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
public class ViewReportController {
 
    // Controller for ViewReport.page,
    // which redirects the user to a Salesforce Report
    // whose name is passed in as a Query String parameter
 
    // We expect to be handed 1-2 parameters:
    // r: the DEVELOPER name of the Report you want to view
    // ns: a salesforce namespace prefix (optional)
    public PageReference redirect() {
        // Get all page parameters
        Map<String,String> params = ApexPages.currentPage().getParameters();
 
        String ns = params.get('ns'); // NamespacePrefix
        String dn = params.get('dn'); // DeveloperName
 
        List<Report> reports;
 
        // If a Namespace is provided,
        // then find the report with the specified DeveloperName
        // in the provided Namespace
        // (otherwise, we might find a report in the wrong namespace)
        if (ns != null) {
            reports = [select Id from Report
                  where NamespacePrefix = :ns
                  and DeveloperName = :dn limit 1];
        } else {
            reports = [select Id from Report where DeveloperName = :dn limit 1];
        }
 
        PageReference pgRef;
 
        // If we found a Report, go view it
        if (reports != null && !reports.isEmpty()) {
            pgRef = new PageReference('/' + reports[0].Id);
            // Add back in all of the parameters we were passed in,
            // MINUS the ones we already used: ns, dn
            params.remove('ns');
            params.remove('dn');
            pgRef.getParameters().putAll(params);
        } else {
            // We couldn't find the Report,
            // so send the User to the Reports tab
            pgRef = new PageReference('/'
                + Report.SObjectType.getDescribe().getKeyPrefix()
                + '/o'
            );
        }
 
        // Navigate to the page we've decided on
        pgRef.setRedirect(true);
        return pgRef;
 
    }
}