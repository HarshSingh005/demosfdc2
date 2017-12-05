//Created by John Hecker 10.5.2016 to enable 
//Opportunity redirect when only 1 Opportunity
//Record Type is enabled for a User

public class GetEnabledRecordTypeUtility {
// Returns a List of the IDs of all RecordTypes
// available to the running user for a given SOBject type
public static List<String> GetAvailableRecordTypeIDsForSObject(
    Schema.SObjectType objType
) {
    List<ID> rtids = new List<ID>();
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    // If there are 2 or more RecordTypes...
    if (infos.size() > 1) {
        for (RecordTypeInfo i : infos) {
           if (i.isAvailable() 
           // Ignore the Master Record Type, whose Id always ends with 'AAA'.
           // We check the Id because Name can change depending on the user's language.
            && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
            	rtids.add(i.getRecordTypeId());
        }
    } 
    // Otherwise there's just the Master record type,
    // so add it in, since it MUST always be available
    else rtids.add(infos[0].getRecordTypeId());
    		return rtids;
}
}