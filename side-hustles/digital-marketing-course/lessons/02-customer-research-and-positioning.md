# 2. Customer research, niche selection, and positioning

[Previous](01-foundations-and-business-model.md) · [Course home](../README.md) · [Next: offers and pricing](03-products-offers-and-pricing.md)

## Start with a situation you can investigate

The first lesson gave you a business hypothesis. This lesson replaces vague assumptions with evidence. You do not need a large research department. You need disciplined observation, conversations about actual behavior, and a clear distinction between what people say and what they do.

Consider three potential buyers for coroutine material. A student wants to pass an assignment. A working Android developer needs to stop accidental duplicate requests. A team lead wants consistent concurrency practices across a codebase. They may use the same vocabulary but buy different solutions. The student might want a low-cost explanation. The developer might value a debugging lab. The lead might prefer training and reusable review checklists.

A niche is a focused group of needs you choose to serve. It is not merely a topic tag. “Kotlin” names a subject. “Kotlin developers who understand suspend functions but struggle to reason about structured concurrency in production code” describes a situation that can guide product design.

By the end of this lesson, you will be able to select an initial segment, conduct useful interviews, compare alternatives, and write a positioning statement whose claims can be supported.

## Choose a niche using constraints, not excitement alone

Start with problems you can teach accurately. Then examine urgency, recurrence, access to buyers, existing alternatives, and the cost of serving the segment. Your personal interest matters because you will spend time answering questions and maintaining examples. It does not prove demand.

A student audience may be easy to reach but have limited purchasing power. Senior engineers may have purchasing power but expect precision, current examples, and strong evidence. Teams can support larger contracts while requiring procurement, licensing clarity, and scheduled delivery. Each market contains tradeoffs.

You can compare candidates with a decision table. Avoid treating the scores as scientific market measurements.

| Candidate | Urgent situation | Existing evidence to collect | Access route | Delivery risk |
| --- | --- | --- | --- | --- |
| Beginner coding notes | Confusing first projects | Repeated beginner questions | Learning groups | Wide prerequisite gaps |
| Intermediate debugging guide | A recurring practical bug | Recent debugging stories | Technical posts and peers | Accuracy and version assumptions |
| Interview course | A scheduled interview | Preparation behavior and purchases | Career communities | Pressure to overpromise outcomes |
| Team training | Inconsistent implementation | Manager accounts of team friction | Professional network | Custom support and scheduling |

Choose the candidate for which you can collect meaningful evidence with the least unnecessary work. Narrowness is useful when it improves learning. It becomes harmful when you define a segment so precisely that nobody describes themselves that way or you cannot find enough relevant people.

## Distinguish a problem, a solution request, and a purchase

“I wish someone made a course about this” is a solution request. It may indicate interest. It does not reveal what the person tried, how painful the issue was, or whether they would pay.

A problem account is more informative: “Last week I spent three hours figuring out why a child coroutine stopped. I searched documentation and copied examples, but could not tell which exception propagated.” That story identifies context, cost, alternatives, and a possible teaching gap.

A purchase or meaningful commitment is stronger evidence of willingness to pay than a compliment. It still has limits. A friend may buy to support you. A discount may attract people who would not buy at the intended price. A few pilot sales demonstrate feasibility, not the size of an entire market.

Keep an evidence ladder in mind: repeated observed problems; people investing time in solutions; specific requests to be notified; use of a representative sample; payment under clear terms; successful use; repeat or referral behavior. The ladder helps you decide what a signal supports without dismissing early qualitative evidence.

## Find evidence where the problem occurs

Look at public questions, issue discussions, tutorial comments, course reviews, support requests you are permitted to examine, and conversations with relevant developers. Search for confusion, failed attempts, workarounds, and triggers. A large number of generic likes is weaker than several detailed descriptions of the same blocker.

Record the source, date, exact context, paraphrase, and your interpretation separately. A useful row might say: “Public discussion about cancellation; writer says try/catch did not behave as expected; interpretation: may need exception propagation examples.” The interpretation is yours. Do not present it as the writer's stated intention to buy.

Use public material responsibly. Do not copy private conversations into marketing or publish identifiable customer details without permission. For research notes, minimize personal data. If you quote someone publicly, obtain appropriate permission and preserve the meaning. Your own paraphrase of a recurring theme is often sufficient for internal decision making.

Read negative reviews of competing products for missing outcomes. “Too basic” might reveal a segment mismatch. “Examples did not run” points to execution quality. “Too much content” can indicate poor navigation rather than a need for even more lessons. A single review is one experience; look for patterns before changing direction.

## Interview for past behavior

A helpful interview feels like careful curiosity, not a sales interrogation. Tell the person you are researching how developers learn and that you are not promising a solution. Ask permission before recording. If recording is unnecessary, take brief notes instead.

Begin with a recent event: “Tell me about the last time coroutine behavior surprised you.” Follow the story. “What were you trying to build?” “Where did you get stuck?” “What did you try next?” “What made that explanation insufficient?” “How did you eventually resolve it?” “Have you paid for help with a similar problem?”

Do not ask only, “Would you buy my amazing guide for $39?” That question invites politeness and speculation. If you want pricing evidence, ask about previous purchases and what made them worthwhile. Later you can show a concrete offer and allow an actual decision under clear terms.

A hypothetical exchange illustrates the difference:

> Researcher: What was difficult about the cancellation bug?
>
> Developer: I did not know which scope owned the operation.
>
> Researcher: What did you do when you noticed that?
>
> Developer: I added logs and looked for scope diagrams. The examples were too small to match our repository.
>
> Researcher: What would a useful explanation have needed to show?
>
> Developer: A small application with a screen closing while work was running.

The useful insight is not merely “people want diagrams.” It is that the learner needs to connect ownership to application lifecycle behavior. This could change the product's examples, sample chapter, and sales copy.

## Synthesize without pretending the sample is representative

After several conversations, group observations by trigger, desired progress, current alternative, obstacle, and evidence strength. A small number of interviews can reveal useful language and failure modes. It cannot justify claims such as “70% of all Kotlin developers want this” unless your sampling and analysis actually support that inference.

Suppose five of eight interviewees mention cancellation, three mention testing, and two mention scheduling. You can conclude that cancellation was common in this group. You cannot conclude it is the largest need in the entire Kotlin market. Use it as a product hypothesis and test with a representative sample offer.

Write a synthesis in plain language: “The working developers we spoke to could follow toy examples but struggled when lifecycles overlapped. Their main alternative was collecting multiple explanations and testing code themselves.” Then record dissent: “Two developers preferred official documentation and did not want paid material.” Dissent prevents selective listening.

Do not merge incompatible segments into an average buyer. A beginner who wants more prerequisite teaching and an experienced engineer who wants less may both be right. Separate products or clearer prerequisites may solve the conflict better than a course that tries to satisfy everyone.

## Map direct and indirect competitors

A competitor is any alternative the buyer can use to make progress. Direct alternatives include other guides and courses. Indirect alternatives include official documentation, open-source examples, mentoring, AI assistance, and doing nothing.

Compare the decision dimensions a buyer actually uses: prerequisite level, scope, example quality, maintenance, format, support, portability, and price. Do not invent weaknesses or claim superiority you have not established. You can differentiate honestly by saying, “This guide concentrates on cancellation and exceptions rather than the entire language.”

A positioning map with two axes can be useful, but only if the axes affect purchase decisions. “Playful versus serious” may matter less than “quick reference versus guided practice” and “beginner versus experienced.” A table often conveys the choice more clearly than a decorative chart.

Your advantage might be unusually strong explanations, a focused domain, real debugging cases, or a particular sequence. “More pages” is fragile differentiation because length can increase reading burden. “Everything you ever need” creates expectations that are hard to fulfill and maintain.

## Turn findings into positioning

Positioning explains who the offer is for, the situation it addresses, the relevant alternative, and the useful difference. It guides the product before it becomes a headline.

A working statement might be:

> For Kotlin developers who can use basic coroutines but lose confidence when cancellation and exceptions interact, Coroutine Field Guide offers a sequence of runnable debugging labs and explanations. It is designed for learning practical reasoning through small application cases rather than collecting unrelated snippets. It assumes familiarity with functions, exceptions, and basic coroutine builders.

This statement is deliberately specific. It avoids a ranking claim such as “the world's best course.” It tells a beginner what prerequisites to acquire. It tells an experienced developer what gap the guide addresses.

Now translate the statement into customer-facing language: “Understand which coroutine gets cancelled, why the exception travels, and how to diagnose the behavior in a small working application.” Before using it, verify that the product actually teaches those tasks.

## Validate the message before expanding the product

Show a draft page and sample to relevant people. Ask them to explain, in their own words, who it is for, what it contains, and what they expect after using it. This is a comprehension test, not a request for praise.

If readers expect an interview-preparation course while you intend a debugging reference, the message is failing even if they say it looks attractive. If the sample feels much more advanced than the page implies, fix the prerequisite statement or sample. If people understand the offer and choose an alternative, ask about that decision without arguing.

A useful research artifact contains the segment, three recurring problem accounts, current alternatives, an explicit uncertainty, a positioning statement, and the next low-cost test. The workbook includes a template.

## Optional application: a focused research sprint

Over one or two weeks, gather a small collection of public problem accounts, invite several relevant people to talk, and compare a handful of direct and indirect alternatives. The numbers are planning suggestions, not a research-validity threshold.

Write one page that separates observations, interpretations, and decisions. End with one concrete adjustment: narrower prerequisites, a different first chapter, a sample debugging exercise, or a change of audience. Research becomes useful when it changes a decision. Continually collecting opinions without changing or testing anything can become a way to postpone selling.

A strong niche is a place where you understand the problem, can reach the people experiencing it, and can deliver useful progress with sustainable effort. The next lesson turns that understanding into an offer you can responsibly price and deliver.
