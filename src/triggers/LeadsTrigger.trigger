trigger LeadsTrigger on Lead (before insert) {
    fflib_SObjectDomain.triggerHandler(Leads.class);
}