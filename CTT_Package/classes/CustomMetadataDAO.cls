public class CustomMetadataDAO {
    @testVisible static private Map<String,List<sObject>> customMetadataRecordsMap = new Map<String,List<sObject>>();
    
    public List<sObject> getCustomMetadataRecords(String query) {
        if ( !customMetadataRecordsMap.containsKey( query ) ) {
            customMetadataRecordsMap.put( query, Database.query( query ) );
        }
        return customMetadataRecordsMap.get( query );
    }
}