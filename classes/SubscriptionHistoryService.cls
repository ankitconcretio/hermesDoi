/*
* @purpose: This class is used to handle the operation related to Subscription History Object.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (13-06-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class SubscriptionHistoryService {
    /**
    * @description This method create subscription History Record.
    * @param type, which type of operation is performed.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Boolean, true if record is created successfully.
    */
    public static Boolean createRecord(String type, String recordId, String pageName, String ipAddress){
        try{
        	return createRecords(new List<String>{type}, recordId, pageName, ipAddress);    
        }
        catch(Exception e){
            throw new DoiException(e);
        }
    }
    
    /**
    * @description This method create subscription History Object.
    * @param type, which type of operation is performed.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Subscription_History__c, object.
    */
    public static Subscription_History__c createSubscriptionHistoryObject(String type, String recordId, String pageName, String ipAddress){
    	if(String.isBlank(type) || String.isBlank(recordId) || String.isBlank(pageName) || String.isBlank(ipAddress)){
        	throw new DoiException('parameters should not be empty');    
        }
        String objectName = DoiQueryManager.getObjectName(recordId);
        Subscription_History__c subHistoryObj = new Subscription_History__c();
        subHistoryObj.Type__c = type;       
        subHistoryObj.Confirmation_Page__c = pageName;
        subHistoryObj.Ip_Address__c = ipAddress;
        subHistoryObj.DateTime__c = datetime.now();
        if(objectName.equalsIgnoreCase('Lead')){
        	subHistoryObj.Lead__c = recordId;    
        }
        else{
        	subHistoryObj.Contact__c = recordId;    
        }
        return subHistoryObj;
    }
    
    /**
    * @description This method create subscription History records.
    * @param types, various types of which Subscription History records will be created.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Boolean, true if records are created successfully.
    */
    public static Boolean createRecords(List<String> types, String recordId, String pageName, String ipAddress){
        Boolean response = false;
        if(types.isEmpty() || String.isBlank(recordId) || String.isBlank(pageName) || String.isBlank(ipAddress)){
        	throw new DoiException('parameters should not be empty');    
        }
    	List<Subscription_History__c> lstSubscriptionHistory = new List<Subscription_History__c> ();
        try{
            for(String type : types){
                lstSubscriptionHistory.add(createSubscriptionHistoryObject(type, recordId, pageName, ipAddress));    
            }
	    	response = DoiDmlManager.processRecords(lstSubscriptionHistory, 'Insert');       
        }
        catch(Exception e){
            throw new DoiException(e);
        }
        return response;
    }
}