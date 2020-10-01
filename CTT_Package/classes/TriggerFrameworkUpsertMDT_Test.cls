@isTest
public class TriggerFrameworkUpsertMDT_Test {
 
     @isTest
     public static void testMethod2() 
    {
        String profileID = UserInfo.getProfileId();
        

	    List<TriggerFrameworkConfig__mdt> tgrFrmwrkConfigInsertList = new List<TriggerFrameworkConfig__mdt>();
        TriggerFrameworkConfig__mdt tgrFrmwrkConfig = new TriggerFrameworkConfig__mdt();
        tgrFrmwrkConfig.MasterLabel = 'AIPP_Profile';
        tgrFrmwrkConfigInsertList.add(tgrFrmwrkConfig);
        TriggerFrameworkConfig__mdt tgrFrmwrkConfig1 = new TriggerFrameworkConfig__mdt();
        tgrFrmwrkConfig1.MasterLabel = 'Patient_Services_Nurse';
        tgrFrmwrkConfigInsertList.add(tgrFrmwrkConfig1);
        
		String jobID = TriggerFrameworkUpsertMDT.disableConfig(tgrFrmwrkConfigInsertList);
        
        List<TriggerFrameworkProfileConfig__mdt> tgrFrmwrkProfileConfigInsertList = new List<TriggerFrameworkProfileConfig__mdt>();

        TriggerFrameworkProfileConfig__mdt tgrFrmwrkProfileConfig = new TriggerFrameworkProfileConfig__mdt();
        tgrFrmwrkProfileConfig.Config__c  = tgrFrmwrkConfig.id;
		tgrFrmwrkProfileConfig.DeveloperName ='AIPP_Profile#INTIENT';
        tgrFrmwrkProfileConfigInsertList.add(tgrFrmwrkProfileConfig);
        TriggerFrameworkProfileConfig__mdt tgrFrmwrkProfileConfig1 = new TriggerFrameworkProfileConfig__mdt();
        tgrFrmwrkProfileConfig1.Config__c  = tgrFrmwrkConfig1.id;
        tgrFrmwrkProfileConfig1.DeveloperName ='Patient_Services_Nurse#INTIENT';
        tgrFrmwrkProfileConfigInsertList.add(tgrFrmwrkProfileConfig1);
        
        String jobID1 = TriggerFrameworkUpsertMDT.upsertProfileConfig(tgrFrmwrkProfileConfigInsertList);
        String jobID2 = TriggerFrameworkUpsertMDT.disableProfileConfig(tgrFrmwrkProfileConfigInsertList);
	
          
    }
}