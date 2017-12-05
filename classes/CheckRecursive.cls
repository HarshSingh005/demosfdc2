/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CheckRecursive
 * Created By   : Shailendra Singh (Appirio)
 * Purpose      : In order to avoid the situation of recursive call, make sure your trigger is getting executed only one time. To do so, 
 				  you can create a class with a static boolean variable with default value true.
				  In the trigger, before executing your code keep a check that the variable is true or not.
				  Once you check make the variable false.
 * Created Date : 29/03/2016
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 **********************************************************************************************************/
public class CheckRecursive {
  
  @TestVisible 
  private static boolean run = true;
  private static boolean runAccount = true;
  private static boolean runContact = true;
  public static boolean runContactOnce = false;
  private static boolean runUpdateOppOwnerOnce = true;
  private static integer runClawback = 0;
  private static Integer counter = 0;
  @TestVisible private static boolean runOpportunity = true;
  private static boolean runOppNameUpdateMethod = true;
  public static boolean runOnce() {
      if (run) {
          run = false;
          return true;
      } else {
          return run;
      }
  }
  
  public static boolean runOppNameUpdate() {
      if (runOppNameUpdateMethod) {
          runOppNameUpdateMethod = false;
          return true;
      } else {
          return runOppNameUpdateMethod;
      }
  }
  
    public static boolean ifClawbackRunningRecursively() {
      if(runClawback < 6){
          runClawback++;
          return true;
      }else{
          return false;
      }
  }

  public static boolean runAccountOnce() {
      if(runAccount){
          runAccount = false;
          return true;
      }else{
          return runAccount;
      }
  }

  public static boolean runContactOnce() {
      if(runContact){
          runContact = false;
          return true;
      }else{
          return runContact;
      }
  }

  public static boolean runOpportunityOnce() {
      if(runOpportunity){
          runOpportunity = false;
          return true;
      }else{
          return runOpportunity;
      }
  }
  
  public static boolean runUpdateOppOwnerOnce() {
      if(runUpdateOppOwnerOnce){
          runUpdateOppOwnerOnce = false;
          return true;
      }else{
          return runUpdateOppOwnerOnce;
      }
  }
  
  public static Integer checkCounter(){
    	return counter++;   	
    }
}