public class MavenStagingTableTriggerHandler {        
    /** @todo  Consolidate some of this subject-creation code with that in CaseTriggerHandler into a common library */
    private static List<String> dayPostfixes = new List<String>{'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th' };
    public static List<String> stringsToParse = new List<String>{'race_string__c','occupation__c','other_occupation__c', 
            'clinical_complications__c', 'other_clinical_complications__c', 
//            'underlying_illness__c', 'Underlying_Illness_Specify_String__c', 'Underlying_Illness_Specify_Other__c','pregnancy_detail__c',
            'case_hospitalized__c', 'hospital_name__c', 'other_hospital_name__c','icu_admission__c',
            'date_discharged_string__c','date_hospitalized_string__c',
            'employed_or_admitted_care_location__c','Employed_or_Admitted_Loc_Type_String__c','employed_or_admitted_other_detail__c'};
    public static List<Underlying_Illness__c> relatedRecs_UnderlyingIllnesses = new List<Underlying_Illness__c>();
    public static String getFirstFieldValue(String str){         
            if(str == null){
                return null;
            } else {
                List<String> parts = str.split('[,;]\\s*');
                if(parts.size() == 0){
                    return null;
                } else {
                    return parts[0];
                }
            }
        }   
    public static void onBeforeInsert(List<Maven_Staging_Table__c> trigNew){
        /** @todo  Make this better -- get rec type ids from sObject describes, do one query for the Queue Ids */
        Id positiveOutreachRecTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Positive_Outreach' and SObjectType = 'Case'][0].Id;
        Id contactOutreachRecTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Contact_Outreach' and SObjectType = 'Case'][0].Id;
        Id positiveOutreachQueueId =  [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Positive_Outreach_Queue'][0].Id;
        Id contactOutreachQueueId =  [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Contact_Outreach_Queue'][0].Id;
        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<Case>();
        for(Maven_Staging_Table__c mST : trigNew){
            Account newAccount = new Account();
            Case newCase = new Case();
            for(String fieldName : stringsToParse){
                mST.put(fieldName,getFirstFieldValue((String)(mST.get(fieldName))));
            }
            //Dummy Account reference
            Account accountReference = new Account();
            accountReference.Maven_Contact_Id__c = mST.Maven_Contact_Id__c;
            newCase.Account = accountReference; 
            //Account fields
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            newAccount.RecordTypeId = personAccountRecordTypeId;
            newAccount.FirstName = mST.First_Name__c;
            newAccount.LastName = mST.Last_Name__c;
            newAccount.MiddleName = mST.Middle_Name__c;
            newAccount.Language__pc = mST.Language__c;
            newAccount.Maven_Contact_Id__c = mST.Maven_Contact_Id__c;
            newAccount.PersonBirthdate = mST.Birthdate__c;
            newAccount.PersonHomePhone = mST.Home_Phone__c;
            newAccount.PersonMobilePhone = mST.Cell_Phone__c;
            newAccount.Phone = mST.Work_Phone__c;
            newAccount.PersonEmail = mST.Email__c;
            newAccount.PersonMailingStreet = mST.Street_Address__c;
            newAccount.PersonMailingCity = mST.City__c;
            newAccount.County__c = mST.County__c;
            newAccount.PersonMailingState = mST.State__c;        
            newAccount.Next_of_Kin_Notes__c = mST.Next_of_Kin_Notes__c;
            newAccount.Next_of_Kin_Phone__c = mST.Next_of_Kin_Phone__c;
            newAccount.Race__c = mST.Race_String__c;
            newAccount.Hispanic__c = mST.Hispanic__c;
          //  newAccount.HealthCloudGA__Gender__pc = mST.Gender__c;
            if (!String.isEmpty(mST.Occupation__c)) newAccount.Occupation_Value__r = new Occupation__c( Reference_Code__c = mST.Occupation__c );
            newAccount.Other_Occupation__c = mST.Other_Occupation__c;
            newAccount.Employer_Name__c = mST.Employer_Name__c;
            newAccount.Employer_Phone__c = mST.Employer_Phone__c;
            newAccount.Employer_Address__c = mST.Employer_Address__c;
            newAccount.Employer_City__c = mST.Employer_City__c;
            newAccount.Employer_State__c = mST.Employer_State__c;
            newAccount.Healthcare_Worker__c = mST.Healthcare_Worker__c;
            if(mST.Healthcare_Worker__c != null){newAccount.Is_Health_Care_Worker__pc = (mST.Healthcare_Worker__c.toLowerCase() == 'yes' ? TRUE : FALSE);}
            newAccount.Hospital_Reference_Code__c = mST.Hospital_Reference_Code__c;
            newAccount.Other_Death_Location__c= mST.Location_of_Death_Detail__c;    
            newAccount.Location_of_Death__c = mST.Location_of_Death__c;
            //
            // Case Type and supporting values
            //
            Id recTypeId, ownerId;
            String subject, dateStr;
            if (mST.Disease_Status__c.toLowerCase() == 'contact')
            {
                // Make it a Contact Outreach record type
                dateStr = CaseTriggerHandler.FormatSubjectDate(mST.Last_Exposure_Date__c);
                recTypeId = contactOutreachRecTypeId;
                subject = 'Possible Contact: ' + dateStr;
                ownerId = contactOutreachQueueId;
                newCase.Origin = 'Phone';
            }
            else // if (mST.Disease_Status__c.toLowerCase() == 'confirmed')
            {
                // Otherwise, we assume it's a Positive Outreach -- this will be the default, so any new Disease_Status__c value will map to this unless the code is changed!
                dateStr = CaseTriggerHandler.FormatSubjectDate(mST.Test_Taken_Date__c);
                recTypeId = positiveOutreachRecTypeId;
                subject = 'Tested Positive: ' + dateStr;
                ownerId = positiveOutreachQueueId;
                newCase.Origin = 'Test Result';
            }
            //Case fields
            newCase.RecordTypeId = recTypeId;
            newCase.Subject = subject;
            newCase.ownerId = ownerId;
            newCase.Maven_Contact_Id__c = newAccount.Maven_Contact_Id__c;
            newCase.Last_Exposure_Date__c = mST.Last_Exposure_Date__c;
            newCase.First_Monitoring_Date__c = mST.First_Monitoring_Date__c;
            newCase.Last_Monitoring_Date__c = mST.Last_Monitoring_Date__c;
            newCase.Disease_Status__c = mST.Disease_Status__c;
            newCase.Investigator_Name__c = mST.Investigator_Name__c;
            newCase.Investigator_Phone__c = mST.Investigator_Phone__c;
            newCase.Investigation_Status__c = mST.Investigation_Status__c;
            newCase.Investigation_Status_Other__c = mST.Investigation_Status_Other__c;
            newCase.Test_Taken_Date__c = mST.Test_Taken_Date__c;
            newCase.Test_Status__c = mST.Test_Result_Status__c;
            if (mST.Ordering_Facility_Reference_Code__c != null)
                newCase.Ordering_Facility__r = new Account( Ordering_Facility_Reference_Code__c = mST.Ordering_Facility_Reference_Code__c );
            newCase.Ordering_Facility_Description__c = mST.Ordering_Facility_Description__c;
            newCase.Ordering_Provider_Name__c = mST.Ordering_Provider_Name__c;
            newCase.Ordering_Provider_Address__c = mST.Ordering_Provider_Address__c;
            newCase.Ordering_Provider_City__c = mST.Ordering_Provider_City__c;
            newCase.Ordering_Provider_State__c = mST.Ordering_Provider_State__c;
            newCase.Ordering_Provider_Phone__c = mST.Ordering_Provider_Phone__c;
            newCase.Symptoms__c = mST.Symptoms__c;
            newCase.Symptom_Onset_Date__c = mST.Symptom_Onset_Date__c;
            newCase.Symptom_Resolution_Date__c = mST.Symptom_Resolution_Date__c;
            newCase.Abdominal_Pain__c = mST.Abdominal_Pain__c;
            newCase.Chills__c = mST.Chills__c;
            newCase.Cough__c = mST.Cough__c;
            newCase.Cough_Onset_Date__c = mST.Cough_Onset_Date__c;
            newCase.Diarrhea__c = mST.Diarrhea__c;
            newCase.Difficulty_Breathing__c = mST.Difficulty_Breathing__c;
            newCase.Fever__c = mST.Fever__c;
            newCase.Fever_Onset_Date__c = mST.Fever_Onset_Date__c;
            newCase.Fever_Temperature__c = mST.Fever_Temperature__c;
            newCase.Fever_Temperature_Unit__c = mST.Fever_Temperature_Unit__c;
            newCase.Fever_Duration__c = mST.Fever_Duration__c;
            newCase.Headache__c = mST.Headache__c;
            newCase.Muscle_Aches_Pains__c = mST.Muscle_Aches_Pains__c;
            newCase.Sore_Throat__c = mST.Sore_Throat__c;
            newCase.Vomiting__c = mST.Vomiting__c;
            newCase.Other_Symptoms__c = mST.Other_Symptoms__c;
            newCase.Clinical_Complications__c = mST.Clinical_Complications__c;
            newCase.Other_Clinical_Complications__c = mST.Other_Clinical_Complications__c;
//            newCase.Underlying_Illness__c = mST.Underlying_Illness__c;
//            newCase.Underlying_Illness_Specify__c = mST.Underlying_Illness_Specify_String__c;
//            //newCase.Underlying_Illness_Description__c = mST.Underlying_Illness_Description__c;
//            newCase.Pregnancy_Detail__c = mST.Pregnancy_Detail__c;
            newCase.Case_Hospitalized__c = mST.Case_Hospitalized__c;
            if (mST.Hospital_Name__c != null) newCase.Hospital_Name__r = new Account( Hospital_Reference_Code__c = mST.Hospital_Name__c );
            newCase.Other_Hospital_Name__c = mST.Other_Hospital_Name__c;
            if (!String.isEmpty(mST.date_hospitalized_string__c)){newCase.Date_Hospitalized__c = date.parse(mST.date_hospitalized_string__c);}
            if (!String.isEmpty(mST.date_discharged_string__c)){newCase.Date_Discharged__c = date.parse(mST.date_discharged_string__c);}
            newCase.ICU_Admission__c = mST.ICU_Admission__c;
            newCase.ICU_Admission_Date__c = mST.ICU_Admission_Date__c;
            newCase.ICU_Discharge_Date__c = mST.ICU_Discharge_Date__c;
            newCase.Outcome__c = mST.Outcome__c;
            newCase.Date_of_Death__c = mST.Date_of_Death__c;
            newCase.Employed_or_Admitted_Healthcare__c = mST.Employed_or_Admitted_Healthcare__c;
            newCase.Employed_or_Admitted_Care_Location__c = mST.Employed_or_Admitted_Care_Location__c;
            newCase.Employed_or_Admitted_Location_Type__c = mST.Employed_or_Admitted_Loc_Type_String__c;
            newCase.Employed_or_Admitted_Other_Detail__c = mST.Employed_or_Admitted_Other_Detail__c;
            //add new account and case to sObject list
            acctList.add(newAccount);
            caseList.add(newCase);
            BuildUnderlyingIllnesses(mst);
        }        
        insert acctList;
        insert caseList;
        InsertRelatedRecords();
        Map<Id,Account> acctMap = new Map<Id,Account>(acctList);
        CaseTriggerHandler.LinkPersonAccountCases(acctMap.keySet());
    }
    /**
     * Inserts all related records (if any)
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public static void InsertRelatedRecords()
    {
        if (relatedRecs_UnderlyingIllnesses.size() > 0)
            insert relatedRecs_UnderlyingIllnesses;
    }
    /**
     * Class to build out related Underlying Illness records for a Case
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public static void BuildUnderlyingIllnesses(Maven_Staging_Table__c mst)
    {
//        System.debug('====> MId: ' + mst.Maven_Contact_Id__c);
        Integer recCount = GetRelatedRecCount(mst.Underlying_Illness_Specify_String__c);
        if (recCount == 0)
            return;
        List<Underlying_Illness__c> uis = new List<Underlying_Illness__c>();
        for (Integer i = 0; i < recCount; i++)
        {
            // Include a reference to the Case via Case.Mavent_Contact_Id__c external Id -- this will link the record on insert
            uis.add(new Underlying_Illness__c( Case__r = new Case( Maven_Contact_Id__c = mst.Maven_Contact_Id__c ) ));
        }
        PopulateChildrenRecords(uis, mst.Underlying_Illness_Specify_String__c, 'Underlying_Illness_Specify__c');
        PopulateChildrenRecords(uis, mst.Underlying_Illness_Specify_Other__c, 'Underlying_Illness_Specify_Other__c');
        PopulateChildrenRecords(uis, mst.Underlying_Illness_Description__c, 'Underlying_Illness_Description__c');
        PopulateChildrenRecords(uis, mst.Pregnancy_Detail__c, 'Pregnancy_Detail__c');
        if (uis.size() > 0)
        {
//            System.debug('====> uis: ' + JSON.serialize(uis));
            relatedRecs_UnderlyingIllnesses.addAll(uis);
        }
    }
    /**
     * 
     * 
     * NOTE: This should only be called on a field that is required to be set for the child record.
     *       Otherwise, if called with '' -- we won't be able to tell if this is one record with a blank value for this field
     *       or no records/responses at all.
     */
    public static Integer GetRelatedRecCount(String compoundStr)
    {
//        System.debug('====> GetRelatedRecCount - str: "' + compoundStr + '"');
        if (compoundStr == null || compoundStr == '')
        {
//            System.debug('====> GetRelatedRecCount - 1: 0');
            return 0;
        }
        // If the compoundStr is some variation of just semicolons -- ';;;' -- just return the length + 1
        // This gets around the issue of str.split(';') returning an empty list if there are no strings between the semicolons
        // NOTE: UPDATE: using str.split(';', -1) will supposedly return the full list of empty values
//        if (compoundStr.countMatches(';') == compoundStr.length())
//        {
//            System.debug('====> GetRelatedRecCount - 2: ' + (compoundStr.length() + 1));
//            return compoundStr.length() + 1;
//        }
        List<String> parts = compoundStr.split(';\\s*', -1);
//        System.debug('====> GetRelatedRecCount - 3: ' + parts.size());
        return parts.size();
    }
    /**
     * Custom MST_Exception exception
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public class MST_Exception extends Exception {}
    /**
     * Generic method for Populating a value on "compound value" children records
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-26
     */
    public static void PopulateChildrenRecords(List<sObject> recs, String compoundStr, String field)
    {
//        System.debug('====> PCR - field "' + field + '", str: "' + compoundStr + '"');
        if (compoundStr == null || compoundStr == '') // || compoundStr.countMatches(';') == compoundStr.length())
            return; // No values to populate
        List<String> parts = compoundStr.split(';\\s*', -1);
        if (parts.size() != recs.size())
        {
            throw new MST_Exception('Compound value count mismatch -- found ' + parts.size() + ' parts, expected ' + recs.size() + ' parts for target field "' + field + '" - value: "' + compoundStr + '"');
        }
        for (Integer i = 0; i < parts.size(); i++)
        {
//            System.debug('====> Assigning ' + field + ' => "' + parts[i] + '"');
            recs[i].put(field, parts[i]);
        }
    }
}