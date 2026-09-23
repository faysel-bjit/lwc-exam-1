public with sharing class ForecastManagerController {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpenPipelineOpportunities() {

        try {
            return [
                SELECT Id, Name, Amount, Probability, Expected_Revenue_Overridden__c
                FROM Opportunity
                WHERE CloseDate = THIS_MONTH
                AND StageName NOT IN (
                    'Proposal/Price Quote',
                    'Negotiation/Review',
                    'Closed Won',
                    'Closed Lost'
                )
                WITH USER_MODE
                ORDER BY CloseDate ASC, Name ASC
            ];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void setExpectedRevenue(Id opportunityId) {
        try {
            Opportunity opp = [
                SELECT Id, Amount, Probability
                FROM Opportunity
                WHERE Id = :opportunityId
                WITH USER_MODE
                LIMIT 1
            ];

            Decimal expectedRevenue;

            if (opp.Amount != null
                && opp.Amount > 2000000
                && opp.Probability != null
                && opp.Probability > 50) {

                expectedRevenue = opp.Amount * 0.15;

            } else {
                expectedRevenue = opp.Amount * 0.10;
            }

            opp.Expected_Revenue_Overridden__c = expectedRevenue;

            update opp;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}