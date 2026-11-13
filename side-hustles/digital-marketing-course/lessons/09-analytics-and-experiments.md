# 9. Analytics, attribution, and useful experiments

[Previous](08-email-and-customer-relationships.md) · [Course home](../README.md) · [Next: partnerships and ads](10-partnerships-affiliates-and-paid-acquisition.md)

## Measure a decision, not everything you can collect

A dashboard can contain dozens of numbers while leaving you unsure what to do. Analytics becomes useful when a question connects an observation to an action. “Are relevant visitors reaching the sample?” is a decision question. “Can I collect more events?” is not yet one.

For a small educational-products business, begin with a clear event path: relevant visit, sample request, confirmed subscription where applicable, product-page visit, checkout start, confirmed purchase, refund, and first useful product action. You do not need to observe every cursor movement to understand a broken download or a confusing offer.

This lesson assumes your offer and customer journey are defined. It teaches rate calculations, tracking design, attribution limits, contribution measurement, and experiment design for small audiences. All datasets are invented and included for practice, not evidence of expected performance.

## Define the units before calculating rates

A conversion rate is a count of successful actions divided by a defined count of opportunities. The units and time window matter. Ten purchases divided by 500 unique visitors is a visitor-to-purchase rate of 2%. Ten purchases divided by 700 sessions is a session-to-purchase rate of about 1.43%. Both calculations can be correct while answering different questions.

Do not mix impressions, clicks, sessions, people, and orders as if they were interchangeable. A person can create several impressions, click twice, and purchase once. A returning buyer can create multiple orders. Your denominator should match the decision you are evaluating.

For early reporting, write the definition beside each number. For example: “Purchase conversion: completed first guide orders divided by product-page sessions during the same reporting period.” That rate is still affected by returning visitors and delayed purchases, so be cautious when interpreting it causally.

Use cohorts for delayed behavior. A cohort is a group defined by a shared starting event, such as subscribing in a particular week. Measuring their purchases over a consistent follow-up window avoids comparing a new group with one that has had months to decide.

## Build a small event specification

| Event | Meaning | Useful fields | Important guardrail |
| --- | --- | --- | --- |
| Sample requested | Form accepted a request | Resource and acquisition context | Do not treat it as confirmed consent if another step is required |
| Subscription confirmed | Required confirmation completed | Signup cohort and declared interest | Preserve the actual consent context |
| Checkout started | Buyer entered payment flow | Product and offer version | A start is not a sale |
| Purchase confirmed | Payment system confirms the order | Unique order ID, amount, currency, product | Deduplicate repeated notifications |
| Refund recorded | A refund has been processed | Order ID, amount, reason category | Distinguish partial and full refunds |
| First-use reported | Buyer reports or system appropriately observes a meaningful start | Product and activity | Do not overstate learning from a page open |

Use appropriate aggregate measurement and avoid sending sensitive personal data into analytics tools. Do not put email addresses, passwords, or private support text in event names or URLs. The exact consent and privacy implementation depends on your audience and jurisdiction.

Payment records are the operational reference for whether a payment occurred. Marketing analytics may miss or duplicate browser events. Reconcile discrepancies rather than forcing the ledger to match the prettier dashboard.

## Use campaign links consistently

Campaign parameters help label how a visitor arrived. A simple example is:

```text
https://example.com/coroutine-guide?utm_source=linkedin&utm_medium=organic_social&utm_campaign=guide_pilot&utm_content=cancellation_demo
```

The source identifies the referring platform. The medium describes the channel type. The campaign groups a specific initiative. The content value distinguishes this creative asset. Google's URL-builder documentation explains these parameters and their case-sensitive values. See [R6](../SOURCES.md#r6-campaign-links).

Choose a consistent naming convention, such as lowercase with underscores, and keep a campaign register. If one link uses `LinkedIn` and another uses `linkedin`, reports can fragment. Do not use external campaign parameters on your own internal navigation as a substitute for event tracking; you can confuse how the journey is interpreted.

Test that redirects preserve the intended parameters and that your chosen analytics setup reads them. A parameter in a URL is only a label; it does not automatically create a functioning measurement system.

## Work through a complete funnel

Imagine 1,000 landing-page visitors from a defined campaign. Of these, 100 request a sample, 80 complete the required subscription confirmation, 20 begin checkout, and 12 purchase within the defined window.

The visitor-to-request rate is 100 ÷ 1,000 = 10%. Request-to-confirmation is 80 ÷ 100 = 80%. Visitor-to-purchase is 12 ÷ 1,000 = 1.2%. Checkout-start-to-purchase is 12 ÷ 20 = 60%.

You should not automatically multiply every rate as though every event belonged to one perfectly tracked linear journey. Some buyers may purchase without subscribing. Some may use another device. For this illustrative funnel, assume all counted purchasers followed the same path; a real implementation must check whether that assumption holds.

Where would you investigate first? A low confirmation rate suggests delivery or expectation issues. A low purchase rate among qualified visitors suggests fit, proof, or offer questions. A checkout gap suggests transaction friction or surprise. Rates tell you where to look; customer accounts and system tests help explain why.

## Connect acquisition to contribution

Suppose a campaign produces 12 orders at $39 each, giving $468 gross sales before relevant deductions. Using the simplified $30 contribution per order from Lesson 3 gives $360 contribution before acquisition. If the campaign cost $240, it leaves $120 before fixed costs and creator compensation not already included.

Customer acquisition cost, or CAC, is acquisition spend divided by acquired customers under a stated definition. Here, if all 12 orders represent new customers, CAC is $240 ÷ 12 = $20. If some orders came from existing customers, new-customer CAC requires a different denominator.

Return on ad spend, or ROAS, is attributed revenue divided by ad spend. Here it is $468 ÷ $240 = 1.95. A positive-looking ROAS does not prove profit because it omits other costs. If the product had only $12 contribution before acquisition per order, the same campaign would lose contribution after advertising.

Use consistent refund handling. You can begin with expected refund allowances, then replace them with realized outcomes for mature cohorts. Do not deduct both an allowance and the same actual refund without accounting for the overlap.

## Understand attribution as a model of credit

A person may discover you through LinkedIn, read a search article, join an email list, and buy through a direct visit. Different attribution models assign credit differently. Last-click reporting emphasizes the last observed interaction. Other models distribute credit across observed touchpoints.

Google's attribution documentation describes how reporting settings affect the assignment of credit for key events. See [R7](../SOURCES.md#r7-attribution). The selected model changes reporting; it does not reveal a uniquely true cause of every purchase.

Observed paths are incomplete because of cross-device behavior, privacy controls, untagged links, private sharing, and offline influence. A buyer's optional answer to “Where did you first hear about this?” can add context, but memory is also imperfect.

Avoid summing each platform's claimed purchases as though they were distinct orders. Several systems may claim the same buyer under different windows. Reconcile at the order level where appropriate and permitted, while acknowledging the limits of causal explanation.

## Design an experiment around one uncertainty

An experiment needs a hypothesis, a change, an outcome, guardrails, and a decision rule. For example: “Showing the full sample above the pricing section will help qualified visitors judge fit, increasing completed purchases without increasing refunds.”

A randomized A/B test assigns comparable visitors to variants during the same period. This reduces some confounding factors. It does not automatically fix bad measurement, insufficient sample size, or multiple simultaneous changes.

A before-and-after comparison is weaker because traffic mix, seasonality, and audience familiarity may change. You can still use it for learning if you label its limits. Do not call a sequential comparison a controlled experiment simply because it contains two screenshots.

Change the variable that addresses the uncertainty. If readers misunderstand prerequisites, clarify them and inspect fit and refund outcomes. Testing button colors will not answer whether the offer solves the right problem.

## Learn from small samples honestly

Suppose variant A receives 100 visits and two purchases, while B receives 100 visits and three purchases. B's observed rate is 3% compared with A's 2%, a relative difference of 50%. Yet the absolute difference is one purchase. Sampling variation can easily dominate such a small comparison.

For a rough illustration, the standard error of a proportion can be approximated by the square root of p(1−p)/n when conditions support that approximation. With p = 0.02 and n = 100, it is about 0.014, or 1.4 percentage points. At very small counts, normal approximations are unreliable; the calculation here illustrates instability rather than providing a significance test.

Do not stop a test every time one variant temporarily leads. Repeated peeking and selectively reporting winners can produce misleading conclusions. If you need formal statistical testing, define the design and analysis in advance with an appropriate method and enough data.

For a small business, qualitative comprehension tests, purchase interviews, and fixing obvious technical failures may be more useful than a long series of underpowered A/B tests. You can improve a broken checkout without proving its repair through a marketing experiment.

## Use a weekly decision review

Review a compact dashboard: qualified visits by source, confirmed subscriptions, new customers, gross sales, refunds, contribution, cash acquisition spend, time invested, and recurring customer issues. Compare consistent periods and explain unusual changes.

Write one interpretation with uncertainty: “Search visits increased, but they came mainly to a beginner article outside the guide's intended level.” Then choose an action: improve the article's next step, clarify fit, or create a relevant foundational offer later. Do not respond by celebrating raw traffic alone.

Keep a decision log with hypothesis, evidence, action, and follow-up date. This is not bureaucracy for its own sake. It prevents you from forgetting why you changed the price or mistaking an old assumption for an established fact.

## Optional application: make a measurement plan

Use the workbook's event plan, campaign register, and unit-economics fields. Define one cohort and a purchase window. Run a test transaction through your own setup and inspect whether the order is counted once. Work through the supplied fictional campaign dataset and compare contribution, not only ROAS.

Good measurement makes uncertainty more visible and decisions more specific. It does not remove the need for judgment, customer conversations, or useful products.
