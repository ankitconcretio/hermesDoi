/*
* @purpose: This is the class for performing all queries of Doi process.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (23-05-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiQueryManager {    
    private static final String BASE_QUERY = 'Select {0} From {1} {2}';
    
    /**
     * @name : getRecords 
     * @params :  queryString   : This string type varibale holds query to be execute.
     * @description : This method returns the result, after the execution of query.
	 **/
    public static List<SObject> getRecords(String queryString){
        return Database.query(queryString);
    }
        
    /**
     * @name : getObjectName 
     * @params :  recordId   : This string type varibale holds the selected recordId.
     * @description : This method returns the object name fetched from recordId.
	 **/
    public static String getObjectName(String recordId){
    	String objectName = '';
        if(String.isNotBlank(recordId)){
            try{
                objectName = String.valueOf(Id.valueOf(recordId).getSObjectType()); 
            }
            catch(Exception e){
                throw new DoiException(e);
            }    
        }
        else{
        	throw new DoiException('Record Id not found');    
        } 
        return objectName;
    }
    
    /**
     * @name : isLeadOrContact 
     * @params :  recordId   : This string type varibale holds the selected recordId.
     * @description : This method returns true, if record belongs to Lead Or Contact.
	 **/
    public static Boolean isLeadOrContact(String recordId){
        Boolean response = false;
        String objectName = '';
        if(String.isNotBlank(recordId)){
            try{
            	objectName = DoiQueryManager.getObjectName(recordId);		     
            }
            catch(Exception e){
                throw new DoiException(e);
            }
            if(objectName.equalsIgnoreCase('Lead') || objectName.equalsIgnoreCase('Contact')){
            	response = true;	    
            }
        }
        else{
            throw new DoiException('Record Id not found');    
        }
        return response;
    }
    
    
    /**
     * @name : getRecords 
     * @params :  fieldNames   : This list type varibale holds the name of fields to be fetched.
     * 			  objectName   : This string type varibale holds the name of Object.
     * 			  condition    : This string type variable holds the condition, which is used to fetch the result from database.
     * @description : This method prepares the queryString on the basis of fieldNames, objectName & condition then returns the result.
	 **/
    public static List<SObject> getRecords(String objectName, List<String> fieldNames, String condition){
        String formattedString = '';
        if(String.isBlank(objectName)){
        	throw new DoiException('Object name should not be blank');		
        }
        else if(fieldNames.isEmpty()){
        	throw new DoiException('fieldNames should not be empty');		
        }
        else{
            String fields = String.join(fieldNames, ',');
            if(String.isNotBlank(condition)){
            	formattedString = String.format(BASE_QUERY, new List<String>{fields, objectName, condition});    
            }
            else{
            	formattedString = String.format(BASE_QUERY, new List<String>{fields, objectName, ''});    
            }            
            try{
                return DoiQueryManager.getRecords(formattedString);
            }
            catch(Exception e){
                throw new DoiException(e);
            }
        } 		    
    }
}