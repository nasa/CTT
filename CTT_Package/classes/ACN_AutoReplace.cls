public class ACN_AutoReplace {
    public static String sObjectName;
    public static String externalFieldApiName;
    public static String referencefieldApiName;
    public static String formulaFieldApiName;
    public static List<sObject> newRecords = new List<sObject>();
    
    private static List<sObject> allRecords = new List<sObject>();
    private static Set<String> operands = new Set<String>();
    private static Map<String, String> replaceMap = new Map<String, String>();
    private static final String ANDv = 'AND';
    private static final String ORv = 'OR';
    private static final String OPEN = '(';
    private static final String CLOSE = ')';
    private static final String CURLYOPEN = '{';
    private static final String CURLYCLOSE = '}';
    private static String finalExpression = '';
    private static String[] eachExpression = new String[]{};
        
        public static void autoReplace() {
            String formulaFieldValue, externalFieldValue, referencefieldValue;
            for(sObject eachRecord : newRecords) {
                formulaFieldValue = (String) eachRecord.get(formulaFieldApiName);
                if(formulaFieldValue != null) {
                    splitExpressionCURLY(formulaFieldValue);
                    evaluateEachCURLYExpression();
                    replaceString();
                }
            }
            System.debug('replaceMap:::: '+replaceMap);
            for(sObject eachRecord : newRecords) {
                formulaFieldValue = (String) eachRecord.get(formulaFieldApiName);
                if(formulaFieldValue != null) {
                    for(String target : replaceMap.keySet()) {
                        // String regex = '/'+target+'/g'; // /\bTHING|\bITEM|\bFOO/g
                        formulaFieldValue = formulaFieldValue.replace(target, encodeString(replaceMap.get(target),System.Label.ACN_EncodeChar));
                        System.debug('formulaFieldValue:::: '+formulaFieldValue);
                    }
                    eachRecord.put(formulaFieldApiName, decodeString(formulaFieldValue,System.Label.ACN_EncodeChar));
                }
            }
            update newRecords;
        }
    
    // 1st
    private static void splitExpressionCURLY(String expression) {
        Integer indexOfCurlyOpen = -1;
        Integer indexOfCurlyClose = -1;
        System.debug('expression:::: '+expression);
        String[] chars = expression.split('');
        for(Integer i = 0; i < chars.size(); i++){
            String singleChar = chars[i];
            if(singleChar == CURLYOPEN) {
                indexOfCurlyOpen = i;
                continue;
            }
            if(singleChar == CURLYCLOSE) {
                indexOfCurlyClose = i;
                break;
            }
        }
        String replace = expression.substring(indexOfCurlyOpen + 1 , indexOfCurlyClose);
        System.debug('replace:::: '+replace);
        eachExpression.add(replace); // [eachExpressionCounter++] = replace;
        expression = expression.replace( CURLYOPEN + replace + CURLYCLOSE, '');
        System.debug('expression:::: '+expression);
        if(! String.isBlank(expression)){
            splitExpressionCURLY(expression);
        }
        return;
    }
    
    // 2nd
    private static void evaluateEachCURLYExpression() {
        for(Integer j=0 ; j < eachExpression.size() ; j++) {
            String[] arrEachExpr = eachExpression[j].split('=:');
            evaluateEachExpression(arrEachExpr[0]);
            operands.add(arrEachExpr[1].trim());
        }
        return;
    }
    
    // 2nd -> 3rd
    private static void evaluateEachExpression(String expression){
        String tempExpression = expression;
        // (QI-000010 = Yes && QI-000011 = Yes) AND ((QI-000010 = Yes && QI-000011 = Yes) && (QI-000010 = Yes && QI-000011 = Yes))
        String expr = tempExpression.replaceAll('\\|\\|', ',').replaceAll('&&', ',').replaceAll('AND', ',').replaceAll('OR', ',').replaceAll('\\)', '').replaceAll('\\(', '').trim();
        System.debug('expr' + expr); // QI-000010 = Yes , QI-000011 = Yes , QI-000010 = Yes , QI-000011 = Yes , QI-000010 = Yes , QI-000011 = Yes
        String[] fnlResult = expr.split(',');
        // QI-000010 = Yes ,
        // ~QI-000011 = Yes ,
        // ~QI-000010 = Yes ,
        // ~QI-000011 = Yes ,
        // ~QI-000010 = Yes ,
        // ~QI-000011 = Yes
                
        /* list<string> op1 = new List<string>();
        list<string> op = new List<string>();
        list<string> op2 = new List<string>(); */
        
        for(String fnl : fnlResult) {
            fnl = fnl.trim(); // QI-000010 = Yes
            String eachExpr = fnl ; //'1.1==y';  // ==,!=,>,<,>=,<=  
            
            String[] operators = new String[]{'==','!=','=','>=','<=','>','<'}; // this order of operator is important. DO NOT CHANGE!
                for(integer i=0;i<operators.size() ; i++) {
                    if(eachExpr.contains(operators[i])){
                        String[] arr = fnl.split(operators[i]);
                        operands.add(arr[0].trim()); // using map.put(orgId,arr[0].trim()) // or maintain another list of orgId corresponding to each operand
                        break;
                    }
                }
        }
        return;
    }
    
    // 4th
    private static void replaceString() {
            allRecords = Database.query('SELECT Id, '+ referencefieldApiName +', '+ formulaFieldApiName +', '+ externalFieldApiName +' FROM '+ sObjectName +' WHERE '+ externalFieldApiName +' IN :operands');
            createMap(allRecords, externalFieldApiName, referencefieldApiName);
            
        if(sObjectName == 'ACN_Call_Flow_Screen__c') {
            allRecords.clear();
            allRecords = Database.query('SELECT Id, ACN_Question_Identifier__c, ACN_Question_Logic__c, ACN_External_Ref__c FROM ACN_Screen_Data_Elements__c WHERE ACN_External_Ref__c IN :operands');
            createMap(allRecords, 'ACN_External_Ref__c', 'ACN_Question_Identifier__c');
        }
        return;
    }
    
    // 5th
    private static String encodeString(String encodeStr, String encodeChar) {
        // encodeStr.replaceAll('(?<=.)(?=.)', ',');
        // System.debug('encodeStr:::: '+encodeStr.replaceAll('(?<=.)(?=.)', ','));
        return encodeStr.replaceAll('(?<=.)(?=.)', encodeChar);
    }
    
    // 6th
    private static String decodeString(String decodeStr, String decodeChar) {
        // encodeStr.replaceAll('(?<=.)(?=.)', ',');
        System.debug('decodeStr:::: '+decodeStr.remove(decodeChar));
        return decodeStr.remove(decodeChar);
    }
    
    private static void createMap(List<sObject> allRecords, String keyString, String valueString) {
        for(sObject eachRecord : allRecords) {
            replaceMap.put((String)eachRecord.get(keyString), (String)eachRecord.get(valueString));
        }
    }
}