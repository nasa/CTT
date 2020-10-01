/**
 * Case Trigger Handler Class
 *
 * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
 * @since   2020-03-29
 */
public without sharing class CaseTriggerHandler {
    private static List<String> dayPostfixes = new List<String>{'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th' };
    public static void onBeforeInsert(List<Case> newList)
    {
        copyTeamfromParentToChild(newList);
        FleshOutOutreaches(newList);
    }
    public static void onAfterInsert(Map<Id, Case> newCases) {
        /* Changed method name from syncCongregateSetting to syncHighRiskFieldsToContact 4/16/2020 Alexandria Sanborn*/
        syncHighRiskFieldsToContact(null, newCases);
    }
    public static void onBeforeUpdate(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        updateTeam(oldCases, newCases);
    }
    public static void onAfterUpdate(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        /* Changed method name from syncCongregateSetting to syncHighRiskFieldsToContact 4/16/2020 Alexandria Sanborn*/
        syncHighRiskFieldsToContact(oldCases, newCases);
    }
    public static void updateTeam(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        List<Id> ownerIds = new List<Id>();
        for (Case newCase: newCases.values()){
            ownerIds.add(newCase.OwnerId);
        }
        Map<Id, User> userMap = new Map<Id, User>();
        for (User usr: [select Id, Team__c from User where Id=:ownerIds]){
            userMap.put(usr.Id, usr);
        }
        for (Case newCase: newCases.values()){
            String newUser = String.valueOf(newCase.OwnerId);
            Case oldCase = oldCases.get(newCase.Id);
            String oldUser = String.valueOf(oldCase.OwnerId);
            User usr = userMap.get(newCase.OwnerId);
            
            
            
            if (oldCase.Team__c==Null && oldUser.startsWith('00G') && !(newUser.startsWith('00G'))){
                newCase.Team__c = usr.Team__c;
                
            }
            
        }
    }
    public static void copyTeamfromParentToChild(List<Case> newCases){
        List<Id> pCaseIds = new List<Id>();
        for (Case cs: newCases){
            pCaseIds.add(cs.ParentId);
        }
        Map<Id, Case> pCaseMap = new Map<Id, Case>();
        
        for (Case cs2:[select Team__c from Case where Id=:pCaseIds]){
            pCaseMap.put(cs2.Id, cs2);
        }
        for (Case cs: newCases){
            Case pCase = pCaseMap.get(cs.ParentId);
            
            
            if (cs.ParentId != Null){
                
                cs.Team__c = pCase.Team__c;
            }
            
        }
    }
    public static void FleshOutOutreaches(List<Case> newList)
    {
        Map<Id,RecordType> recTypeMap = new Map<Id,RecordType>( [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Case'] );
        List<Case> contactOutreachCases = new List<Case>();
        List<Case> locationOutreachCases = new List<Case>();
        for (Case c : newList)
        {
            
           // System.debug('====> recType: ' + recTypeMap.get(c.RecordTypeId).DeveloperName);
            if (recTypeMap.get(c.RecordTypeId).DeveloperName == 'Contact_Outreach')
            {
                contactOutreachCases.add(c);
            }
            else if (recTypeMap.get(c.RecordTypeId).DeveloperName == 'Location_Outreach')
            {
                locationOutreachCases.add(c);
            }
        }
        if (contactOutreachCases.size() > 0)
        {
            FleshOutContactOutreaches(contactOutreachCases);
        }
        if (locationOutreachCases.size() > 0)
        {
            FleshOutLocationOutreaches(locationOutreachCases);
        }
    }
    private class CaseAccountLink
    {
        Account a;
        Case c;
    }
    public static void FleshOutContactOutreaches(List<Case> newList)
    {
        Id personAcctRecTypeId =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'][0].Id;
        Id contactOutreachQueueId =  [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Contact_Outreach_Queue'][0].Id;
        List<Case> processCases = new List<Case>();
        List<Account> newAccounts = new List<Account>();
        List<CaseAccountLink> caseLinks = new List<CaseAccountLink>();
        for (Case c : newList)
        {
            // We need to detect that it is a "Quick Action" case
            if (c.Subject == null && c.ContactId == null && c.AccountId == null)
            {
                String dateStr;
                if (c.Last_Exposure_Date__c == null)
                    dateStr = '(Unknown Date)';
                else
                {
                    // Convert the Date to a DateTime (ugh!) so we can format as a string (double ugh!!)
                    dateStr = DateTime.newInstance(c.Last_Exposure_Date__c, Time.newInstance(12, 0, 0, 0)).format('MMM d')
                                + dayPostfixes[Math.mod(c.Last_Exposure_Date__c.day(), 10)];
                }
                c.Subject = 'Possible Contact: ' + dateStr;
                if (c.Assign_to_Queue__c) c.OwnerId = contactOutreachQueueId; // Assign to Contact Outreach Queue
                // Create new Person Account records
                Account a = new Account();
                a.RecordTypeId = personAcctRecTypeId;
                a.FirstName = c.First_Name__c;
                a.LastName = c.Last_Name__c;
                a.MiddleName = c.Middle_Name__c;
                a.PersonHomePhone = c.Home_Phone__c;
                a.PersonMobilePhone = c.Mobile_Phone__c;
                a.Phone = c.Work_Phone__c;
                a.PersonEmail = c.Email__c;
                a.Language__pc = c.Language__c;
/*                System.debug('====> My User.Id: ' + UserInfo.getUserId());
                if (UserInfo.getUserId() == (Id)'005t0000004HAH7') {
                    System.debug('====> Setting PrimaryLanguage for LC: ' + c.Language__c);
                    a.HealthCloudGA__PrimaryLanguage__pc = c.Language__c;
                }
*/
              //  a.HealthCloudGA__Gender__pc = c.Gender__c;
                a.PersonBirthdate = c.Date_Of_Birth__c;
                a.PersonMailingStreet = c.Street_Input__c;
                a.PersonMailingCity = c.City_Input__c;
                a.PersonMailingState =c.State__c;
                a.PersonMailingPostalCode = c.Zip_Code_Input__c;               
                a.Contact_is_a_Minor__pc = c.Contact_is_a_Minor__c;
                newAccounts.add(a);
                CaseAccountLink ccl = new CaseAccountLink();
                ccl.c = c;
                ccl.a = a;
                caseLinks.add(ccl);
            }
        }
        if (newAccounts.size() > 0)
        {
            insert newAccounts;
            /** @todo  Retry this using PersonContactId instead! */
            // We need the PersonIndivudalId value for the person accounts, so we have to query the account records again. :(
//            Map<Id,Account> accountsMap = new Map<Id,Account>( [SELECT Id, PersonIndividualId FROM Account WHERE Id IN :newAccounts] );
            // Map the new accounts so we can call the @future method below -- the PersonIndividualId is not set yet
            Map<Id,Account> accountsMap = new Map<Id,Account>( newAccounts );
            for (CaseAccountLink ccl : caseLinks)
            {
                ccl.c.AccountId = ccl.a.Id;
            }
            LinkPersonAccountCases(accountsMap.keySet());
        }
    }
    @future
    public static void LinkPersonAccountCases(Set<Id> personAcctIds)
    {
        List<Case> casesToUpdate = [SELECT Id, AccountId, Account.PersonContactId FROM Case WHERE AccountId IN :personAcctIds];
        for (Case c : casesToUpdate)
        {
            c.ContactId = c.Account.PersonContactId;
        }
        update casesToUpdate;
    }
    public static String FormatSubjectDate(Date theDate)
    {
        String dateStr;
        if (theDate == null)
            dateStr = '(Unknown Date)';
        else
        {
            // Convert the Date to a DateTime (ugh!) so we can format as a string (double ugh!!)
            dateStr = DateTime.newInstance(theDate, Time.newInstance(12, 0, 0, 0)).format('MMM d')
                        + dayPostfixes[Math.mod(theDate.day(), 10)];
        }
        return dateStr;        
    }
    public static void FleshOutLocationOutreaches(List<Case> newList)
    {
        System.debug('====> in FleshOutLocationOutreaches()');
        Id businessAcctRecTypeId =  [SELECT Id FROM RecordType WHERE Name = 'Business' and SObjectType = 'Account'][0].Id;
        Id locationOutreachQueueId =  [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Location_Outreach_Queue'][0].Id;
        List<Case> processCases = new List<Case>();
        List<Account> newAccounts = new List<Account>();
        List<CaseAccountLink> caseLinks = new List<CaseAccountLink>();
        for (Case c : newList)
        {
            if (c.Subject == null)
            {
                String dateStr;
                if (c.Last_Exposure_Date__c == null)
                    dateStr = '(Unknown Date)';
                else
                {
                    // Convert the Date to a DateTime (ugh!) so we can format as a string (double ugh!!)
                    dateStr = DateTime.newInstance(c.Last_Exposure_Date__c, Time.newInstance(12, 0, 0, 0)).format('MMM d')
                                + dayPostfixes[Math.mod(c.Last_Exposure_Date__c.day(), 10)];
                }
                c.Subject = 'Location Visited: ' + dateStr;
            }
            // Assign_to_Queue__c not currently exposed, but defaults to True
            if (c.Assign_to_Queue__c) c.OwnerId = locationOutreachQueueId; // Assign to Location Outreach Queue
            if (c.ContactId == null && c.AccountId == null && c.Location_Name__c != null)
            {
                // Create new Person Account records
                Account a = new Account();
                a.RecordTypeId = businessAcctRecTypeId;
                a.Name = c.Location_Name__c;
//                a.Phone = c.Phone__c;
//                a.Email__c = c.Email__c;
                newAccounts.add(a);
                CaseAccountLink ccl = new CaseAccountLink();
                ccl.c = c;
                ccl.a = a;
                caseLinks.add(ccl);
            }
        }
        if (newAccounts.size() > 0)
        {
            insert newAccounts;
            for (CaseAccountLink ccl : caseLinks)
            {
                ccl.c.AccountId = ccl.a.Id;
            }
        }
    }
    /* Changed method name from syncCongregateSetting to syncHighRiskFieldsToContact 4/16/2020 Alexandria Sanborn*/
    public static void syncHighRiskFieldsToContact(Map<Id, Case> oldCases, Map<Id, Case> newCases) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Boolean> congregateSettingMap = new Map<Id, Boolean>();
        /* Added 4/16/2020 Alexandria Sanborn*/
        //start 
        Map<Id, Boolean> healthcareWorkerMap = new Map<Id, Boolean>(); 
        //end
        for (Case c : newCases.values()) {
            if (oldCases!=null &&
                (oldCases.get(c.Id).Employed_or_Admitted_Location_Type__c != c.Employed_or_Admitted_Location_Type__c ||
                oldCases.get(c.Id).ContactId!=c.ContactId)) {
                Boolean congregateFlag = c.Employed_or_Admitted_Location_Type__c!=null ? true : false;
                congregateSettingMap.put(c.ContactId, congregateFlag);
            }
            /* Added 4/16/2020 Alexandria Sanborn*/
            //start
            if (oldCases!=null &&
                (oldCases.get(c.Id).Is_Healthcare_Worker__c != c.Is_Healthcare_Worker__c ||
                oldCases.get(c.Id).ContactId!=c.ContactId)) {
                Boolean healthcareWorkerFlag = c.Is_Healthcare_Worker__c == 'Yes' ? true : false;
                healthcareWorkerMap.put(c.ContactId, healthcareWorkerFlag);
            }
            //end
        }
        List<Contact> contactsToSync = new List<Contact>();
        system.debug(healthcareWorkerMap);
        system.debug(congregateSettingMap);
        if (congregateSettingMap.size() > 0 || healthcareWorkerMap.size() > 0) {
            for (Contact cc : [SELECT Id, Is_In_Long_Term_Care_Facility__c,Is_Health_Care_Worker__c FROM Contact WHERE Id IN :congregateSettingMap.keySet() OR Id IN :healthcareWorkerMap.keySet()]) {
                if(congregateSettingMap.containsKey(cc.Id)){
                    cc.Is_In_Long_Term_Care_Facility__c = congregateSettingMap.get(cc.Id);
                }
                /* Added 4/16/2020 Alexandria Sanborn*/
                //start
                if(healthcareWorkerMap.containsKey(cc.Id)){
                    cc.Is_Health_Care_Worker__c = healthcareWorkerMap.get(cc.Id);
                }
                //end
                contactsToSync.add(cc);
            }
        }
        if (contactsToSync.size() > 0)
            update contactsToSync;
    }

    /**
     * Object specifiers
     * 
     * These can be added or bitwise-OR'ed together to specify more than one object:
     * 
     * objSpec_UnderlyingIllness + objSpec_SomeOtherObject
     * objSpec_UnderlyingIllness | objSpec_SomeOtherObject
     */
    public static Integer objSpec_UnderlyingIllness = 1 << 0;
//    public static Integer objSpec_SomeOtherObject = 1 << 1;
//    public static Integer objSpec_SomeOtherObject = 1 << 2;
//    public static Integer objSpec_SomeOtherObject = 1 << 3;
//    public static Integer objSpec_SomeOtherObject = 1 << 4;
    public static Integer objSpec_ALL = objSpec_UnderlyingIllness; // | objSpec_SomeOtherObject | objSpec_SomeOtherObject

    /**
     * Update export fields from related lists
     * 
     * We have a couple ways we could implement this:
     * 
     * 1) Build separate methods for each of the related objects and call each one separately depending on which related object
     *    is updated. This would work on given that users will be editing one set of related objects at a time. However it means
     *    having separate code for each one. It also doesn't work well if we need to update all related fields at the same time
     *    (which may not ever be needed).
     * 
     * 2) We could build one master method that updates all export fields from all related lists in one go. That would ensure we
     *    have only one query (assuming we query related data through the child object reference field), would provide a minimal
     *    amount of code to maintain, and would be most efficient if we need to update all fields at the same time (which we
     *    aren't sure would ever be needed). However it means we are querying lots of related objects each time we make just one
     *    update.
     * 
     * 3) Build one master method, but be able to specify which related objets need to be loaded. This would be the most efficient
     *    and flexible, and would only require one set of code to maintain, but the code itself could be a lot more complex to
     *    add/remove/execute code just for specific objects.
     * 
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    @future
    public static void UpdateExportFields(Set<Id> caseIds, Integer objectSpecifier)
    {
        // Start the Case query
        String soql = 'SELECT Id ';

        // SOQL sub-query for Underlying_Illness__c related records
        if ((objectSpecifier & objSpec_UnderlyingIllness) != 0) {
            soql += ', (SELECT Underlying_Illness_Specify__c, Underlying_Illness_Specify_Other__c, Underlying_Illness_Description__c, Pregnancy_Detail__c ';
            soql += ' FROM Underlying_Illnesses__r ORDER BY Name)';
        }

        // End the Case query
        soql += ' FROM Case WHERE Id IN :caseIds';

        // Execute the query
        List<Case> cases = Database.query(soql);

        List<Case> updateCases = new List<Case>();

        // Go through each case and build up 'export' fields from the related children records
        for (Case c : cases)
        {
            Case newC = new Case( Id = c.Id );

            // Update export fields for Underlying_Illness__c related records
            if ((objectSpecifier & objSpec_UnderlyingIllness) != 0) {
                newC.IX_Underlying_Illness_Specify__c = ImplodeValues(c.Underlying_Illnesses__r, 'Underlying_Illness_Specify__c');
                newC.IX_Underlying_Illness_Specify_Other__c = ImplodeValues(c.Underlying_Illnesses__r, 'Underlying_Illness_Specify_Other__c');
                newC.IX_Underlying_Illness_Description__c = ImplodeValues(c.Underlying_Illnesses__r, 'Underlying_Illness_Description__c');
                newC.IX_Pregnancy_Detail__c = ImplodeValues(c.Underlying_Illnesses__r, 'Pregnancy_Detail__c');
            }

            updateCases.add(newC);
        }

        update updateCases;
    }

    /**
     * Select and join together all values from a set of records
     * 
     * recs -- a list of sObjects -- can be any object, standard or custom
     * 
     * origField -- this is the field to get from the list of records. This can be a standard field (i.e. 'LastName' from Contacts),
     *              a custom field (i.e. 'Close_Reason__c' for Case), or a field reference (i.e. 'Account.RecordType.Name' for Contacts)
     * 
     * Returns a string value of semi-colon concatenated values from each of the records. Null values will be returned as '', so
     * two records with null values, followed by one record with a value will look like ';;Value3'
     * 
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public static String ImplodeValues(List<sObject> recs, String origField)
    {
        if (recs.size() == 0)
            return null;
        
        List<String> parts = new List<String>();

        for (sObject rec : recs)
        {
            String field = origField;

            // Handle field references like <Contact>.'Account.RecordType.Name'
            if (field.contains('.'))
            {
                // Split the field reference list up on '.'
                List<String> fieldParts = field.split('\\.');

                // Iterate through all the base reference objects (i.e. 'Account.RecordType' in example from above)
                for (Integer i = 0; i < fieldParts.size()-1; i++)
                {
                    field = fieldParts[i];
                    
                    // Assign rec to 'parent' object
                    rec = rec.getsObject(field);
                }

                // Finally set field to the final (field) part of the referenced field (i.e. 'Name' in example above)
                field = fieldParts[fieldParts.size()-1]; 
            }

            // Get the field from the record
            parts.add((String)(rec.get(field)));
        }

        // Join all resulting parts together with a semi-colon
        return String.join(parts, ';');
    }
}