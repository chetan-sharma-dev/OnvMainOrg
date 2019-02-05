public class LeadsServiceImpl implements ILeadsService {
	
    public List<Lead> getLeadsById(Set<Id> ids) {
        
        return LeadsSelector.getInstance().selectLeadsById(ids);
        
    }
    
    public List<Lead> upsertLeads(List<Lead> leads) {
        
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Lead leadRecord : leads) {
            contactIds.add(leadRecord.Contact__c);
            accountIds.add(leadRecord.Account__c);
        }
        
        Map<Id, Contact> leadContacts = new Map<Id, Contact>((List<Contact>)ContactsSelector.getInstance().selectSObjectsById(contactIds));
        Map<Id, Account> leadAccounts = new Map<Id, Account>((List<Account>)AccountsSelector.getInstance().selectSObjectsById(accountIds));
        
        for(Lead leadRecord : leads) {
            
            leadRecord.Salutation = leadContacts.get(leadRecord.Contact__c).Salutation;
            leadRecord.FirstName = leadContacts.get(leadRecord.Contact__c).FirstName;
            leadRecord.MiddleName = leadContacts.get(leadRecord.Contact__c).MiddleName;
            leadRecord.LastName = leadContacts.get(leadRecord.Contact__c).LastName;
            leadRecord.Suffix = leadContacts.get(leadRecord.Contact__c).Suffix;
            
            //contact email set to email of lead
            leadRecord.Email = leadContacts.get(leadRecord.Contact__c).Email;
            
            //setting company field which is required
            leadRecord.Company = leadAccounts.get(leadRecord.Account__c).Name;
        }
        
        fflib_ISObjectUnitOfWork uow = Application.unitOfWork.newInstance();
        UpsertUnitOfWorkLeadsHelper upsertLeadsWork = new UpsertUnitOfWorkLeadsHelper();
        uow.registerWork(upsertLeadsWork);
        upsertLeadsWork.registerProjectedStockUpsert(leads);
        uow.commitWork();
        
        return leads;
        
    }
    
    public List<Opportunity> convertLeadToOpportunity(List<LeadsService.LeadConvertWrapper> leads) {
        
        Map<Id, Opportunity> convertedOpportunities = new Map<Id, Opportunity>();
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        List<Database.LeadConvert> leadsToBeConverted = new List<Database.LeadConvert>();
        Database.LeadConvert leadConvert;
        
        for(LeadsService.LeadConvertWrapper leadConvertWrapper : leads) {
            leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(leadConvertWrapper.leadRecord.Id);
            leadConvert.setAccountId(leadConvertWrapper.leadRecord.Account__c);
            leadConvert.setContactId(leadConvertWrapper.leadRecord.Contact__c);
            leadConvert.setOpportunityName(leadConvertWrapper.opportunityName);
            leadConvert.setConvertedStatus('Qualified');
            leadConvert.setOwnerId(leadConvertWrapper.leadRecord.OwnerId);
            leadsToBeConverted.add(leadConvert);
            leadsMap.put(leadConvertWrapper.leadRecord.Id, leadConvertWrapper.leadRecord);
        }
        
        Set<Id> convertedOpportunitiesIds = new Set<Id>();
        List<Database.LeadConvertResult> leadsConvertResult = Database.convertLead(leadsToBeConverted);
        
        for(Database.LeadConvertResult leadConvertResult : leadsConvertResult) {
            convertedOpportunitiesIds.add(leadConvertResult.getOpportunityId());
        }
        
        //Update fields of opportunity which are on Lead Already
        convertedOpportunities = new Map<Id, Opportunity>((List<Opportunity>)OpportunitiesSelector.getInstance().selectSObjectsById(new Set<Id>(convertedOpportunitiesIds)));
        
        for(Database.LeadConvertResult leadConvertResult : leadsConvertResult) {
            convertedOpportunities.get(leadConvertResult.getOpportunityId()).Lead_Source__c = leadsMap.get(leadConvertResult.getLeadId()).Lead_Source__c;
            convertedOpportunities.get(leadConvertResult.getOpportunityId()).Merchant__c = leadsMap.get(leadConvertResult.getLeadId()).Merchant__c;
            convertedOpportunities.get(leadConvertResult.getOpportunityId()).CloseDate = Date.today();
        }
        
        List<Opportunity> opportunitiesToBeUpdated = new List<Opportunity>(convertedOpportunities.values());
        fflib_ISObjectUnitOfWork uow = Application.unitOfWork.newInstance();
        uow.registerDirty(opportunitiesToBeUpdated);
        uow.commitWork();
        
        return opportunitiesToBeUpdated;
        
    }
    
    /*
     * Unit of work upsert helper class - UpsertUnitOfWorkProjectedStockHelper
	*/
    private class UpsertUnitOfWorkLeadsHelper implements fflib_SObjectUnitOfWork.IDoWork { 
        
        public Database.UpsertResult[] Results {get; private set;}
        
        private List<Lead> m_records;
        
        public UpsertUnitOfWorkLeadsHelper() {  
            m_records = new List<Lead>();
        }
        
        public void registerProjectedStockUpsert(List<Lead> records) {
            m_records.addAll(records);
        }
        
        public void doWork() {
            Results = Database.upsert(m_records, false);                
        }
        
    }
}