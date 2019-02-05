@isTest
public class LeadControllerTest {
    @testSetup static void setup(){
        Profile adminProfile = [SELECT Id, Name FROM profile WHERE Name='System Administrator' LIMIT 1];
        Profile chatterFreeProfile = [SELECT Id, Name FROM profile WHERE Name='Read Only' LIMIT 1];
        
        User adminUser = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'admin.user@asdf.com',
                            Username = 'admin.user@asdf.com',
                            ProfileId = adminProfile.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        User chatterFreeUser = new User(LastName = 'Chatter',
                            FirstName='Free',
                            Alias = 'jliv',
                            Email = 'test.chatter@asdf.com',
                            Username = 'test.chatter@asdf.com',
                            ProfileId = chatterFreeProfile.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert chatterFreeUser;
        Account accountObj = new Account(Name = 'Metacube Software PVT Ltd');
        insert accountObj;
        Id merchantcustomerRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company/Consignor').getRecordTypeId();
        Account accountMerchantObj = new Account(Name= 'MerchantAccountTest', RecordTypeId = merchantcustomerRecordTypeIdAccount);
        insert accountMerchantObj;
        Contact contactObj = new Contact(AccountId = accountObj.Id, LastName = 'Test Account', Email = 'test@test.com');
        insert contactObj;
        
        Lead_Source__c leadSourceObj = new Lead_Source__c(Name = 'Test exhibition');
        insert leadSourceObj;
        Lead leadObj = new Lead(Title = 'Test Title', Lead_Source__c = leadSourceObj.Id, Lead_Receipt_Date__c = System.today(), 
                                Account__c = accountObj.Id, Contact__c = contactObj.Id, Merchant__c = accountMerchantObj.Id, Salutation = contactObj.Salutation,
                                FirstName = contactObj.FirstName, MiddleName = contactObj.MiddleName, LastName = contactObj.LastName,
                                Suffix = contactObj.Suffix, Email = contactObj.Email, Company = accountObj.Name );
        insert leadObj;
        
        
        
    }
    
    @isTest static void testGetLeadMethodWithoutRecordAccess(){
       User chatterFreeUser = [SELECT Id, LastName, FirstName, Alias, Email, Username, ProfileId FROM User WHERE LastName = 'Chatter'];
       Lead leadObj = [SELECT Id FROM Lead LIMIT 1];
        try {
            System.runAs(chatterFreeUser){
                System.assert(LeadController.getLead(leadObj.Id) != null);
            }
        } catch(Exception error) {
            System.debug(error.getMessage());
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
    @isTest static void testGetLeadMethodWithRecordAccess(){
        try {
            Lead leadObj = [SELECT Id, Title, Lead_Source__c, Merchant__c, Lead_Receipt_Date__c, Account__c, Contact__c FROM Lead LIMIT 1];
            System.assert(LeadController.getLead(leadObj.Id) != null);
        } catch(Exception error) {
            System.debug(error.getMessage());
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
    
    @isTest static void testSaveLeadMethodSuccess(){
        Account accountObj = [SELECT Id, Name FROM Account WHERE Name = 'Metacube Software PVT Ltd'];
        Contact contactObj = [SELECT Id, AccountId, Salutation, FirstName, MiddleName, Suffix, LastName, Email FROM Contact where Email='test@test.com'];
        Lead_Source__c leadSourceObjNew = new Lead_Source__c(Name = 'Test exhibition New');
        insert leadSourceObjNew;
        
        Lead leadObjNew = new Lead(Title = 'Test Title1', Lead_Source__c = leadSourceObjNew.Id, Lead_Receipt_Date__c = System.today(), 
                                Account__c = accountObj.Id, Merchant__c=accountObj.Id , Contact__c = contactObj.Id, Salutation = contactObj.Salutation,
                                FirstName = contactObj.FirstName, MiddleName = contactObj.MiddleName, LastName = contactObj.LastName,
                                Suffix = contactObj.Suffix, Email = contactObj.Email, Company = accountObj.Name );
        //insert leadObj;
        //try {
            //Lead leadObj = [SELECT Id, Title, Lead_Source__c, Merchant__c, Lead_Receipt_Date__c, Account__c, Contact__c FROM Lead LIMIT 1];
            System.assert(LeadController.saveLead(leadObjNew) != null);

        
    }
	
    @isTest static void testSaveLeadMethodError(){
        Account accountObj = [SELECT Id, Name FROM Account WHERE Name = 'Metacube Software PVT Ltd'];
        Contact contactObj = [SELECT Id, AccountId, Salutation, FirstName, MiddleName, Suffix, LastName, Email FROM Contact where Email='test@test.com'];
        Lead_Source__c leadSourceObjNew = new Lead_Source__c(Name = 'Test exhibition New');
        insert leadSourceObjNew;
        
        Lead leadObjNew = new Lead();
        //insert leadObj;
        try {
            //Lead leadObj = [SELECT Id, Title, Lead_Source__c, Merchant__c, Lead_Receipt_Date__c, Account__c, Contact__c FROM Lead LIMIT 1];
            System.assert(LeadController.saveLead(leadObjNew) != null);
        } catch(Exception error) {
            System.debug(error.getMessage());
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
    @isTest static void testcreateOpportunityMethodSuccess(){
       // try {
            Lead leadObj = [SELECT Id, Title, Lead_Source__c, Merchant__c, Lead_Receipt_Date__c, Account__c, Contact__c, OwnerId FROM Lead LIMIT 1];
        	System.debug('leadObj'+leadObj);    
        System.assert(LeadController.createOpportunity(leadObj, 'Test opp') !=null);
            
      //  }
        
    }
    @isTest static void testcreateOpportunityMethodWithoutOpportunityName(){
        Lead leadObj = [SELECT Id, Title, Lead_Source__c, Merchant__c, Lead_Receipt_Date__c, Account__c, Contact__c, OwnerId FROM Lead LIMIT 1];
        System.debug('leadObj'+leadObj);    
        try{
            Opportunity opp=LeadController.createOpportunity(leadObj, '');
        } catch(Exception error)
        {
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
    @isTest static void testcreateOpportunityMethodWithoutMerchant(){
        Account accountObj = [SELECT Id, Name FROM Account WHERE Name = 'Metacube Software PVT Ltd'];
        Contact contactObj = [SELECT Id, AccountId, Salutation, FirstName, MiddleName, Suffix, LastName, Email FROM Contact where Email='test@test.com'];
        Lead_Source__c leadSourceObjNew = new Lead_Source__c(Name = 'Test exhibition New');
        insert leadSourceObjNew;
        
        Lead leadObjNew = new Lead(Title = 'Test Title1', Lead_Source__c = leadSourceObjNew.Id, Lead_Receipt_Date__c = System.today(), 
                                Account__c = accountObj.Id,Contact__c = contactObj.Id, Salutation = contactObj.Salutation,
                                FirstName = contactObj.FirstName, MiddleName = contactObj.MiddleName, LastName = contactObj.LastName,
                                Suffix = contactObj.Suffix, Email = contactObj.Email, Company = accountObj.Name );
        insert leadObjNew;
        System.debug('leadObj'+leadObjNew);    
        try{
            Opportunity opp=LeadController.createOpportunity(leadObjNew, 'Test Opp');
        } catch(Exception error)
        {
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
    @isTest static void testcreateOpportunityMethodWithoutLead(){
        
        try{
            Opportunity opp=LeadController.createOpportunity(null, 'Test Opp');
        } catch(Exception error)
        {
            System.assert(error.getMessage().contains('Script-thrown exception'));
        }
        
    }
}