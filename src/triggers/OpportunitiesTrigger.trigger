trigger OpportunitiesTrigger on Opportunity (before insert) {
	fflib_SObjectDomain.triggerHandler(Opportunities.class);
}