/*
 * Class        : CustomSearchInterface
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 14, 2013
 * Objective    : Any Visualforce page that wants to use the CustomSearch component will need to have its Controller or extension implement this Interface
*/
public interface CustomSearchInterface {
	PageReference doSearch(String filterStr);
}