@isTest public class CustomMetadataDAOTest {
    @isTest static void testGetMetadata() {
        List<sObject> customMetadataRecords;
        Test.startTest();
        customMetadataRecords = new CustomMetadataDAO().getCustomMetadataRecords( 'select Enabled__c from TriggerFramework_Extensibility_Enabled__mdt' );
        Test.stopTest();
        System.assertEquals( [ select Enabled__c from TriggerFramework_Extensibility_Enabled__mdt ].size(), customMetadataRecords.size(), 'Size should match' );
    }
    
    public static void setMetadata( String query, List<sObject> records ) {
        CustomMetadataDAO.customMetadataRecordsMap.put( query, records );
    }
}