# 8. Email, lead magnets, and customer relationships

[Previous](07-seo-and-evergreen-discovery.md) · [Course home](../README.md) · [Next: analytics](09-analytics-and-experiments.md)

## Replace a fleeting encounter with a useful relationship

A developer may like an explanation today and need the full guide weeks later. Email can provide a voluntary way to continue the relationship. It gives you a direct communication path while still depending on the subscriber's permission, mailbox systems, and your provider's reliability.

An email list is not an audience you own in the sense of controlling people. Subscribers can leave. Your job is to earn continued attention by delivering what they expected and making it easy to stop.

This lesson assumes that you have a useful sample, an offer, and a way to accept subscriptions. It teaches lead magnets, welcome sequences, segmentation, deliverability, and lifecycle communication. The compliance section is U.S.-oriented and introductory; other jurisdictions can impose additional requirements.

## Choose a lead magnet that reveals product fit

A lead magnet is a useful resource offered in exchange for an appropriate next relationship, often an email subscription. Its purpose is not merely to maximize addresses. It should attract people who have the problem your paid product solves.

For a coroutine guide, a representative chapter or a small diagnostic worksheet has close fit. A giant list of unrelated developer tools may attract more people while providing little evidence that they want this guide. A prize giveaway can be even less informative because the incentive dominates the product interest.

The resource should produce a small, complete result. A sample that introduces a problem but hides every explanation creates frustration. A chapter that demonstrates your teaching lets the reader evaluate fit and gives you a natural basis for explaining the full sequence.

State the exchange clearly. If the form subscribes people to an ongoing newsletter as well as delivering a sample, say that near the form. Do not describe the action as “download only” and silently add a promotional sequence. Where separate consent or other requirements apply, implement them appropriately.

## Build the subscription experience

The page should explain who the resource is for, what it contains, how it is delivered, and what further email to expect. Ask only for information you need. An email address may be enough; extra fields create friction and data-handling work.

After submission, show a useful confirmation. If confirmation by email is required, explain that the subscriber must take that step. If the download is immediately available, show the link and also deliver it by the promised route. Avoid leaving the person wondering whether the form worked.

Test the sequence with an address you control. Verify that the resource arrives, the links work, the sender is recognizable, and unsubscribe behavior works. A form-success message is not evidence that the email reached an inbox.

Store the source, time, and relevant subscription context so you can understand what people requested. You do not need invasive profiling. A simple record that someone subscribed through the cancellation sample can help you send relevant material and resolve later questions.

## Teach through a short welcome sequence

A welcome sequence can deliver the resource, reinforce a useful concept, address a common obstacle, and explain the paid option. Its length and spacing depend on what you promised and what readers find helpful. More automated messages do not automatically create more trust.

Here is an illustrative sequence. The intervals are a starting editorial plan, not a performance benchmark.

| Message | Purpose | Useful content | Next step |
| --- | --- | --- | --- |
| Immediately after confirmed subscription | Fulfill the request | Sample link and a clear starting point | Read the first example |
| A few days later | Improve sample use | Explain one frequent confusion | Try or inspect the worked variation |
| Later in the first week | Show the broader learning path | Explain how chapters connect | View contents and prerequisites |
| After useful context | Present the offer | Price, scope, sample reminder, terms | Buy if the fit is right |
| Following week | Learn and continue | Ask what remains confusing | Reply voluntarily |

Do not put buyers into a sequence that keeps urging them to buy the same item. Purchase status and newsletter consent are different dimensions. Stop inappropriate sales messages while preserving communications the buyer still expects.

## Write an email that fulfills one job

A good email can be short because its context is clear. The delivery message might say:

> Subject: Your coroutine cancellation sample
>
> Here is the sample you requested. Start with the ownership diagram, then follow the code and expected logs. The example assumes basic Kotlin and introductory coroutine usage.
>
> If a step is unclear, you can reply and tell me where you got stuck. The following emails will explain a few related concepts and show how the full guide extends the sample, as described on the signup page.

This draft needs the actual resource link, accurate schedule language, sender details, and applicable footer before use. It illustrates tone and purpose rather than a complete compliance-ready campaign.

For an offer email, say what is available, who it fits, what it includes, what it costs, and where to inspect the terms. Do not disguise a sales message as an account-security notice or a personal emergency. The subject should accurately represent the content.

## Segment by useful context

Segmentation means sending different relevant messages to different groups. Early useful segments include sample subscribers, guide buyers, workshop attendees, and people who specifically requested future course news. Avoid creating dozens of categories before you have a reason to use them.

A behavior does not always mean what you think. An email open can be affected by privacy systems and automated image loading. A click can be generated by a security scanner. A reply or purchase is often stronger evidence of human intent, though still requiring context.

Use tags for observable facts such as “purchased guide” or “requested workshop information.” Keep speculative labels such as “high-value prospect” from becoming a substitute for actual conversation. If you ask about interests, make the question optional and explain its purpose.

A sensible automation rule is “When a confirmed guide purchase occurs, remove the buyer from the guide-promotion sequence and deliver onboarding.” A poor rule is “When anyone opens three messages, pressure them with a fake expiring discount.”

## Understand deliverability at a practical level

Delivery means a receiving system accepted a message. Inbox placement is a separate matter. Authentication helps receiving systems evaluate whether the sender is authorized. Relevant content, healthy sending behavior, and complaint rates also matter.

SPF authorizes sending infrastructure, DKIM adds a verifiable signature, and DMARC builds on authentication and domain alignment. Use your provider's exact setup instructions; arbitrary DNS edits can disrupt existing mail. Google's current guidance distinguishes general senders from bulk senders and adds requirements for the latter, including authentication and one-click unsubscribe for applicable messages. See [R3](../SOURCES.md#r3-email-delivery).

Do not treat authentication as permission to send unwanted messages. Avoid purchased lists, remove hard bounces through your provider's supported process, and respect unsubscribe requests. Investigate sudden delivery problems before increasing volume. A plain email can be effective, but plain formatting alone does not guarantee inbox placement.

Before choosing a provider, verify export capability, authentication support, unsubscribe management, suppression behavior, privacy terms, and the features you actually need. Compare current official terms rather than relying on this course for a fixed vendor ranking.

## Understand the legal floor and the relationship standard

The FTC's CAN-SPAM guide covers commercial email, including B2B messages. Its requirements include accurate headers and subjects, clear advertising identification, a valid postal address, a clear opt-out, and honoring opt-outs within ten business days. An opt-out mechanism must work for at least thirty days after sending. Using a vendor does not remove your responsibility. See [R5](../SOURCES.md#r5-commercial-email).

That brief summary is not a complete compliance determination. Consent requirements vary by jurisdiction and context. This course uses explicit opt-in as an operating approach; do not assume that meeting a U.S. minimum automatically permits a global campaign. Check the requirements that apply to your actual subscribers and selling arrangement.

Separate genuine transaction messages from promotional mail. A download receipt serves an existing purchase. Adding substantial promotion may change how a message should be handled. Do not evade marketing opt-outs by relabeling promotions as essential account notices.

Keep a working suppression mechanism so unsubscribed addresses are not accidentally reimported into promotional lists. Minimize retained data and document why it is needed. The precise implementation depends on your provider and applicable obligations.

## Build onboarding and follow-up

A sale starts the product experience. Send the buyer a clear access path, the recommended first step, prerequisites, and the support route you actually provide. If the product requires setup, explain how to verify that setup before starting the lesson.

A useful follow-up asks whether access worked and whether a specific chapter was confusing. It should not demand a positive review. If you request feedback, distinguish private product feedback from permission to publish a testimonial.

When buyers encounter a repeated problem, update the product, onboarding, or sales page. Email is valuable because it can reveal where expectations and experience diverge. An increasingly elaborate automation sequence is less valuable than fixing the underlying mismatch.

Repeat offers should connect to a real next need. A guide buyer who asks for live practice may welcome a workshop invitation. Someone who has not opened the guide may need a better starting point rather than a more expensive course.

## Measure the relationship

Track confirmed subscriptions, resource access when appropriately measurable, replies, unsubscribes, complaints, purchases, and customer outcomes. Open rates are an imperfect directional signal. They are not a reliable count of attentive readers.

Calculate sequence purchase rate using a clearly defined cohort and window. If 100 confirmed sample subscribers enter in one month and six purchase within thirty days, the observed rate is 6%. It does not predict that the next hundred will behave identically, especially if their acquisition source differs.

If many people unsubscribe immediately, inspect whether the form set accurate expectations. If they remain but never use the sample, inspect delivery and usefulness. If they engage with teaching but do not purchase, inspect fit, offer, evidence, and timing before sending more reminders.

## Optional application: test the complete lifecycle

Create a sample signup page, a delivery email, two teaching messages, a clear offer email, and buyer onboarding. Test every branch with addresses and transactions you control. Verify opt-in context, delivery links, buyer exclusion, and unsubscribe behavior. Keep the drafts in the workbook until the real terms and system settings are ready.

The objective is a useful, voluntary relationship that supports learning and informed purchasing. Automation should make that relationship more reliable, not substitute for it.
