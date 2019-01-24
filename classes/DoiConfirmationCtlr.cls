/*
* @purpose: This is the controller class of DoiConfirmation(Vf page) in which we verifying the object name through recordId (fetched from URL).
*   		And update the DOI field when user click on Confirm DOI button.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (11-04-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiConfirmationCtlr {
    public String recordId {get;set;}
    public String userName {set;get;}
    public Boolean isDoiConfirmed {set;get;}
    public Boolean isEmailOpted {set;get;}
    public String salutation {set;get;}
    public String leadSource {get;set;}
    public String privacyPolicyLink {get;set;}
    public String doiWebsite {get;set;}
    public String ipAddress {get;set;}
    public String currentPageName {get;set;}
    
    //Constructor of DoiConfirmationCtlr class.
    public DoiConfirmationCtlr(){
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
                                                          new List<String>{'Name', 'Double_Opt_In__c', 'Email_Opt_In__c', 'DOI_Origin_Website__c',
                                                              				'Salutation_Mktg_EN__c', 'LeadSource', 'DOI_Privacy_Policy_Link__c'},
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
                salutation = String.valueOf(sObj.get('Salutation_Mktg_EN__c'));
                isDoiConfirmed = Boolean.valueOf(sObj.get('Double_Opt_In__c'));
                isEmailOpted = Boolean.valueOf(sObj.get('Email_Opt_In__c'));
                leadSource = String.valueOf(sObj.get('LeadSource'));
                privacyPolicyLink = String.valueOf(sObj.get('DOI_Privacy_Policy_Link__c'));
                doiWebsite = String.valueOf(sObj.get('DOI_Origin_Website__c'));
            }
        }           
    }
	
    /**
     * @name   : confirmDOI 
     * @params :  recordId   : This Id type varibale holds the record Id of selected record.
     * @description : This method verify Subscriber using recordId & update the DOI field.
     * @returnType : Integer : (0 => Success), (1 => Record not found), (2 => Duplicate Record Found), 
     * 						   (3 => Unsubscribed), (4 => Already DOI Confirmed), (5 => Field Not Updateable),
     * 						   (6 => Update Failed)
	 **/   
    @RemoteAction
    public static Integer confirmDOI(String recordId, String currentPageName, String ipAddress){
        List<SObject> sObjectList = new List<SObject>();
        Boolean isDOISelected, isOptOut, isEmailOptIn;
        Integer response = 0;
        
        if(String.isNotBlank(recordId)){
        	//get sObjectInstance from DoiHelper
            try{
            	if(DoiQueryManager.isLeadOrContact(recordId)){
                    String condition = 'WHERE Id=' +'\''+recordId+'\'';
                    sObjectList = DoiQueryManager.getRecords(DoiQueryManager.getObjectName(recordId),
                                                             new List<String>{'Double_Opt_In__c', 'Email_Opt_In__c', 'HasOptedOutOfEmail'},
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
                isDOISelected = Boolean.valueOf(sObj.get('Double_Opt_In__c'));
                isOptOut = Boolean.valueOf(sObj.get('HasOptedOutOfEmail'));
                //isEmailOptIn = Boolean.valueOf(sObj.get('Email_Opt_In__c'));
                if(isOptOut == true){
                    response = 3;
                }
                else{
                	//check whether is Double_Opt_In field selected or not.
                    if(isDOISelected == true){
                        response = 4;
                    }
                    else{
                        if(String.isBlank(currentPageName) || String.isBlank(ipAddress)){
                        	response = 6;    
                    	}
                        else{
                            try{
                                sObj.put('Double_Opt_In__c', true);	    
                                Boolean result = DoiDmlManager.processRecords(sObj, 'Update');
                                if(result == true){
                                    Boolean SubHistoryResult = SubscriptionHistoryService.createRecord(Label.Double_Opt_In, recordId, currentPageName, ipAddress);    
                                }
                                else{
                                	response = 6;        
                                }
                            }
                            catch(Exception e){
                                System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                                response = 6;
                            }    
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
     * @name : verifyEmail 
     * @params :  emailId   : This String type varibale holds the email Id to verify the user.
     * @description : This method identify Subscriber through email Id and update DOI field.
     * @returnType : Integer : (0 => Success), (1 => Record not found), (2 => Duplicate Record Found), (3 => Unsubscribed)
     * 						   (4 => Already DOI Confirmed), (5 => Email Not Sent),(6 => Email not found)
	 **/
    @RemoteAction
    public static Integer verifyEmail(String emailId){
        List<SObject> sObjectList = new List<SObject>();
        Boolean emailStatus = false;
        Id templateId;
        Integer response = 0;
        String recordId = '';
        if(String.isBlank(emailId)){
            response = 6;
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
                if(Boolean.valueOf(sObj.get('HasOptedOutOfEmail'))){
                	response = 3;    
                }
                else if(Boolean.valueOf(sObj.get('Double_Opt_In__c'))){
                	response = 4;    
                }
                else if(Boolean.valueOf(sObj.get('Email_Opt_In__c'))){
                    try{
                        templateId = DoiHelper.getRequiredTemplate(recordId, 'DOI');
                        if(String.isNotBlank(templateId)){
                            emailStatus = DoiEmailManager.sendEmail(recordId, templateId);
                            if(emailStatus == false){
                                response = 5;	    
                            }
                        }
                        else{
                            response = 5;    
                        }
                    }
                    catch(Exception e){
                        System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
                        response = 5;
                    }    
                }
            }
        }
        return response;        
    }
}