# 3. Turn conversations into scoped, profitable engagements

[Previous: client pipeline](02-build-your-own-client-pipeline.md) · [Guide home](README.md) · [Next: delivery, tools, and growth](04-delivery-modern-tools-and-repeat-business.md)

## Why a good conversation is not yet a project

A prospect may like your demo, praise your background, and still have no urgent reason or authority to buy. The purpose of sales is to determine whether there is a useful exchange to make, then make that exchange clear. For your services, this means understanding a workflow, agreeing on a deliverable, allocating the risks, and securing the commercial commitment before you reserve substantial delivery time. Confidence comes from clarity, not from memorizing closing tricks.

The fictional customer Cedar Learning will help connect the steps. Its coordinators collect approved lesson resources, annotate them, and create a weekly export. The owner asks whether you can “build an extension like your bookmarker, but for our team.” That sentence is an opening, not a specification. You do not yet know whether the system is installable, whether sharing is required, which pages are involved, or whether an existing tool already solves the task. Your next job is to reduce those unknowns in a proportionate way.

This chapter gives commercial design principles and editable business examples. It does not establish legal enforceability, your tax situation, or the right contractual terms for every jurisdiction. Use the official sources in the references for US outreach and tax basics, and obtain qualified advice for an actual contract or tax decision where needed. The point is practical preparation: you should be able to have an informed conversation and identify unresolved terms before the work begins, rather than treating a generic template as automatic protection.

## Separate fit, discovery, and solution design

A fit conversation establishes whether further investigation makes sense. Keep it short and focused. Ask what the person wants to change, who uses the workflow, what happens today, why it matters now, and who will decide. You can explain your relevant experience and how you work. You do not need to debug their repository or design an entire architecture on the call. A useful conclusion is either a small next step or a clear decision that the engagement is unsuitable.

Discovery investigates enough detail to scope the result. It may include observing a workflow, inspecting approved sample data, reviewing a repository, checking API constraints, and documenting acceptance examples. Discovery can be free when it is genuinely small and part of ordinary quoting. When substantial investigation creates a useful decision document, sell it as a bounded paid service. Explain exactly what the customer receives and that implementation is optional. Do not hide a basic sales estimate behind a mandatory consulting fee without giving independent value.

Solution design chooses how to meet the agreed requirement. Some design belongs in discovery, especially when feasibility is uncertain. Detailed implementation can follow after the scope is approved. This separation prevents a common mistake: spending several unpaid evenings solving the project in order to write a proposal, then feeling obliged to win it at any price. Your professional obligation is to understand enough to make an honest offer, not to deliver the entire solution before the customer commits.

## Run a fit call with a decision at the end

Open by setting the purpose: “I would like to understand the workflow and timing, then decide whether a small pilot or a diagnostic is sensible.” Ask the buyer to walk through a recent example. Concrete examples reveal details that abstract requirements miss. “We need automation” might become “Every Friday I copy six fields from approved video pages into our lesson template.” That gives you inputs, outputs, frequency, and a user role to investigate.

Ask what happens when the task goes wrong. A delayed internal note is different from a failed payment or a record exposed to another customer. The severity affects testing, support, and whether the project fits a solo freelancer's capacity. Then ask how the team handles the task now and why that approach is insufficient. An existing workaround is not automatically evidence that custom software is worth buying; it establishes a baseline against which the proposed change can be compared.

Discuss timing and budget without making them an interrogation. “Is this tied to a launch or an internal improvement?” reveals urgency. “Have you set a budget range, or would it help if I explained the likely scale of a small pilot?” makes the commercial conversation collaborative. If the buyer will not discuss a range, you can state a provisional range with assumptions. There is little value in spending days designing a $4,000 solution for someone whose maximum budget is $200.

Close with a decision and next owner. That might be “You will send two redacted examples and confirm the browser policy; I will send a diagnostic scope by Thursday.” It might be “An existing export probably handles this; I suggest trying that first.” Record the result promptly. A call without a clear next action tends to become vague follow-up, while an agreed action makes both parties' progress assessable.

## Ask the questions your specific services require

| Service | Questions before a fixed build quote | Why the answers change scope |
|---|---|---|
| Chrome extension | Which domains, pages, browser versions, user roles, permissions, installation route, and data flows? | Site differences, review, enterprise policies, and access can dominate delivery |
| Web application flow | Which current repository, hosting plan, authentication provider, roles, integration events, and failure cases? | Existing architecture and authorization rules can make a small UI change a larger system change |
| Technical consulting | What decision must be made, what evidence is available, and who will use the recommendation? | A useful diagnostic needs a bounded question and a usable output |
| Tutorial or demo | Who is the reader, what should work, which versions, who reviews, and what usage rights? | Technical research, editorial changes, and reuse terms affect the effort |
| Mentorship | What prerequisites, project outcome, session length, review limits, and support window? | Teaching requires preparation and bounded availability, not just call time |

For extensions, ask whether a supported API or existing integration exists before committing to DOM interaction. Ask whether the business controls the relevant system and whether its administrators permit the installation route. Confirm whether the extension will collect browsing or account data and where that data goes. You are establishing delivery facts, not performing a full legal or security assessment. If the customer requires such an assessment, treat it as a separate capability and purchasing decision.

For web work, identify who can approve repository access, deployment, DNS changes, payment configuration, and production testing. A buyer may own the business but lack access to a former developer's hosting account. That is a real project dependency. Do not promise a launch date that assumes access will appear instantly. Separate the time you need to work from the time the customer, payment provider, or other vendor may need to act.

For tutorials, agree whether code needs to work locally, in a hosted demo, or both. Decide whether the company supplies accounts or usage credits and how much ongoing maintenance is included. A published repository can become outdated after a vendor changes its SDK. Define the tested versions and delivery date, plus any separately purchased update service. This makes your work reproducible without turning one article into an unlimited maintenance commitment.

## Design a paid diagnostic with an independent result

For Cedar Learning, a $450 diagnostic example could include a ninety-minute workflow observation, review of five redacted examples, a feasibility assessment, a recommended approach, and a two-page scope. Estimate four to six total hours, including preparation and communication. At six hours, gross revenue is $75 per hour before expenses and tax. If the investigation is likely to take twelve hours, either raise the price, reduce the investigation, or choose a different engagement structure.

The diagnostic report can compare three routes: a configuration change in an existing tool, an approved API integration, and a user-triggered extension. Evaluate the routes using setup effort, reliability, installation, data handling, ongoing cost, and user experience. Give a recommendation and explain the unresolved assumptions. If you find that an existing export is adequate, say so. The buyer has paid for a good decision, not for justification of a predetermined custom build.

Its acceptance criteria might be: the observed workflow is described accurately; inputs and outputs are listed; installation and access constraints are recorded; two or three approaches are compared; and a proposed pilot has defined acceptance examples. Implementation is excluded. The report is complete when it answers the agreed decision question, even if the recommendation is to stop. That is how you keep discovery valuable and bounded.

You can credit some diagnostic fees toward implementation, but do not assume you must. A credit is a commercial offer with an expiry and scope, not evidence that discovery had no value. If you offer it, include the economics in your total quote. A common error is to charge for discovery, discount it completely, and then forget those hours when assessing profitability. Record every phase consistently.

## Convert wishes into observable acceptance examples

A requirement such as “easy to use” is meaningful but too vague to decide whether a milestone is complete. Translate it into behavior. For the extension: a coordinator can open the supported page, enter a note, save it, see confirmation, and export the agreed columns. For a web inquiry flow: a valid submission creates one record and shows success; an invalid submission explains what must change; a failed integration produces a recoverable operator alert without silently losing the request.

Use representative examples supplied or approved by the customer. Document normal cases, missing fields, invalid data, duplicate actions, and dependency failures. Avoid inventing a massive testing matrix for a tiny pilot, but cover the failures that matter to the workflow. If the customer has two user roles, test the role boundary rather than assuming a hidden button is enough to protect access. Technical acceptance should demonstrate the promised result, including important failure behavior.

Keep business measurement distinct. You may measure task completion time, error counts, or adoption after release. Those observations inform the customer's decision to expand. They should not substitute for technical acceptance unless the commercial arrangement explicitly depends on them and you can control the relevant factors. A solo freelancer generally should not guarantee sales or cost savings caused by a wider business system they do not operate.

Define the review process as well as the criteria. Identify one approver, a review window, a way to submit consolidated feedback, and a process for unresolved defects. A proposed five-business-day review window can be a negotiation starting point, not a universal enforceable rule. Do not assume silence legally equals acceptance. Put the actual agreement in the contract and distinguish in-scope corrections from new requests.

## Choose a pricing model based on uncertainty

Fixed fees work when the result and dependencies are sufficiently defined. The customer gets budget predictability; you take estimation risk. Hourly or daily billing can suit ongoing work or an uncertain backlog, but it needs priorities, reporting, and an approved spending limit. A capped time-and-materials diagnostic is useful when you cannot predict the investigation precisely but can agree on a maximum commitment. A retainer reserves defined capacity or provides a recurring service; it is not an unlimited queue.

| Model | Good fit | Main risk | Practical control |
|---|---|---|---|
| Fixed scope, fixed fee | A supported extension export or bounded web flow | Unpaid scope growth | Acceptance examples and change process |
| Hourly with cap | Existing app investigation or small evolving backlog | Buyer fears an open-ended bill | Written cap, priorities, and progress updates |
| Paid diagnostic | Unknown architecture or feasibility | Buyer confuses investigation with full fix | Independent report and explicit exclusions |
| Capacity retainer | Predictable maintenance or agency support | Reserved time becomes always-on availability | Hours, response window, rollover, and exclusions |
| Recurring output package | Tutorials, demos, or workshops | Revisions and research expand | Defined outputs, review rounds, rights, and dependencies |

Value informs a price, but it does not remove delivery economics. If a customer believes a feature is important, you can price for responsibility, expertise, and outcome rather than keystrokes. You still need to know whether the scope can be delivered profitably and whether the customer has a viable alternative. Avoid arbitrary “charge ten percent of their savings” rules when the savings are hypothetical. A clear fixed deliverable at a justified price is enough for a first engagement.

## Work through a quote from the inside out

Suppose a pilot requires two hours of planning, fourteen of implementation, four of testing, two of communication, two of handover, and two of expected support. That is twenty-six delivery-related hours. Add four acquisition hours allocated to the sale, giving thirty total hours. At an internal target of $70 per total hour, labor contribution is $2,100. Add $100 direct costs and a $300 uncertainty allowance, producing an illustrative $2,500 quote. The allowance is not a magic percentage; tie it to actual risks.

You could instead offer a $1,600 version by removing cloud synchronization and supporting a local export only, if that smaller scope still solves a useful problem. This is preferable to discounting the same promise until it becomes uneconomic. Explain what each option does and which you recommend. Do not create three nearly identical packages merely to steer the buyer toward an inflated middle option. Options should represent real differences in the result or responsibility.

For tutorial work, count research, example implementation, writing, screenshots, clean-environment verification, editorial calls, revisions, and publication coordination. A $900 article that takes eighteen total hours yields $50 gross per hour before expenses and taxes. If the scope includes a working application and extensive editorial changes, that may be unattractive. You can simplify the example, reduce rights or revision scope where appropriate, or quote a higher price. Your enjoyment of teaching does not eliminate the need to account for preparation.

For mentorship, four one-hour sessions may require two additional hours of preparation, one of reviews, and one of administration. A $400 package then represents eight hours, or $50 gross hourly before other costs. If you offer unlimited chat between sessions, that denominator is unknown. Define response windows and review limits. The same economic principles apply across your services even when the visible customer interaction is a short call.

## Write a proposal that answers the buying questions

A proposal should state the problem and desired result in the customer's language. Then specify the deliverables, acceptance criteria, dependencies, exclusions, schedule, price, payment milestones, ownership terms, and next decision. Keep it as short as the scope permits. A small pilot may need two or three pages plus governing terms, rather than a long agency-style presentation. Its purpose is mutual clarity, not to prove how many frameworks you know.

For Cedar Learning, the opening could be: “Your coordinators currently copy approved lesson details into a weekly file. This pilot will provide a user-triggered Chrome workflow that stores the agreed fields and exports one CSV format on the supported pages.” The proposal should then say whether storage is local, whether data is shared, and which roles are supported. If cloud synchronization is excluded, make that visible near the deliverable rather than burying it in fine print.

Define the customer's responsibilities. They supply representative redacted examples, confirm authority to use the relevant systems, identify the approver, provide account access, and review the pilot within the agreed window. Missing customer inputs affect the schedule. State how you will notify them and reschedule, rather than silently absorbing delays. You can be flexible while still making dependencies explicit.

The payment plan might be forty percent before work, forty percent after an accepted staging milestone, and twenty percent at handover. On $2,500, those payments are $1,000, $1,000, and $500. This is an illustrative allocation, not a mandatory industry standard. Tie invoices to understandable milestones and define what happens if a payment is late or work is cancelled. Smaller diagnostics may be paid upfront. Larger engagements may need shorter billing intervals to limit exposure for both parties.

## Make scope changes ordinary rather than adversarial

A change request is a new decision about time, money, and priorities. It should not require conflict. When a buyer says “Could it also work on another site?”, respond with curiosity: which pages, what behavior, and why now? Then explain whether it fits the current scope. If it changes dependencies, acceptance, or effort, provide a written impact assessment before implementing it. The buyer can approve the addition, swap an existing feature, or postpone it.

A change note can be brief: “Requested: support a second source site. Current pilot supports the agreed domain only. Investigation is estimated at up to three hours, capped at $240; implementation will be quoted after that review. The current milestone remains unchanged unless we agree to reschedule it.” Replace the numbers with a real estimate. This separates investigation from an unsupported fixed promise about an unfamiliar system.

Distinguish a defect from a new requirement. If the agreed export omits a required column on a supported example, that is an in-scope correction. If the customer asks for a new export format, that is a change. If the source website changes after acceptance, responsibility depends on the maintenance terms and cause. Write these examples into the agreement in plain language. Ambiguity is especially expensive for extensions because their external environment can change independently.

## Handle common objections with diagnosis

When someone says the quote is too high, ask which constraint matters: total budget, uncertainty about value, timing of payments, or comparison with another scope. If the budget is real but smaller, offer a useful smaller result or decline. If trust is the issue, a paid diagnostic or a reviewable milestone may help. Do not immediately lower the fee without changing anything; that suggests your original price was arbitrary and leaves the delivery risk intact.

When someone says AI can build it, agree that AI can accelerate parts of implementation. Explain the responsibilities included in your service: understanding the workflow, choosing access boundaries, handling failures, testing, deployment, documentation, and owning the agreed corrections. Avoid defending your fee through hours of manual typing. You sell a reliable process and result. If the customer prefers to build it internally, a scoped review or mentorship engagement may be a better fit.

When a buyer asks for a free prototype, offer an existing relevant demonstration or a small paid feasibility test with a useful deliverable. A limited speculative example can occasionally be a conscious marketing investment, but cap the time and avoid production access or customer-specific work that substitutes for a paid project. Record the cost as acquisition time. “Free” work still has an economic cost, especially when you have limited weekly capacity.

When the response is “We need to think about it,” ask what information is still missing and who is involved in the decision. Agree on a follow-up date if appropriate. Do not assume the objection hides a bargaining tactic. The buyer may need an internal approval, a security review, or a different priority. A clear no or later date is more useful than a fictional probability in a CRM.

## Protect ownership and confidentiality in the actual agreement

For client work, distinguish customer-specific deliverables, your pre-existing code, third-party dependencies, and general know-how. A contract can assign or license different categories differently, but that must be explicit and appropriate to the engagement. Do not assume that paying an invoice automatically settles every intellectual property question. Similarly, do not assume you can reuse client code in your products because the underlying pattern is common. Identify reusable foundations before the project and agree on their treatment.

For technical content, cover byline, attribution, editing, reuse channels, translation, exclusivity, portfolio permission, and maintenance. For code repositories, list licenses and explain what the customer receives. For an extension, establish ownership of the developer account, store listing, source repository, and backend services. A transfer at the end can be more complicated than starting with customer-owned accounts, so decide early. Chapter 4 explains the operational side of this handover.

Use customer-approved environments and data. Avoid copying production data into personal accounts just to make development easier. Agree on permitted AI assistants, repository access, logging, and external services. An AI vendor's privacy setting is one part of the analysis, not blanket permission to upload customer information. You remain responsible for following the customer's approved use and the contract. Keep the process proportional to the actual project rather than promising a compliance program you cannot deliver.

If you have employment or other contractual obligations, check the actual terms relevant to outside work, intellectual property, confidentiality, and conflicts before accepting an engagement. The attached resume is historical evidence, not confirmation of current employment. This guide does not assume that you need permission from a particular employer or that a particular restriction exists. It asks you to ground the decision in your real agreements and keep client work separate from resources you are not authorized to use.

## Plan payment and cash flow as part of delivery

An invoice should identify your business or individual billing identity, the customer, the agreed service or milestone, currency, amount, due date, payment method, and reference to the agreement. Payment processors can help collect funds, but they do not replace scope agreement or guarantee recovery in every dispute. Keep invoice records and payment confirmations. Reconcile what was invoiced, what was collected, fees, refunds, and expenses rather than treating an invoice as earned cash in the bank.

Do not finance a customer's indefinite project accidentally. A sensible initial payment, staged delivery, and prompt invoicing reduce the amount of unpaid work at risk. If an invoice is late, follow the agreed process: send a factual reminder, identify any dispute, and pause or reschedule further work where the contract permits. Avoid threats or surprise fees. Consistency is more useful than emotion, and clear records make it easier to resolve misunderstandings.

For agency work, establish whether you invoice the agency directly and whether it owes payment regardless of its own customer's payment schedule. Read any terms that condition payment on another party. A project can be profitable on paper and still create cash-flow stress if payment takes months. Your ability to accept a slow-paying customer depends on your actual finances, not the hypothetical revenue scenarios in this guide.

## Understand the difference between revenue and income

Gross revenue is the amount customers pay before expenses. Payment processing, project services, software subscriptions, subcontractors, and other business costs reduce it. Taxes may also be due, and their treatment depends on your situation. A $2,500 project is not $2,500 of spendable personal income. The IRS states that self-employed individuals generally face income tax and self-employment tax and may need estimated payments. Use its current guidance and your own circumstances rather than a universal “save thirty percent” rule. [C3](references.md#c3)

Track actual business expenses and keep supporting records. A dedicated account can make reconciliation easier, but account structure does not by itself create a legal entity or liability protection. Do not choose an entity or tax treatment based only on a freelancing tutorial. A qualified adviser can help evaluate the actual situation when the decision matters. Your immediate operational task is simpler: maintain accurate records and avoid spending gross receipts as though every dollar were profit.

A monthly review should show collected revenue, direct project costs, recurring overhead, outstanding invoices, total hours, and money reserved for obligations. Keep capacity and cash separate. You can have a full calendar but little collected cash, or a large advance payment attached to substantial undelivered work. The second case is not free money; it funds future obligations. This distinction becomes important when deciding whether to take another project or buy more software.

## Create support terms before the first bug report

A correction period can cover defects in the agreed deliverable reported within a specified window, such as fourteen calendar days after acceptance. That is a proposed business term to negotiate. Define a defect using the acceptance examples and supported environment. New features, unrelated system failures, and third-party site changes may require a separate quote. Do not call every post-delivery problem billable without inspecting it; a regression you introduced should be handled according to your responsibility.

Set the communication channel and response window. “I review support messages on business days and aim to acknowledge them within two business days” is different from an emergency uptime guarantee. Only promise a service level you can actually sustain around your available hours. A solo side-business operator should be cautious about twenty-four-hour obligations. If the system requires that level of coverage, involve a suitable provider or decline the unsupported responsibility.

For maintenance, specify the recurring task. A package might include a monthly dependency review, a small number of supported workflow checks, and up to two hours of minor changes. Explain rollover, overages, scheduling, and exclusions. The fee compensates reserved capacity and real work; it should not be a subscription attached to a static site merely because recurring revenue sounds attractive. Review whether the customer still needs it after the initial period.

## A complete fictional negotiation

Cedar Learning asks for a team extension with notes, shared storage, automatic summaries, multiple sites, and a dashboard. You first identify the essential task: producing a consistent weekly export. You explain that a shared product with AI and multiple sources is a larger project, and propose a $450 diagnostic to observe the workflow and choose a useful pilot. The customer receives an independent recommendation and can stop afterward.

During discovery, the team confirms one supported source and one coordinator role. Shared storage is useful later but not required for the first test. You propose a $2,500 local export pilot, excluding AI and multi-user synchronization. The scope includes representative examples, error states, source handover, and a defined correction period. The customer asks for a lower price, so you offer a $1,700 version with fewer supported fields and no custom formatting, assuming the revised scope remains economical. These figures are illustrative teaching choices.

The buyer chooses the smaller pilot. You agree on payment milestones, customer inputs, and acceptance. During delivery, they ask for automatic cloud sync. You document it as a separate phase and offer a discovery step for access and data handling. At the review, an agreed field is missing from one export example, so you correct it under the current scope. After acceptance, you hand over the source and explain options for future work without implying that expansion is already sold.

This negotiation illustrates a healthy pattern: investigate uncertainty, sell a useful smaller outcome, and distinguish defects from additions. It does not depend on pressure or exaggerated claims. The customer retains control of spending, and you retain control of the promise you make. That is the foundation of a sustainable freelance practice.

## Keep a decision record after each sale or loss

For a won engagement, record why the customer bought, which proof mattered, what was excluded, how the price was chosen, and what you expect total hours to be. After delivery, compare the estimate with actual effort. For a lost engagement, record the stated reason without inventing a psychological explanation. “Budget below scope” is useful; “they do not value quality” usually is not. Look for repeated patterns across several opportunities.

If buyers repeatedly choose the diagnostic but never implementation, determine whether the recommendation is solving the problem or whether implementation is too large or unclear. If they buy implementation but support destroys the economics, revise acceptance and maintenance. If a lower-priced offer attracts difficult, broad projects, the problem may be scope and qualification rather than the price number alone. Your records turn experience into a better offer instead of a collection of anecdotes.

The practical assets for this chapter are a fit-call agenda, diagnostic scope, proposal, acceptance matrix, change note, and invoice record. You will find editable versions in the templates. They are designed to make a small project reviewable, not to impersonate a lawyer or replace a real agreement. Before scheduling work, ensure the buyer, result, inputs, payment, and stop conditions are clear enough that both parties can describe the same project.

## Detailed examples for the three other service routes

### Web improvement: a booking request that can fail safely

A training business wants a form connected to its existing customer tracker. Before quoting, identify the actual event: is it an inquiry, a reservation, or a paid booking? An inquiry can tolerate a manual follow-up; a paid booking may need inventory rules, payment verification, cancellation behavior, and customer confirmation. Calling all three “a booking form” conceals major scope differences. Ask for a recent example and trace the information from submission to the person who acts on it.

For a bounded inquiry integration, define fields, validation, record creation, duplicate handling, notifications, and recovery. If the tracker is unavailable, what should the visitor see and where should the request wait? Who can view the stored data? How will an operator know that a submission needs attention? These questions establish useful acceptance examples. They also reveal whether the customer needs a reliable integration or just a link to a service that already supports the workflow.

An appropriate proposal might cover one form and one destination with an agreed manual fallback. It would exclude payment handling and inventory unless specifically investigated. If the customer later adds checkout, treat that as a new commercial decision. Your BetterCare Meals background is relevant proof, but it does not eliminate the need to understand a different customer's business rules. Reusing general experience is efficient; reusing assumptions without checking them is risky.

### Consulting: a repository setup review with a spending cap

An agency inherits an application that only one former contractor could run. You can offer a capped investigation: a clean-environment setup attempt, dependency and configuration findings, a prioritized remediation note, and one walkthrough. Define which operating environment you will test and which access the agency must provide. The cap limits spending; it does not guarantee every issue will be repaired within it. State when you will pause and ask for a new decision if deeper problems emerge.

During the review, you discover a missing private package and an undocumented environment variable. Record those blockers rather than spending unlimited time trying to bypass them. The customer can obtain legitimate access or approve an alternative. Your report remains useful because it identifies what prevents reproducibility and who must act. If the agency wants implementation, quote the fixes once the dependency is understood. This preserves both your independence and the customer's budget control.

### Technical education: a workshop with finite preparation

A small engineering team wants a session on building an internal Chrome extension. A workshop is more than a call. Agree on the participants' prerequisites, supported environment, example project, learning outcome, session duration, and follow-up material. Decide whether you will review the team's own code or teach with a synthetic example. The latter is often easier to prepare safely and keeps sensitive systems outside the teaching scope.

Your quote should count preparation, rehearsal, environment checks, delivery, questions, and any recording rights. A live workshop and a reusable company training recording are different usage packages. If the team wants participants to leave with a production extension, that is closer to guided implementation and requires additional scope. A clear workshop outcome might be understanding the architecture and completing a small local demonstration. Let the contract match the actual promise rather than the buyer's most optimistic interpretation of “training.”
