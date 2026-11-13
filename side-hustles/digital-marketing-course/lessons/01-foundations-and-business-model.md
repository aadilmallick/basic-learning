# 1. Marketing foundations: build a business around a useful result

[Course home](../README.md) · [Next: customer research](02-customer-research-and-positioning.md)

## The problem marketing solves

Imagine that you have excellent notes on Kotlin coroutines. The explanations are accurate, the diagrams are clear, and the examples run. You publish a payment link. Almost nobody buys. That result does not yet tell you whether the notes are bad. Perhaps nobody found the link. Perhaps the people who found it already understand coroutines. Perhaps the right people found it but could not tell how your notes differ from free documentation. Perhaps they wanted guided practice rather than more reading.

Marketing is the work of understanding a buyer, designing an appropriate offer, communicating its value, making it accessible, and learning from the resulting behavior. Promotion is one part of that work. Posting more frequently only addresses some possible causes of weak sales.

This course assumes that you are a solo developer selling educational products, initially to individuals. You can adapt the examples to Python, databases, AI engineering, or another subject. The recurring product, **Coroutine Field Guide**, is fictional. All prices, conversion rates, dates, and customer results in worked examples are teaching assumptions, not observed market benchmarks or earnings predictions.

By the end of this lesson, you should understand the relationship between a product, an offer, a market, a channel, and a business model. You will also have a way to diagnose where a sales system is failing.

## Separate the product from the offer

A product is what you deliver. An offer is the complete proposition a buyer evaluates: the product, intended outcome, audience, price, format, support, limitations, and terms.

“Seventy pages of notes” describes a product. “A focused guide for working Kotlin developers who can launch coroutines but struggle to diagnose cancellation bugs, including five runnable debugging labs and worked explanations” describes an offer. The second version helps a buyer decide whether the material fits their situation. It does not need to promise instant expertise.

A market is the set of people and situations in which an exchange might occur. “Developers” is too broad to guide a first offer. A senior backend engineer preparing for an incident review has different needs from a student completing an introductory assignment. A channel is the route by which you reach people: search, a newsletter, LinkedIn, a partner workshop, or paid advertising.

The business model connects these elements to costs and revenue. A downloadable guide, a recorded course, a live cohort, and a team license can cover similar knowledge while producing very different support obligations and margins.

| Format | Buyer pays for | Main operating burden | Sensible first test |
| --- | --- | --- | --- |
| Notes or handbook | Convenient explanation and reference | Accuracy, updates, discoverability | A paid, tightly scoped guide |
| Recorded course | Demonstration and guided progression | Recording, lesson maintenance, access support | One complete short module |
| Live workshop | Scheduled help and feedback | Scheduling, preparation, delivery | One small session |
| Cohort course | Progress with a group and instructor | Feedback capacity and facilitation | A small pilot |
| Team license | Consistent learning across a team | Procurement, permissions, support | A clearly scoped team pilot |

There is no automatic ladder that requires every buyer to purchase each format. Someone may discover your guide through search and immediately buy a team workshop. Design for real needs rather than forcing everyone through a complicated funnel.

## Value starts with a change in the buyer's situation

The buyer is not purchasing your effort. They are deciding whether the expected improvement is worth the money, time, and risk. A useful conceptual model is:

**Perceived value = expected usefulness, adjusted for confidence, effort, and fit.**

This is a reasoning aid, not a measurable universal equation. It points to four questions. What will someone be able to do? Why should they believe you? What will they need to invest? Is this material appropriate for their current knowledge?

For the Field Guide, a credible outcome is: “After working through the cancellation chapter, you can trace parent-child cancellation and identify where a swallowed exception changes behavior.” An unreliable outcome is: “Master Kotlin and get a high-paying job this week.” The first is within the product's teaching scope. The second depends on many factors the product cannot control.

Useful differentiation can come from sequence, examples, diagnostics, portability, or a particular context. You do not need to discover a topic nobody has taught. You do need a reason for a specific person to choose your treatment.

Free documentation is a real alternative. So are a saved video playlist, a coworker, an AI assistant, and postponing the problem. Your offer should explain the additional utility it provides: curated progression, verified examples, consistent assumptions, or practice with explanations. Charging for publicly available facts does not remove the need to add value.

## Follow the customer's decision, not just the funnel diagram

A funnel is a simplified view of stages: discovery, consideration, purchase, use, and possible repeat purchase. Actual behavior loops. Someone may see a post, forget you, discover a search article, join your newsletter, and buy after trying a sample.

At each stage the buyer has a different uncertainty. Discovery asks, “Is this relevant?” Consideration asks, “Will it work for someone like me?” Purchase asks, “Can I trust the transaction and terms?” Use asks, “Where do I start?” Repeat purchase asks, “Did the previous experience justify trusting you again?”

Each uncertainty suggests an asset. A problem-specific tutorial establishes relevance. A representative sample demonstrates teaching quality. Clear checkout terms reduce transaction ambiguity. An onboarding email helps the buyer start. A follow-up that asks where they got stuck improves future material.

An asset has a job. A social post does not need to explain every refund condition. A checkout page should not hide delivery details behind motivational storytelling. When you know the uncertainty at a stage, you can choose what to explain there.

## Use unit economics before chasing volume

Revenue is money collected from sales before the relevant deductions. Profit depends on the costs you include. For marketing decisions, contribution is especially useful: the amount left after the variable costs associated with an order, before fixed costs and the creator's salary unless explicitly included.

Assume a $39 guide. For teaching purposes, suppose payment and platform costs total $3 per order, expected refund cost averages $2, and variable support averages $4. Contribution before acquisition is:

**$39 − $3 − $2 − $4 = $30 per order.**

These are invented costs. Replace them with your platform contract and actual observations. Taxes collected on behalf of a tax authority are not simply extra spendable product revenue. Detailed tax treatment depends on jurisdiction and arrangement; this course does not determine it.

If paid acquisition costs $20 per buyer, the example leaves $10 per order toward fixed costs and compensation. At $35 acquisition cost, it loses $5 before those fixed costs. A beautiful ad dashboard cannot change that arithmetic.

Your time matters even when the cash expense is zero. If you spend ten hours creating posts that generate four sales, that work may still be worthwhile as a learning investment. It is not evidence that the channel has no cost. Track both cash and hours so you can distinguish learning from sustainable operation.

Do not estimate profitability by assuming that every guide buyer will eventually purchase an expensive course. Repeat purchases become useful evidence only after you observe them over a defined period.

## Work backward from a modest goal

Suppose your planning goal is ten guide sales in a month. If an assumed 2% of qualified landing-page visits purchase, you need 500 such visits. The calculation is 10 ÷ 0.02. If an assumed 5% of relevant social impressions generate a page visit, that would require 10,000 impressions.

Neither rate is a forecast. Their purpose is to expose the assumptions hidden inside “I want ten sales.” If your actual click rate is 0.5%, the required exposure changes dramatically. Also, impressions are repeated exposures, not necessarily unique people. Keep the units visible.

Now compare two strategies. One produces many broad impressions with few relevant visits. The other produces fewer visits from a focused technical newsletter. The smaller audience may generate more sales because relevance and trust differ. You cannot choose solely from follower count.

A goal should include a customer outcome as well as a financial outcome. For an early pilot, you might want to learn whether buyers can complete one debugging lab, whether delivery works, and whether the promise accurately describes the material. Early customer success provides the foundation for later marketing.

## Diagnose the weakest transition

When sales disappoint, identify the broken transition before creating more content.

| Observation | Possible explanation | Useful next investigation |
| --- | --- | --- |
| Few relevant people encounter the offer | Distribution is too small or poorly targeted | Review where the intended buyer already looks for help |
| Relevant people see content but do not visit | Weak relevance, unclear next step, or enough value delivered already | Compare buyer questions with the post and destination |
| Visitors inspect the page but do not buy | Wrong offer, insufficient proof, price mismatch, or unclear terms | Watch voluntary feedback and interview nonbuyers |
| Checkout starts without completed payments | Technical failure, surprise costs, or missing payment method | Test checkout and examine aggregate failure information |
| Buyers request refunds | Poor fit, inaccurate promise, access problem, or weak product | Read the reason and inspect onboarding and content |
| Buyers succeed but sales remain small | Distribution constraint or narrow market | Test one additional relevant channel |

These are hypotheses, not conclusions. A low purchase rate could come from traffic that never belonged on the page. Rewriting the headline will not repair that mismatch.

## Choose a manageable first system

A solo creator needs a system they can operate repeatedly. For this course, begin with one buyer segment, one useful product, one primary discovery channel, one email list, and one straightforward checkout. You can add search and partnerships gradually. You do not need an affiliate program, a community, several social networks, and automated upsells before your first useful sale.

A practical first system might be: technical LinkedIn posts demonstrate one debugging concept; interested readers visit a sample chapter; subscribers receive the sample and a short teaching sequence; the paid guide is offered with clear prerequisites and terms; buyers get immediate access and a starting point.

Every additional component creates work and possible failure. Complexity becomes justified when it resolves an observed bottleneck. If readers repeatedly request video demonstrations, a companion workshop may help. If they are confused by the guide's scope, more products may make the confusion worse.

## Optional application: your one-page business hypothesis

Write a paragraph naming the buyer, recurring problem, trigger, proposed outcome, product format, price hypothesis, discovery channel, and biggest uncertainty. Use explicit language such as “I believe” where evidence is missing.

Example: “I believe working Kotlin developers facing cancellation bugs will pay for a focused debugging guide because collecting reliable examples currently takes them time. I will test a sample and a $39 guide through educational posts and an opt-in list. The largest uncertainty is whether they want a paid reference or feedback on their own code.”

An adequate first version is specific enough that evidence could contradict it. “Everyone wants to improve their coding” cannot guide a test. Save the hypothesis in the workbook; the next lesson teaches you how to investigate it.

The important shift is from publishing material and hoping to be noticed to designing a sequence of useful customer decisions. Marketing becomes easier to reason about when each asset serves a real uncertainty and each result can update a clear hypothesis.
