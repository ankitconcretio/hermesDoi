/*
* @purpose: This is the helper class for all three controller classes(DoiConfirmationCtlr, UnsubscribeEmailCtlr & ReSubscribeEmailCtlr).
*			In this class some common methods like returning Sobject List by passing email Id as parameter and checking Lead Converted or not and getting
*			required template to be used.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (23-04-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiHelper {
    /**
     * @name : isConvertedLead 
     * @params :  recordId   : This id type varibale holds the record Id of selected record.
     * @description : This method verify the objectName from record Id, then verify whether object is Lead or not, if object is not a Lead object then return recordId 
     * 				  which was passed in this method.
     * 				  But when object is Lead object and if that lead is converted into contact then return ConvertedConatctId, else return recordId which was passed in 
     * 				  this method. 
	 **/     
    public static String isConvertedLead(String recordId){
        List<SObject> sObjList = new List<SObject>();
        String response = '', condition = '';
        if(String.isNotBlank(recordId)){
            try{
                if(DoiQueryManager.getObjectName(recordId).equalsIgnoreCase('lead')){
                    condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjList = DoiQueryManager.getRecords('Lead',
                                                          new List<String>{'isConverted', 'convertedContactId'},
                                                          condition);	    
                }
                else{
                    response = recordId;    
                }
            }
            catch(Exception e){
            	throw new DoiException(e);
            }
            if(sObjList.size() == 1){
                SObject sObj = sObjList.get(0);
                if(Boolean.valueOf(sObj.get('isConverted')) == true){
                    response = String.valueOf(sObj.get('convertedContactId'));
                }
                else{
                    response = recordId;    
                }
            }
        }
        else{
            throw new DoiException('Record Id cannot be blank');     
        }
        return response;
    }
    
    /**
     * @name : getRecordsBasedOnEmail 
     * @params :  emailId    : This String type varibale holds the email Id of selected record.
     * @description : This method search the records based on given emailID on both Lead & Contact.
	 **/
    public static List<SObject> getRecordsBasedOnEmail(String emailId){
    	List<SObject> sObjectList = new List<SObject>();
        String response = '', condition = '';

        if(String.isNotBlank(emailId)){
            try{
                condition = 'WHERE Email=' +'\''+emailId+'\''+ ' AND isConverted='+false+ ' LIMIT 10000';
                sObjectList = DoiQueryManager.getRecords('Lead',
                                                         new List<String>{'Id', 'Double_Opt_In__c', 'Email_Opt_In__c', 'HasOptedOutOfEmail', 'Opt_Out__c'},
                                                         condition);	    
            }
            catch(Exception e){
                throw new DoiException(e);
            }
            
            if(sObjectList.isEmpty()){
                try{
                    condition = 'WHERE Email=' +'\''+emailId+'\''+ ' LIMIT 10000';
                    sObjectList = DoiQueryManager.getRecords('Contact',
                                                             new List<String>{'Id', 'Double_Opt_In__c', 'Email_Opt_In__c', 'HasOptedOutOfEmail', 'Opt_Out__c'},
                                                             condition);    
                }
                catch(Exception e){
                    throw new DoiException(e);
                }
            }
        }
        return sObjectList;
    }
    
    /**
     * @name : getRequiredTemplate 
     * @params :  status : This string type varibale used to identify the process(which template to be fetched).
     * 			  recordId    : This string type varibale holds the record Id of selected record.
     * @description : This method identify which template should be selected on the basis of status & recordId.
	 **/
    public static String getRequiredTemplate(String recordId, String status){
    	String response = '';
        String objectName = '', templateName = '';
        if(String.isNotBlank(recordId) && String.isNotBlank(status)){
            try{
                objectName= String.valueOf(Id.valueOf(recordId).getSobjectType());    
            }
            catch(Exception e){
                throw new DoiException(e);
            } 
            if(objectName.equalsIgnoreCase('Lead')){
                if(status.equalsIgnoreCase('DOI')){
                	templateName  = Label.Email_Template_For_Doi_Email_Lead;  
                }
                else if(status.equalsIgnoreCase('Unsubscribe')){
                    templateName  = Label.Email_Template_For_Unsubscribe_Email_Lead;
                }
                else if(status.equalsIgnoreCase('ReSubscribe')){
                    templateName  = Label.Email_Template_For_ReSubscribe_Email_Lead;
                }
            }
            else if(objectName.equalsIgnoreCase('Contact')){
             	if(status.equalsIgnoreCase('DOI')){
                	templateName  = Label.Email_Template_For_Doi_Email_Contact;  
                }
                else if(status.equalsIgnoreCase('Unsubscribe')){
                    templateName  = Label.Email_Template_For_Unsubscribe_Email_Contact;
                }
                else if(status.equalsIgnoreCase('ReSubscribe')){
                    templateName  = Label.Email_Template_For_ReSubscribe_Email_Contact;
                }   
            }
            else{
            	throw new DoiException('Invalid record Id found');     
            }
            
            if(String.isNotBlank(templateName)){	
                try{
                    String condition = 'WHERE developername=' +'\''+templateName+'\''+ ' LIMIT 1';
                    List<Sobject> sObjList = DoiQueryManager.getRecords('EmailTemplate',
                                                                        new List<String>{'Id'},
                                                                       	condition);
                    if(sObjList.size() == 1){
                    	response = sObjList.get(0).Id;    
                    }     
                }
                catch(Exception e){
                    throw new DoiException(e);
                }
            }           
        }
        else{
        	throw new DoiException('RecordId or status not found');    
        }
        return response;
    }
}