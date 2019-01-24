/*
* @purpose: This is the class for performing all Dml operations in Doi process.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (01-06-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiDmlManager {
    /**
    * @description This method returns true when updation of sObjectList is successfull.
    * @param sObjList contains list to update.
    * @return Boolean, returns true when updation is successfull.
    */
    private static Boolean updateRecords(List<sObject> sObjectList){
        update sObjectList;
        return true;       
    }
    
    /**
    * @description This method returns true when insertion of sObjectList is successfull.
    * @param sObjList contains list to insert.
    * @return Boolean, returns true when insertion is successfull.
    */
    private static Boolean insertRecords(List<sObject> sObjectList){
        insert sObjectList;
        return true;
    }
    
    /**
    * @description This method process the single record and send the record for dml operation.
    * @param sObj contains a record to perform dmlType operation.
    * @param dmlType contains dml operation to be performed.
    * @return Boolean, returns true when dml operation is successfully performed.
    */
    public static Boolean processRecords(SObject sObj, String dmlType){
        Boolean response = false;
        if(sObj == null){
        	throw new DoiException('SObject should not be null');	    
        }
        else if(String.isBlank(dmlType)){
        	throw new DoiException('dmlType should not be empty');    
        }
        try{
            response = processRecords(new List<SObject>{sObj}, dmlType);    
        }
        catch(Exception e){
        	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());	    
        }
        return response;
    }
    
    /**
    * @description This method process the list of record and send the records for dml operation.
    * @param sObjList contains list of records to perform dmlType operation.
    * @param dmlType contains dml operation to be performed.
    * @return Boolean, returns true when dml operation is successfully performed.
    */
    public static Boolean processRecords(List<SObject> sObjList, String dmlType){
        Boolean response = false;
        if(sObjList.isEmpty()){
        	throw new DoiException('SObject should not be null');	    
        }
        else if(String.isBlank(dmlType)){
        	throw new DoiException('dmlType should not be empty');    
        }
        try{
            if(dmlType.equalsIgnoreCase('insert')){
                response = insertRecords(sObjList);
            }
            else if(dmlType.equalsIgnoreCase('update')){
                response = updateRecords(sObjList);
            }    
        }
        catch(Exception e){
        	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());	    
        }      
        return response;    
    }
}