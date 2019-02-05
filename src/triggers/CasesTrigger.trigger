trigger CasesTrigger on Case (before insert) {
    fflib_SObjectDomain.triggerHandler(Cases.class);
}