trigger AccountsTrigger on Account (before insert) {
    fflib_SObjectDomain.triggerHandler(Accounts.class);
}