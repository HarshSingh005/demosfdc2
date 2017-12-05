trigger updateRoles on STOWD__Status_Ownership_Duration__c (before insert) { 

    if(TriggerState.isActive('updateRoles')) {
        list<string> uNames = new list<string>(); 
    
        for (STOWD__Status_Ownership_Duration__c d : trigger.new) 
            uNames.add(d.STOWD__Owner__c); 
    
        map<string, string> namesToRoles = new map<string, string>(); 
    
        for (user u : [select name, UserRole.name from user where name in :uNames]) 
            namesToRoles.put(u.name, u.UserRole.name); 
        
        for (group u : [select name from group where name in :uNames]) 
            namesToRoles.put(u.name, u.name);
    
    
        for (STOWD__Status_Ownership_Duration__c d : trigger.new) 
            if (namesToRoles.containsKey(d.STOWD__Owner__c)) 
                d.Owner_Role__c = namesToRoles.get(d.STOWD__Owner__c); 
    }
}