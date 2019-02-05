@isTest
public class CasesServiceTest {
    @testSetup static void setup(){
        Account accountObj = new Account(Name = 'Metacube Software PVT Ltd');
        insert accountObj;
        
        Contact contactObj = new Contact(AccountId = accountObj.Id, LastName = 'Test Account', Email = 'test@test.com');
        insert contactObj;
        
        List<Case> cases = new List<Case>();
        
        for(Integer i = 0; i < 5 ; i++){
            cases.add(new Case(AccountId = accountObj.Id, ContactId = contactObj.Id, Status = 'New', SuppliedEmail = 'test' + i +'@test.com', Sales_Process__c = 'Export'));
        }
        insert cases;
    }
    
    @isTest static void testConvertAndMethod(){
        MAP<Id, Case> casesMap = new MAP<Id, Case>([SELECT Id, AccountId, ContactId, Status, SuppliedEmail, Sales_Process__c FROM Case]);
        List<Case> cases = CasesService.getCasesById(casesMap.keySet());
        System.assert(cases.size() > 0);
        
        Lead_Source__c leadSourceObj = new Lead_Source__c(Name = 'Test exhibition');
        insert leadSourceObj;
        
        List<CasesService.CaseConvertWrapper> casesToConvert = new List<CasesService.CaseConvertWrapper>();
        Integer counter = 1;
        for(Case caseObj : cases){
        	casesToConvert.add(new CasesService.CaseConvertWrapper(caseObj, 'Test Title ' + counter++, leadSourceObj.Id));
        }
        
        List<Lead> leads = CasesService.convertToLead(casesToConvert);
        System.assert(leads.size() > 0);
        
    }
}