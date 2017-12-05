/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ViewReportControllerTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test for ViewReportController redirect page
 * Created Date : 01/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/26/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
@isTest(SeeAllData=true)
public class ViewReportControllerTest {
 
    // We MUST be able to see real Reports for this to work,
    // because we can't insert test Reports.
 
    public static testmethod void redirectTest() {
        // For this example, we assume that there is
        // at least one Report in our org WITH a namespace
 
        // Get a report to work with
        List<Report> reports = [
            select Id, DeveloperName, NamespacePrefix
            from Report
            where NamespacePrefix != null
            limit 1
        ];
 
        // Assuming that we have reports...
        if (!reports.isEmpty()) {
            // Get the first one in our list
            Report r = reports[0];
 
            //
            // CASE 1: Passing in both namespace, developername,
            // and a parameter value
            //
 
            // Load up our Visualforce Page
            PageReference p = System.Page.ViewReport;
            p.getParameters().put('ns',r.NamespacePrefix);
            p.getParameters().put('dn',r.DeveloperName);
            p.getParameters().put('pv0','llamas');
            p.getParameters().put('pv2','alpacas');
            Test.setCurrentPage(p);
 
            // Load up our Controller
            ViewReportController ctl = new ViewReportController();
 
            // Manually call the redirect() action,
            // and store the page that we are returned
            PageReference ret = ctl.redirect();
 
            // We should be sent to the View page for our Report
            System.assert(ret.getURL().contains('/'+r.Id));
            // Also, make sure that our Filter Criterion values
            // got passed along
            System.assert(ret.getURL().contains('pv0=llamas'));
            System.assert(ret.getURL().contains('pv2=alpacas'));
 
            //
            // CASE 2: Passing in both just developername
            //
 
            // Load up our Visualforce Page
            p = System.Page.ViewReport;
            p.getParameters().put('dn',r.DeveloperName);
            Test.setCurrentPage(p);
 
            // Load up our Controller
            ctl = new ViewReportController();
 
            // Manually call the redirect() action,
            // and store the page that we are returned
            ret = ctl.redirect();
 
            // We should be sent to the View page for our Report
            System.assert(ret.getURL().contains('/'+r.Id));
 
            //
            // CASE 3: Passing in a nonexistent Report name
            //
 
            // Load up our Visualforce Page
            p = System.Page.ViewReport;
            p.getParameters().put('dn','BlahBLahBlahBlahBlahBlah');
            Test.setCurrentPage(p);
 
            // Load up our Controller
            ctl = new ViewReportController();
 
            // Manually call the redirect() action,
            // and store the page that we are returned
            ret = ctl.redirect();
 
            // We should be sent to the Reports tab
            System.assert(ret.getURL().contains(
                '/'+Report.SObjectType.getDescribe().getKeyPrefix()+'/o'
            ));
 
        }
 
    }
}