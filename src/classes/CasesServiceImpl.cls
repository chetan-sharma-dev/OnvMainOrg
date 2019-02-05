public class CasesServiceImpl implements ICasesService { 
    
    public List<Case> getCasesById(Set<Id> ids) {
     
        return CasesSelector.getInstance().selectCasesById(ids);
        
    }
    
    public List<Lead> convertToLead(List<CasesService.CaseConvertWrapper> casesObjs) { 
        List<Lead> convertedLeads = new List<Lead>();
        List<Case> cases = new List<Case>();
        for(CasesService.CaseConvertWrapper caseWrapper : casesObjs){ 
            Case caseObj = caseWrapper.caseRecord; 
            Lead leadObj =  new Lead( Title =  caseWrapper.leadTitle,
                                     Lead_Source__c = caseWrapper.leadSource,
                                     Account__c = caseObj.AccountId,
                                     Company = caseObj.Account.Name,
                                     //Set Contact details
                                     Contact__c = caseObj.ContactId,
                                     Salutation = caseObj.Contact.Salutation,
                                     FirstName = caseObj.Contact.FirstName,
                                     MiddleName = caseObj.Contact.MiddleName,
                                     LastName = caseObj.Contact.LastName,
                                     Suffix = caseObj.Contact.Suffix,
                                     //Set other details on lead
                                     Status = 'New',
                                     Email = caseObj.Contact.Email,
                                     OwnerId = caseObj.OwnerId,
                                     Sales_Process__c = caseObj.Sales_Process__c,
                                     Lead_Receipt_Date__c = Date.today());
            convertedLeads.add(leadObj);
            caseObj.Status = 'Converted';
            cases.add(caseObj);
        }
        if(convertedLeads.size() > 0){
            try{
                insert convertedLeads;
                upsert cases;
            } catch(DmlException dml){
                throw dml;
            }
        }
        //Implement business logic
        return convertedLeads;
    //}
    }

    
    
}