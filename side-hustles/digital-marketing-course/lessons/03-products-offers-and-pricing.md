# 3. Product design, offers, pricing, and sustainable economics

[Previous](02-customer-research-and-positioning.md) · [Course home](../README.md) · [Next: copy and sales pages](04-copywriting-and-sales-pages.md)

## Make a product that earns its promise

Customer research identifies a desired change. Product design determines how you help produce it. If people want to debug cancellation, a folder containing every note you have ever written may not help. They need a starting point, a sequence, appropriate examples, and a way to recognize correct reasoning.

The product should be an efficient path to a bounded outcome. A coding guide might teach one concept, demonstrate a mistake, explain the correction, and provide a reference page for later use. A course might add screen recordings and worked projects. Neither format needs to claim that passive consumption produces expertise.

This lesson assumes that you have selected a buyer segment and written a positioning hypothesis. You will now define a minimum sellable product, distinguish valuable scope from decorative bonuses, choose a price hypothesis, and calculate what different distribution options can afford.

## Design backward from an observable task

Begin with a task the learner should be able to perform. For Coroutine Field Guide, choose: “Trace cancellation and exception propagation in a small application and explain the resulting logs.” That is more useful than “understand coroutines,” because you can inspect whether the material supports it.

List the prerequisites: basic Kotlin syntax, functions, exceptions, and introductory coroutine usage. Then identify the explanation sequence: job hierarchy, scope ownership, cancellation, exception propagation, diagnostic logging, and realistic application cases. The learner should not encounter a difficult interaction before the component concepts are explained.

Now define product evidence. Include a sample lab, expected output, explanation of why the output occurs, and common variations. The buyer can inspect a sample before purchase, and the learner can use the explanation after purchase. The same well-designed asset improves both marketing and teaching.

A minimum sellable product is the smallest complete experience that responsibly fulfills the stated promise. It differs from a teaser. If you sell a guide to cancellation debugging, the paid guide must actually teach that task. Selling an outline as a complete course is an inaccurate description, regardless of how early the business is.

## Convert personal notes into a buyer-ready guide

Your own notes contain assumptions you no longer notice. You may write “scope handles this” because the surrounding course explained ownership. A new reader does not have that context. Prepare notes for another person through an editorial process.

First, remove dependencies on the order in which you happened to learn. Put prerequisite concepts before advanced uses. Second, explain the reasoning between code samples. Third, make setup assumptions explicit. Fourth, verify examples and label version-sensitive behavior. Fifth, add navigation so the buyer can find a concept without rereading everything.

Finally, distinguish reference content from guided instruction. A two-page comparison table is useful during work. A careful derivation is useful while learning. A good guide can contain both, but they should be labeled so the reader knows which path to take.

Do not reuse material you lack rights to sell. Your original explanation of a public concept differs from copying someone else's course transcript, diagrams, or paid examples. Check permissions for third-party code, illustrations, and quotations. If ownership is unclear, replace the asset with your own work or obtain appropriate permission. This course does not determine the legal status of a particular source.

## Choose format by learning need and operating capacity

A PDF or Markdown guide is easy to search and update. Video can reveal editing, debugging, and thought processes. A workshop creates a scheduled opportunity to ask questions. A community may offer ongoing help, but it also creates moderation and response expectations.

The right question is not “Which format looks most valuable?” Ask “What does the learner need to observe or do, and what can I reliably deliver?” A ten-minute video showing a debugger may add more value than hours of narrated slides. A precise written diagram may be easier to revisit than a long recording.

Start with a complete narrow offer and expand when evidence supports expansion. If several buyers struggle with the same exercise, improve the exercise explanation before assuming you need an expensive new course. If buyers repeatedly ask for live review, test a workshop with limited, real capacity.

Define the maintenance promise before selling. “Includes updates to this edition for twelve months” is bounded. “All future updates forever” creates an obligation whose cost is difficult to predict. Describe file formats, access duration, download rights, and support channels in language a buyer can understand.

## Build bundles around related needs

A bundle should reduce a useful problem, not inflate a perceived discount. Suppose the guide costs $39 and a separate recorded debugging workshop costs $79. A $99 bundle may make sense for someone who wants both reading and demonstrations. It does not become valuable because you assign arbitrary dollar values to twenty extra downloads.

A tier comparison should make differences concrete:

| Hypothetical offer | Included | Excluded | Capacity implication |
| --- | --- | --- | --- |
| Guide | Downloadable handbook and labs | Individual code review | Low variable delivery cost |
| Guide plus workshop recording | Guide and a worked demonstration | Live questions | Additional production and updates |
| Small live workshop | Guide, live session, stated Q&A | Ongoing private mentorship | Real seat and time limits |
| Team pilot | Agreed seats and defined session | Unlimited company access | Licensing and coordination |

These are examples, not recommended price points for every creator. A tier is useful when it serves a genuinely different need. If buyers cannot explain why they would choose each tier, simplify the offer.

## Understand three pricing lenses

Cost-based thinking asks what delivery costs and what margin remains. It prevents obviously unsustainable offers but does not reveal customer demand. Value-based thinking asks what improvement matters to the buyer. It helps frame relevance but does not justify unsupported earnings claims. Alternative-based thinking asks what the buyer could do instead. It anchors comparison but can encourage imitation if used alone.

Use all three. Your guide may cost little to distribute but require extensive maintenance. The buyer may value reduced confusion but still prefer free documentation. Competitors may charge more because they include live feedback you do not offer.

A starting price is a hypothesis. To refine it, examine purchase decisions, refund reasons, usage, and qualitative feedback. A low price can reduce purchase friction while attracting poorly matched buyers or making support unaffordable. A high price can support more service while requiring stronger evidence and clearer differentiation.

Avoid fake precision. You cannot derive the perfect price from one interview or a universal formula. Pricing involves uncertainty and positioning. The responsible approach is to make a coherent offer, observe actual decisions, and change one material variable at a time where practical.

## Work through the economics carefully

Assume a guide is sold for $39 before applicable tax. For illustration, variable costs per order are $3 in payment/platform costs, $2 in expected refunds, and $4 in support. The support cost could represent ten minutes valued at $24 per hour. The result is $30 contribution before acquisition.

Expected refund cost is an average allowance, not a statement that each order receives a $2 refund. For example, a portion of orders receiving full refunds can produce an average expected deduction. In a real model, avoid counting the same refund twice when calculating net receipts and contribution.

Suppose fixed production and setup costs are $600 in cash. With no acquisition cost, the simplified cash break-even is $600 ÷ $30 = 20 orders. If acquisition costs $15 per order, contribution after acquisition becomes $15, and the same cash break-even requires 40 orders. If you also want to recover 60 hours of creation time valued at $30, the allocated cost rises by $1,800. Under the $15 contribution assumption, recovering the combined $2,400 requires 160 orders.

The purpose is not to scare you away from creating. It is to separate three goals: validating demand, recovering cash, and earning sustainable compensation. A project can accomplish the first before it accomplishes the others.

## Compare price changes using contribution, not conversion alone

Imagine 1,000 qualified visits. Offer A costs $39 and converts 2%, producing 20 orders and $780 gross sales. If contribution before acquisition is $30, it generates $600 contribution. Offer B costs $59 and converts 1.5%, producing 15 orders and $885 gross sales. Suppose its contribution is $48; it generates $720.

The higher price can produce more contribution despite a lower purchase rate. But the comparison is valid only if the audiences, time periods, offer details, refund behavior, and delivery burden are sufficiently comparable. A launch email to loyal subscribers and an ad to strangers are not a controlled price test.

Also examine customer outcomes. A premium tier that raises revenue but creates unmanageable support is not automatically better. A discount that attracts buyers who never use the product may reduce long-term trust and referral potential.

For small audiences, carefully recorded qualitative price conversations may be more useful than pretending a handful of sales creates a statistically stable optimum. You will learn experiment design later in the course.

## Use pilots and preorders transparently

A pilot lets you test the complete experience with a limited group. A preorder sells future delivery. Each requires clarity about what exists, what remains unfinished, the expected delivery schedule, and what happens if delivery changes.

For a hypothetical workshop pilot, you might offer one session with a fixed agenda, stated prerequisites, a maximum number of participants based on your actual capacity, and clear cancellation terms. That creates meaningful evidence while limiting commitments.

Do not call a preorder an immediately available course. Do not invent a countdown or pretend a downloadable guide is nearly out of stock. A genuine cohort deadline can be useful because preparation and feedback capacity are real constraints. An evergreen file does not have the same constraint.

Before accepting money, verify the relevant platform's terms, payment process, refund mechanism, delivery process, and obligations for your selling arrangement. Exact tax, consumer-rights, and international requirements are outside this general course; investigate the jurisdictions you actually serve.

## Write an offer specification

An offer specification is an internal agreement with yourself. It names the buyer, problem, learning outcome, prerequisites, included assets, exclusions, price, delivery, access period, update policy, support scope, and refund terms. It should also list evidence supporting the promise and uncertainties still being tested.

For example, “Guide buyers receive the current PDF and lab files immediately after confirmed payment. This edition explains cancellation and exceptions with runnable examples. It does not include individualized review of a production repository.” Such boundaries prevent accidental promises when you later write copy.

If a support promise creates eight hours of work for each $39 sale, the problem is in offer design. Better sales copy cannot repair the economics. Narrow the support scope, raise the price for the service component, or deliver help in a shared format that genuinely meets the need.

## Optional application: create the smallest credible offer

Select one learner outcome and build its first complete instructional path. Write the offer specification using the workbook. Calculate contribution with your actual expected costs and a separate line for your time. Identify the assumption most likely to make the offer unsustainable.

A useful result is an offer that can be described accurately, demonstrated through a sample, delivered reliably, and evaluated through buyer use. The next lesson teaches you to communicate that offer without hiding behind vague benefits or exaggerated promises.
