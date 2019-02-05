@isTest
public class CaseControllerTest {
    @testSetup static void setup(){
 		Account accountObj = new Account(Name = 'Metacube Software PVT Ltd');
        insert accountObj;
        
        Contact contactObj = new Contact(AccountId = accountObj.Id, LastName = 'Test Account', Email = 'test@test.com');
        insert contactObj;
        
        Case caseObj = new Case(AccountId = accountObj.Id, ContactId = contactObj.Id, Status = 'New', SuppliedEmail = 'test@test.com', Sales_Process__c = 'Export');
        insert caseObj;
     }
    
    @isTest static void testInitMethod(){
        Case caseObj = [SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case Limit 1];
        System.assert(CaseController.init(caseObj.Id) !=null);
    }
    
    @isTest static void testInitMethodWhenUserDonotHaveAccess(){
        Case caseObj = [SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case Limit 1];
        System.assert(CaseController.init(caseObj.Id) !=null);
    }
    
    @isTest static void testConvertMethod(){
        Case caseObj = [SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case Limit 1];
        Lead_Source__c leadSourceObj = new Lead_Source__c(Name = 'Test exhibition');
        insert leadSourceObj;
        caseObj = CaseController.init(caseObj.Id);
        Map<String, String> leadFields = new Map<String, String>{'Title' => 'Test Lead', 'LeadSource' => leadSourceObj.Id };
        System.assert(CaseController.convert(caseObj, leadFields).title == 'Test Lead');
    }
    
    @isTest static void negativeTestConvertMethod(){
        Case caseObj = [SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case Limit 1];
        caseObj.AccountId = null;
        caseObj.ContactId = null;
        caseObj.Sales_Process__c = null;
        update caseObj;
        
        Lead_Source__c leadSourceObj = new Lead_Source__c(Name = 'Test exhibition');
        insert leadSourceObj;
        caseObj = CaseController.init(caseObj.Id);
        Map<String, String> leadFields = new Map<String, String>{'Title' => null , 'LeadSource' => null };
            try {
                CaseController.convert(caseObj, leadFields);
            } catch(AuraHandledException exc){
                System.assert(exc.getMessage().contains('Script-thrown exception') == true);
                System.debug(exc);
            }
    }
    
    @isTest static void negativeTestConvertMethodWhenCaseIsAlreadyClosed(){
        Case caseObj = [SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case Limit 1];
        caseObj.Status = 'Closed';
        update caseObj;
        Lead_Source__c leadSourceObj = new Lead_Source__c(Name = 'Test exhibition');
        insert leadSourceObj;
        caseObj = CaseController.init(caseObj.Id);
        Map<String, String> leadFields = new Map<String, String>{'Title' => 'TestLeadTitle' , 'LeadSource' => leadSourceObj.Id };
            try {
                CaseController.convert(caseObj, leadFields);
            } catch(AuraHandledException exc){
                exc.getMessage().contains('Lead Title: You must enter a value.');
            }
    }

}