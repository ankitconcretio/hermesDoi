public class HPDoiProcessCtlr {
	public String recordId {get;set;}
    public String leadSource {get;set;}
    public HPDoiProcessCtlr(){
        List<SObject> sObjList = new List<SObject>();
    	String recievedId = ApexPages.currentPage().getParameters().get('id');
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
                                                          new List<String>{'LeadSource'},
                                                          condition);	    
                }
            }
            catch(Exception e){
            	System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());    
            }
            if(sObjList.size() == 1){
                Sobject sObj = sObjList.get(0);
                leadSource = String.valueOf(sObj.get('LeadSource'));
            }
        }
    }
}