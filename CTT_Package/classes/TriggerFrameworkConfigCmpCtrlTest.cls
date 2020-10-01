@isTest
global with sharing class TriggerFrameworkConfigCmpCtrlTest { 
@isTest  
    public static void testMethod1() 
    {
        String profileID = UserInfo.getProfileId();
     
        TriggerFrameworkConfigCmpCtrl.getCofigs(UserInfo.getProfileId());
        TriggerFrameworkConfigCmpCtrl.getConfigData(UserInfo.getProfileId());
        Map<String, Object> returnMap =	TriggerFrameworkConfigCmpCtrl.toggleProfileAcess(profileID,false);
        returnMap = TriggerFrameworkConfigCmpCtrl.toggleProfileAcess(profileID,true);

		Map<String, Object> returnMap1 = TriggerFrameworkConfigCmpCtrl.classOrTrigger('triggerName',TriggerFrameworkConstants.Triggr);
        Map<String, Object> returnMap2 = TriggerFrameworkConfigCmpCtrl.classOrTrigger('triggerName1',TriggerFrameworkConstants.HELPER);

	    List<TriggerFrameworkConfig__mdt> tgrFrmwrkConfigInsertList = new List<TriggerFrameworkConfig__mdt>();
        TriggerFrameworkConfig__mdt tgrFrmwrkConfig = new TriggerFrameworkConfig__mdt();
        tgrFrmwrkConfig.MasterLabel = 'AIPP_Profile';
        tgrFrmwrkConfigInsertList.add(tgrFrmwrkConfig);
        TriggerFrameworkConfig__mdt tgrFrmwrkConfig1 = new TriggerFrameworkConfig__mdt();
        tgrFrmwrkConfig1.MasterLabel = 'Patient_Services_Nurse';
        tgrFrmwrkConfigInsertList.add(tgrFrmwrkConfig1);
        Map<String, Object> returnMap3 = TriggerFrameworkConfigCmpCtrl.saveProfileConfigData(tgrFrmwrkConfigInsertList,profileID);
        
        TriggerFrameworkConfig__mdt tgrFrmwrkConfig2 = new TriggerFrameworkConfig__mdt();
        tgrFrmwrkConfig2.MasterLabel = 'COPD_Nurse';
        String str = JSON.serialize(tgrFrmwrkConfig2);
        TriggerFrameworkConfigCmpCtrl.createConfig(str,profileID);
        try{
		TriggerFrameworkConfigCmpCtrl.createConfig('kluiuyu','kjsdfjg');
        }catch(exception e){ e.getMessage();}
		TriggerFrameworkConfigCmpCtrl.deleteConfigData(tgrFrmwrkConfig2.Id);
        
        TriggerFrameworkConfigCmpCtrl.getConfigData(TriggerFrameworkConstants.NULLVALUE);
         Map<String, Object> returnMap4 = TriggerFrameworkConfigCmpCtrl.saveProfileConfigData(tgrFrmwrkConfigInsertList,'profileIDprofileIDprofileIDprofileID');
	
        
    }
    
}