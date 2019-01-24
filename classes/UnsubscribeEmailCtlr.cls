/*
* @purpose: This is the controller class of UnsubscribeEmail(Vf page) in which Object is verified using record Id(fetched from URL). Then on the
			the basis of record Id indetify the user and update the Opt out field on click of Unsubscribe button. 
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (11-04-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class UnsubscribeEmailCtlr {
    public String recordId {set;get;}
    public String userName {set;get;}
    public Boolean isUnsubscribed {set;get;}
    public String leadSource {get;set;}
    public String salutation {set;get;}
    public String ipAddress {get;set;}
    public String currentPageName {get;set;}
    public Boolean postalOptIn {get;set;}
    public Boolean telephoneOptIn {get;set;}
    public Boolean emailOptIn {get;set;}
    
    //Constructor of UnsubscribeEmailCtlr class.
    public UnsubscribeEmailCtlr(){
        List<SObject> sObjList = new List<SObject>();
        String recievedId = '';
        //fetch record Id from page URL.
        recievedId = ApexPages.currentPage().getParameters().get('id');
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if(String.isBlank(ipAddress)){
        	ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');    
        }
        currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        
        if(String.isNotBlank(recievedId)){
            //verify whether object is Lead or not, if object is Lead then check lead isConverted or not.
			try{
                recordId = DoiHelper.isConvertedLead(recievedId);
			}
            catch(Exception e){
            	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
        }
        
        if(String.isNotBlank(recordId)){
            //get sObjectInstance from DoiHelper
            try{
            	if(DoiQueryManager.isLeadOrContact(recordId)){
                    String condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(recordId),
                                                          new List<String>{'Name', 'HasOptedOutOfEmail', 'LeadSource', 'Salutation_Mktg_EN__c',
                                                              				'Postal_Opt_In__c','Tel_Opt_In__c','Opt_out__c','EMail_Opt_In__c'},
                                                          condition);	    
                }
            }
            catch(Exception e){
            	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
            if(sObjList.size() == 1){
                Sobject sObj = sObjList.get(0);
                //set the properties of this class.
            	userName = String.valueOf(sObj.get('Name'));
                isUnsubscribed = Boolean.valueOf(sObj.get('Opt_out__c'));
                leadSource = String.valueOf(sObj.get('LeadSource'));
                salutation = String.valueOf(sObj.get('Salutation_Mktg_EN__c'));
                postalOptIn = Boolean.valueOf(sObj.get('Postal_Opt_In__c'));
                telephoneOptIn = Boolean.valueOf(sObj.get('Tel_Opt_In__c'));
                emailOptIn =Boolean.valueOf(sObj.get('EMail_Opt_In__c'));
            }
        }  
    }
    
    /**
     * @name : unsubscribeEmail 
     * @params :  recordId   : This string type varibale holds the record Id of selected record.
     * @description : This method identify object name using record Id and update the fields related to Unsubscribe.
     * @returnType : Integer : (0 => Success), (1 => Record not found), (2 => Duplicate Record Found), 
     * 						   (3 => Unsubscribed),(4 => Field Not Updateable), (5 => Update Failed), (6 => Tel Opt Out & Postal Opt Out), 
     * 						   (7 => Tel Opt Out), (8 => Postal Opt Out), (9 => Email & tel Opt Out), (10 => Email & Post opt out)
     * 						   (11 => only email Opt Out)
	 **/
    @RemoteAction
    public static Integer unsubscribeEmail(String unsubscribeVal){
        System.debug('unsubscribeVal>> '+ unsubscribeVal);
        Map<String, Object> mapUnsubscribeVal = (Map<String, Object>) JSON.deserializeUntyped(unsubscribeVal);
        String recordId = String.valueOf(mapUnsubscribeVal.get('recordId'));
        String currentPageName = String.valueOf(mapUnsubscribeVal.get('currentPageName'));
        String ipAddress = String.valueOf(mapUnsubscribeVal.get('ipAddress'));
        
        Map<String, Boolean> OptValues = new Map<String, Boolean>();
        OptValues.put('emailOption', Boolean.valueOf(mapUnsubscribeVal.get('emailOption')));
        OptValues.put('telephoneOption', Boolean.valueOf(mapUnsubscribeVal.get('telephoneOption')));
        OptValues.put('postOption', Boolean.valueOf(mapUnsubscribeVal.get('postOption')));
        
        List<SObject> sObjectList = new List<SObject>();
        Boolean isOptOut;
        Integer response = 0;
  
        if(String.isNotBlank(recordId)){
            //get sObjectInstance from DoiHelper
            try{
            	if(DoiQueryManager.isLeadOrContact(recordId)){
                    String condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjectList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(recordId),
                                                             new List<String>{'HasOptedOutOfEmail','Postal_Opt_In__c','Tel_Opt_In__c','Opt_Out__c','EMail_Opt_In__c'},
                                                             condition);	    
                }
            }
            catch(Exception e){
            	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
            if(sObjectList.isEmpty()){
                response = 1;
            }
            else if(sObjectList.size() == 1){
                Sobject sObj = sObjectList.get(0);
                isOptOut = Boolean.valueOf(sObj.get('Opt_Out__c'));          
                //check whether General Opt Out field is selected or not.
                if(isOptOut == true){
                    response = 3;
                }
                else{
                    if(String.isBlank(currentPageName) || String.isBlank(ipAddress)){
                        response = 5;    
                    }
                    else{
                        try{                    
                            Boolean result = DoiDmlManager.processRecords(setUnsubscribeValues(sObj, OptValues),
                                                                          'Update');
                            if(result == true){
                                Boolean SubHistoryResult = setTypeAndCreateRecord(OptValues, recordId, currentPageName, ipAddress);   
                            }
                            else{
                            	response = 5;        
                            }
                        }
                        catch(Exception e){
                            System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                            response = 5;
                        }
                        if(OptValues.get('emailOption') == false && (OptValues.get('telephoneOption') == true || OptValues.get('postOption') == true)){
                            if(OptValues.get('telephoneOption') == true && OptValues.get('postOption') == true){
                                response = 6;    
                            }
                            else if(OptValues.get('telephoneOption') == true && OptValues.get('postOption') == false){
                                response = 7; 
                            }
                            else if(OptValues.get('telephoneOption') == false && OptValues.get('postOption') == true){
                                response = 8; 
                            }
                        }
                        else if(OptValues.get('emailOption') == true && OptValues.get('telephoneOption') == true && OptValues.get('postOption') == false){
                            response = 9;   
                        }
                        else if(OptValues.get('emailOption') == true && OptValues.get('telephoneOption') == false && OptValues.get('postOption') == true){
                            response = 10;     
                        }
                        else if(OptValues.get('emailOption') == true && OptValues.get('telephoneOption') == false && OptValues.get('postOption') == false){
                        	response = 11;    
                        }
                        if(Boolean.valueOf(sObj.get('Opt_Out__c')) == true){
                            response = 0;    
                        }
                    }                	    
                }
            }
		}
        else{
         	response = 1;   
        }
        return response;
    }
    
    /**
     * @name : verifyEmailForUnsubscribe 
     * @params :  emailId   : This String type varibale holds the email Id to verify the user.
     * @description : This method identify Subscriber through email Id and update OptOut field.
     * @returnType : Integer : (0 => Success), (1 => Record not found), (2 => Duplicate Record Found), (3 => Unsubscribed),
     * 						   (4 => Email Not Sent), (5 => Blank Email Id)
	 **/
    @RemoteAction
    public static Integer verifyEmailForUnsubscribe(String emailId){
        List<SObject> sObjectList = new List<SObject>();
        Boolean emailStatus = false;
        Id templateId;
    	Integer response = 0;
        String recordId = '';
        if(String.isBlank(emailId)){
            response = 5;
        }
        else{
 			try{
            	sObjectList = DoiHelper.getRecordsBasedOnEmail(emailId);    
            }
            catch(Exception e){
            	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());     
            }
            if(sObjectList.isEmpty()){
            	response = 1;    
            }
            else if(sObjectList.size() > 1){
            	response = 2;     
            }
            else{
                SObject sObj = sObjectList.get(0);
                recordId = String.valueOf(sObj.get('Id'));
                if(Boolean.valueOf(sObj.get('Opt_Out__c'))){
                    response = 3;    
                }
                else{
                    try{                       
                        templateId = DoiHelper.getRequiredTemplate(recordId, 'Unsubscribe');
                        if(String.isNotBlank(templateId)){
                            emailStatus = DoiEmailManager.sendEmail(recordId, templateId);
                            if(emailStatus == false){
                                response = 4;
                            }
                        }
                        else{
                            response = 4;    
                        }
                    }
                    catch(Exception e){
                        System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                        response = 4;
                    }	
                }
            }
        }
        return response;
    }
    
    /**
    * @description This method set Unsubscription values to sObject.
    * @param sObj, contains the sObject whose values to be updated.
    * @param OptValues, contains the map of values for unsubscription.
    * @return SObject, sObject with new values which will be updated.
    */
    private static SObject setUnsubscribeValues(SObject sObj, Map<String,Boolean> OptValues){
        if((OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == false && OptValues.get('postOption') == false) || OptValues.get('emailOption') == true){
            sObj.put('HasOptedOutOfEmail', true);    
            sObj.put('Email_Opt_In__c', false);    
            sObj.put('Double_Opt_In__c', false);    
        }
        if(OptValues.get('telephoneOption') == true){
        	sObj.put('Tel_Opt_In__c', false);     
        }
        if(OptValues.get('postOption') == true){
        	sObj.put('Postal_Opt_In__c', false);     
        }
        if(Boolean.valueOf(sObj.get('Email_Opt_In__c')) == false && Boolean.valueOf(sObj.get('Postal_Opt_In__c')) == false && Boolean.valueOf(sObj.get('Tel_Opt_In__c')) == false){
        	sObj.put('Opt_Out__c', true);    
        }
    	return sObj;    
    }
    
    /**
    * @description This method set type & create subscription History Records.
    * @param OptValues, contains the unsubscription values.
    * @param recordId, contains the record id on which this object will be created.
    * @param pageName, contains the name of vf page.
    * @param ipAddress, contains ip address where vf page was accessed
    * @return Boolean, true if record is created successfully.
    */
    private static Boolean setTypeAndCreateRecord(Map<String,Boolean> OptValues, String recordId, String pageName, String ipAddress){
        Boolean response = true;
        List<String> types = new List<String>();
        try{
            if((OptValues.get('emailOption') == false && OptValues.get('telephoneOption') == false && OptValues.get('postOption') == false) || OptValues.get('emailOption') == true){
                types.add(Label.Email_Opt_Out);    
            }
            if(OptValues.get('telephoneOption') == true){
                types.add(Label.Tel_Opt_Out);  
            }
            if(OptValues.get('postOption') == true){
                types.add(Label.Postal_Opt_Out);  
            }
            if(types.size() > 0){
            	response = SubscriptionHistoryService.createRecords(types, recordId, pageName, ipAddress);    
            }
        }
        catch(Exception e){
            System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
            throw new DoiException(e);
        }
        return response;
    }
}