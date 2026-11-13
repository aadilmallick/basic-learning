# 4. Deliver reliably, choose modern tools, and earn repeat business

[Previous: sales and pricing](03-discovery-pricing-proposals-and-money.md) · [Guide home](README.md) · [Sources](references.md) · [Templates](templates.md)

## Your delivery process is part of what people buy

A customer buying freelance software is taking a risk. They may not know how to judge architecture or code quality, but they can observe whether you clarify decisions, show progress, handle failures, and leave a usable system behind. Your engineering and teaching background can reduce that uncertainty. Explain the system in plain language, demonstrate the promised behavior, and document what someone needs to operate it. This is a commercial advantage because it makes referrals and repeat work easier.

Modern tools can accelerate parts of this process, but there is no single tool stack that every successful freelancer uses. The research here checks current provider capabilities and policies; it is not a representative survey of freelancer adoption or market share. Recommendations are based on your TypeScript, React, browser, AI, and developer-experience work. Choose tools for a specific bottleneck and confirm current plans before purchasing. A freelancer with a clear process and a small stack can outperform someone who maintains subscriptions instead of customer relationships.

This chapter follows the same fictional Cedar Learning pilot: one supported browser workflow and one export format. It then extends the process to web improvements, consulting, and technical tutorials. The technical guidance is architectural and operational rather than a complete extension programming course. The included executable Python tool handles business arithmetic and a local prospect file; the extension acceptance examples are specifications to implement and test in a real project, not claims that a production extension was built in preparing this guide.

## Start every engagement with an operating agreement

At kickoff, restate the result, scope, approver, supported environment, milestones, communication channel, and next customer inputs. Confirm where decisions will be recorded and how changes will be approved. A small project does not need daily ceremonies, but it does need a source of truth. One shared document and one issue board can be enough. Put the initial scope and acceptance examples somewhere both parties can reference without searching a long chat history.

Collect access deliberately. The customer should own its domain, production hosting, payment account, and other long-term business services wherever practical. Invite you with the role required for the task rather than sharing passwords. Use a password manager or approved secret-sharing method when necessary. Record account ownership and remove unneeded access at handover. This reduces dependency on your personal accounts and makes the customer more comfortable hiring you again.

Agree on working hours and response expectations. If your capacity is eight to twelve hours a week, do not imply full-time availability. Describe deliverable dates with their dependencies rather than promising instant progress every day. For example: “The first review build will be ready within the agreed work period after sample data and access are complete.” Replace that phrase with real dates in an actual agreement. Your honesty about capacity is more useful than an optimistic deadline followed by explanations.

## Use a narrow technical design before coding

For the extension pilot, write a short design note: the user triggers the action; the extension reads only the approved information; the user can review or edit it; data is saved in the agreed place; and export produces the agreed format. List what stays on the device and what reaches a server. Identify the external dependencies and failure cases. This note lets a nontechnical buyer understand the behavior and gives you a basis for implementation choices.

Separate three concerns: the browser interface, the data model, and any server integration. Keeping them separate makes tests and future changes easier. For example, formatting a CSV should not depend on the current DOM of a third-party page. You can test export behavior with synthetic records even when the supported website is unavailable. This is not an instruction to build a complex architecture; it is a way to keep one fragile boundary from spreading throughout a small project.

Choose the simplest deployment that meets the agreed need. Local-only storage may be appropriate for a single-user pilot. Shared team data introduces authentication, authorization, hosting, backup, and account ownership decisions. It should be a conscious scope increase. A spreadsheet or existing integration can sometimes replace the custom system. Your job is to deliver the useful result, and your design note should explain why the chosen route is proportionate.

## Chrome extension delivery has its own obligations

Chrome's current documentation and store policies make Manifest V3 packaging, permissions, and data disclosures important delivery considerations. Keep permissions aligned with the feature and prefer the narrowest access that works. Ordinary Manifest V3 store extensions should package executable logic rather than loading remote scripts to run in the extension. Google's policy contains specific exceptions and context rules; consult the current policy for the actual design instead of simplifying it into “extensions can never contact a server.” Network data access and remotely hosted executable code are different questions. [E1](references.md#e1), [E2](references.md#e2)

Treat the extension package as inspectable by users. Do not put private API keys, database administration credentials, or other server secrets in it. If a paid API requires a private key, keep that key on an appropriately protected server and authenticate the user through the approved design. A public client identifier is different from a private credential, so classify each value correctly. Your developer-experience background should help you document which configuration is public and which belongs in a secret store.

Test lifecycle behavior as well as the happy path. Extension contexts can be stopped and restarted; store durable state where appropriate rather than assuming in-memory state lives forever. Navigation can change the supported page without a full reload. Users can revoke permissions, close a popup, or click twice. A small workflow can fail in these ordinary situations if the implementation only reflects your initial manual demo. Make the relevant cases part of acceptance and explain the remaining limits.

The distribution route is a project dependency. A development build can demonstrate behavior, but it is not automatically a suitable long-term installation method for every team. A public or limited store listing and an enterprise-managed deployment have different requirements. Confirm the customer's environment and current Chrome distribution documentation before quoting the route. This research could not retrieve the specific distribution page reliably, so this guide does not claim to verify eligibility for a particular private deployment arrangement. Store review timing is outside your control; distinguish submission readiness from approval.

For store-related work, establish who owns the developer account, prepares the listing, approves privacy statements, responds to review requests, and handles future notices. The wording must reflect actual behavior. Do not claim that an extension collects no data if it transmits user information to a backend. Do not promise a fixed approval date. These are practical handover responsibilities that are easy to overlook when the visible feature is only a button.

## Choose extension tooling for your existing strengths

WXT is a current open-source web extension framework that can reduce packaging and development friction. Its documentation explicitly notes that it does not replace understanding browser extension APIs. For you, a framework can standardize entry points and builds across projects, but it should not hide the permissions and lifecycle behavior you need to explain to customers. A small vanilla TypeScript extension may be perfectly adequate; use a framework when its conventions make delivery and maintenance simpler. [E3](references.md#e3)

Maintain a reusable foundation only after you understand which parts repeat. Useful foundations might include build configuration, a synthetic fixture page, storage abstractions, an error display, export utilities, and a permissions review checklist. Keep customer-specific behavior separate and respect ownership terms. Do not build a universal extension platform before selling a pilot. You will learn more about reusable requirements from two real projects than from imagining every possible future client.

Playwright documents extension testing with Chromium and a persistent browser context, with current caveats about branded browser sideloading flags. Use the documented environment and verify it against your chosen versions. Automated tests can cover supported synthetic pages and export behavior, while manual checks cover installation and permission prompts. Do not assume a standard website test runner automatically exercises an installed extension. Testing the pure data transformation is useful, but it does not validate the complete browser integration. [E4](references.md#e4)

## Deliver web projects according to their actual complexity

For a content website, prioritize clear page structure, responsive behavior, accessible interaction, content ownership, inquiry delivery, and editing. A builder or CMS may give the customer a more useful handover than a custom repository they cannot maintain. For a transactional application, prioritize the full flow: validation, authentication, authorization, persistence, integration events, failure recovery, and operational ownership. Your React and TypeScript experience is an asset when those requirements justify a custom implementation.

Keep one familiar stack as the default for application work. Your existing experience suggests React or Next.js, TypeScript, a relational backend when appropriate, and a managed deployment route. That is a recommendation for consistency, not a claim that every customer needs those products. Existing codebases, staff capability, data residency, and budget can justify a different choice. Do not impose a rewrite merely to use the tools you prefer.

Hosting terms belong in the estimate. Vercel's Hobby plan is restricted to personal, non-commercial use; check a suitable paid plan for commercial customer work. Included usage and overages can change, so record the current plan, expected usage, billing owner, and budget controls when quoting. A free preview or local demo does not establish that production operation is free. Make recurring costs visible before the customer commits. [H1](references.md#h1)

For managed backends such as Supabase, distinguish development convenience from production readiness. Confirm authorization rules, backups, recovery, service limits, and account ownership in the actual plan. Supabase's deployment documentation describes isolated branching for validating changes without production data; determine whether the relevant feature and plan fit the project. Do not connect an experimental AI-generated interface directly to production customer records and assume the provider handles every application-level permission decision. [H2](references.md#h2)

A paid website handover should include a real owner task. Can the customer change a course date, update an image, or export an inquiry record using the documentation? That test is more informative than merely handing over a Git repository. For an application, the receiving developer should be able to run setup, understand environment variables, deploy, and find operational logs. Your teaching skill makes this part of delivery especially valuable.

## Use AI assistants with a verification process

Cursor, Claude Code, and Codex are current examples of AI coding tools with agent-oriented capabilities. Their products, usage accounting, data settings, and plan limits evolve. Choose one primary assistant first, especially since your resume already reports familiarity. Use it for bounded implementation, code explanation, test generation, and review support. The research establishes current product capabilities, not a guaranteed productivity multiplier or permission to put every customer's code into every service. [A1](references.md#a1), [A2](references.md#a2), [A3](references.md#a3)

A useful task brief specifies the goal, relevant files, constraints, acceptance examples, and required verification. For an export feature: “Implement the agreed column mapping for these synthetic records, preserve existing behavior, add tests for quoting and missing values, and report the commands run.” Review the diff yourself and run the relevant checks. A second model's approval is not a substitute for understanding the code, especially around authorization, payments, and data handling.

Use separate tasks for discovery, implementation, and adversarial review. First ask the assistant to identify assumptions and inspect existing patterns. Then approve a small implementation plan. After the change, ask for concrete failure cases and independently check important paths. Keep the change small enough to review. Broad prompts such as “make this production ready” encourage vague output because the phrase hides the project's actual responsibilities.

Confirm customer permission and product settings before using AI on proprietary material. Check data retention, training use, remote execution, subprocess permissions, and where logs or repository copies may be stored. Cursor documents a Privacy Mode, but that setting does not mean no processing ever occurs or that every customer's requirements are satisfied. Apply the same care to other vendors and plans. Keep production secrets and personal data out of prompts unless an approved workflow explicitly requires and supports them. [A4](references.md#a4)

Price your service around the agreed result and responsibilities, while tracking your actual costs. AI may make some coding faster and other review work more important. Do not guarantee that a customer's project will take one tenth the time because a demo looked quick. If a fixed-fee project becomes more efficient, you can benefit from your process. If the work is hourly, bill according to the agreement and the time actually worked.

## Use app generators for exploration, then assess the result

v0, Lovable, and Bolt are current AI-assisted app or interface generation products. They can help create a concept, demonstrate a flow, or accelerate a starting point. Their official sites describe building applications and prototypes, but that does not establish the quality of any particular generated result. Treat the output as code and configuration that must be understood, tested, and maintained. Your value as an engineer is deciding what is appropriate to ship. [A5](references.md#a5), [A6](references.md#a6), [A7](references.md#a7)

For a client demo, use synthetic data and label the scope: “This illustrates the proposed flow; production integration and access controls are not yet implemented.” That prevents a polished interface from creating the impression that the business system is complete. If the customer approves the direction, inspect the generated dependencies, data flow, error handling, and deployment requirements before using it as a foundation. Sometimes rebuilding a small component in your standard stack is simpler than inheriting a large generated structure.

Do not buy several generation subscriptions because each promises speed. Time-box a comparison using the same small task and evaluate the result: how much editing was needed, could you export and maintain it, did it fit the customer's platform, and did it actually reduce total effort? Include review and cleanup time. A tool that produces a beautiful first screen but makes handover difficult may be a poor choice for freelance delivery.

## A practical modern tool map for your business

The following table is a decision map, not an instruction to subscribe to every row. “Start” means a reasonable default for an initial small practice; it does not imply that you already use or own the product. Provider capabilities were checked where references are shown. Prices are intentionally not frozen across the whole table because billing intervals, included usage, geography, and promotions change.

| Job to accomplish | Candidates | What you should do first | Upgrade trigger |
|---|---|---|---|
| Prospect and follow-up record | Included CSV, then Attio | Keep one record per account with evidence and next action | You repeatedly miss actions or need relationship history [T3](references.md#t3) |
| Find a professional contact | Official sites, Hunter; Apollo for broader B2B research | Manually define the buyer and verify relevance | Contact research becomes the measured bottleneck [T1](references.md#t1), [T2](references.md#t2) |
| Inquiry form | Existing site form or Tally | Ask about workflow, timing, and contact details | Repeated inquiries need a consistent intake [O1](references.md#o1) |
| Scheduling | Existing calendar booking or Cal.com | Offer a short fit call with sensible availability | Back-and-forth creates avoidable delay [O2](references.md#o2) |
| Proposals, contracts, invoices | One simple workflow, or Bonsai/HoneyBook | Choose one system that fits the actual engagement | Repeated admin consumes meaningful paid time [O3](references.md#o3), [O4](references.md#o4) |
| Collect invoice payment | Existing business payment route or Stripe | Confirm region, method, fees, and ownership | Manual collection becomes inconvenient [O5](references.md#o5) |
| Coding assistant | Cursor, Claude Code, or Codex | Use one with approved data handling | A second tool solves a demonstrated gap [A1](references.md#a1), [A2](references.md#a2), [A3](references.md#a3), [A4](references.md#a4) |
| UI exploration | Existing design tool, v0, Lovable, or Bolt | Time-box one synthetic prototype | It reduces total design and implementation effort [A5](references.md#a5), [A6](references.md#a6), [A7](references.md#a7) |
| Extension build | Familiar TypeScript setup or WXT | Keep permissions and lifecycle explicit | Repeated packaging work justifies a framework [E3](references.md#e3) |
| Browser acceptance | Playwright plus manual checks | Test the promised workflow and important failures | More supported environments require a broader matrix [E4](references.md#e4) |
| Error monitoring | Sentry | Capture actionable errors with sensitive data minimized | A live service needs visibility beyond manual reports [O6](references.md#o6) |
| Product behavior measurement | Minimal events; PostHog when justified | Measure the few events tied to the customer's question | The customer needs supported adoption analysis [O7](references.md#o7) |
| Workflow automation | Existing integration; n8n when suitable | Automate reminders or internal handoffs first | Repeated manual steps justify ongoing operations [O8](references.md#o8) |

Project issues and source control can remain in the customer's existing repository workflow. A small project rarely benefits from forcing the buyer into a new project management platform. Use a simple board with planned, in progress, review, and accepted states if that helps. Keep business decisions in a shared record and link technical work to them. The customer should know what needs their attention without reading every commit.

For documentation and demonstrations, your own recording tools may be enough to show your work, provided the output meets the customer's requirements. Use whatever approved recording method produces a clear short video and captions or written steps when needed. You do not need a premium video platform before your first sale. Check sharing permissions and remove private material from recordings. Convenience matters, but confidentiality and access are part of the deliverable.

## Keep the operating stack affordable

Start with a domain and business mail if needed, a simple prospect record, existing scheduling, one coding assistant, source control, and one invoicing route. Client production hosting and usage should normally be visible customer costs rather than silently bundled into your personal subscriptions. A proposed internal software budget of $50–$100 monthly can be a useful ceiling for experimentation, but it is a self-imposed planning limit, not a priced bill of materials. Verify actual subscriptions and usage against current checkout pages.

Evaluate a new tool with a simple calculation. If a subscription costs $30 monthly and saves forty minutes, the apparent savings at an internal $60 hourly value are $40. But setup, maintenance, and whether that time can actually be redeployed matter. If it requires three hours of initial configuration and creates recurring upkeep, the benefit may be negative for a small practice. Use the simplest workable process until a real bottleneck appears.

Avoid duplicate systems with conflicting records. If you choose Bonsai or HoneyBook for client administration, assess whether you still need a separate CRM for the same small pipeline. If the customer already has a scheduling and payment tool, integrate with it where appropriate rather than creating another account. Fewer handoffs reduce the chance of missed information. The professional impression comes from a smooth experience, not the number of logos in your stack.

## Automate your own work carefully

Good early automations include reminding you about a follow-up, creating a draft project folder after a signed agreement, flagging an overdue invoice, or generating a draft weekly update from completed issues. Keep factual review before anything is sent externally. A workflow that accidentally contacts an opted-out prospect or sends a private note to the wrong customer creates more harm than the minutes it saves. Build automation around a stable process and explicit records.

n8n is relevant for connecting services and building internal workflows. Its official licensing material distinguishes permitted consulting from other uses, and its Community edition uses a Sustainable Use License rather than a generic unrestricted open-source license. Do not assume that selling access to your hosted n8n instance or embedding it in a commercial product is covered simply because building workflows for a customer is allowed. The current help center and actual license should govern the intended arrangement; this research encountered a moved documentation page and conflicting community interpretations for some multi-client scenarios. [O8](references.md#o8)

For your first customer automation, prefer a customer-owned account or a clearly agreed deployment arrangement. Specify credentials, failed-run handling, retries, data retention, usage costs, and the person who receives alerts. A workflow editor makes integration code easier to express, but it does not eliminate business rules. A scheduled job that creates duplicate records after a retry still needs an idempotency design and a recovery procedure.

## Make testing match the commercial promise

Test the important behavior at several levels. Pure functions can verify mapping, validation, and export formatting. Integration tests can verify approved service boundaries with suitable fixtures. Browser tests can verify the user flow in the supported environment. Manual checks cover installation, device behavior, content editing, and the actual acceptance review. You do not need a large test count; you need evidence for the specific promise and significant failure modes.

For the extension export, include commas, quotation marks, line breaks, missing optional values, and duplicate actions in synthetic records. When spreadsheet files may interpret exported content as formulas, assess that risk and choose a documented export strategy appropriate to the customer. Test the supported page layout and the behavior when expected elements are absent. A clear message is better than silently saving incorrect information. Keep a small fixture set so future maintenance can detect regressions.

For a payment-related web change, use the payment provider's approved test environment and current documentation. Verify that the trusted server-side result governs access or fulfillment rather than relying solely on a client redirect. Test duplicate events and failure recovery as appropriate. This guide does not supply a payment integration or claim to test one. The point is that commercial acceptance must cover the event that matters to the business, not merely the visual appearance of a success page.

For authorization, test the negative case. An account should not retrieve another user's record simply by changing an identifier. A hidden admin button does not enforce server-side permissions. Keep test users and data controlled and do not probe systems beyond the customer's authorization. The right level of verification depends on the scope; if the system needs independent security assurance, arrange a qualified review rather than representing ordinary development tests as an audit.

## Communicate progress through evidence

Send an update at an agreed cadence, such as once or twice a week for a small engagement. Use four fields: completed behavior, evidence link, decision or blocker, and next milestone. For example: “The supported page now saves the agreed fields and exports the sample CSV. The demo uses synthetic data. I need your confirmation on the optional notes column by Wednesday; the next milestone is the error-state review.” This lets the customer act without interpreting a technical activity log.

Show unfinished work honestly. If only one browser or role has been tested, say so. If the backend connection is mocked, label it in the demo. A polished presentation should not conceal uncertainty. Buyers are usually better able to make decisions when the boundary between working behavior and planned behavior is visible. Your teaching ability can make that boundary understandable without overwhelming them with internal implementation details.

When a blocker appears, describe the effect and options early. “The required API access has not been approved, so the integration milestone cannot be verified. We can continue with the local export scope or pause until access is available.” Avoid silently building an unauthorized workaround. The customer can then choose a legitimate path and understand the schedule impact. This is part of delivery responsibility, not an admission that you should have predicted every external dependency.

## Turn handover into a usable product

A handover pack should include the result and supported environment, setup and build instructions, configuration categories, deployment steps, acceptance evidence, known limitations, and support terms. List account owners and recurring services. Include a rollback or recovery procedure appropriate to the project. A small local extension needs a different operational guide from a hosted application, but both need enough context for the next person to understand what exists.

Perform the handover with the receiving person. For a business owner, demonstrate an ordinary operation and a simple failure recovery. For a developer, run setup from a clean environment and explain the external dependencies. For a tutorial buyer, verify that the sample repository matches the published steps. This is where your ability to explain code has direct commercial value: it reduces the customer's fear of becoming dependent on an unavailable freelancer.

Remove temporary access and test data according to the agreement. Confirm that secrets used during development have the right owner and rotation process. Archive the accepted version and the relevant records so future work starts from a known state. Do not delete customer material unilaterally or retain it indefinitely without a reason. Good recordkeeping and account ownership make later maintenance easier for both parties.

## Ask for referrals and case studies after the outcome is clear

After acceptance and a useful period of use, ask for specific feedback: what changed, what still creates friction, and whether the documentation is sufficient. If the customer reports a measurable improvement, confirm how it was measured and whether it may be quoted. A testimonial should reflect the person's actual words and approved context. Do not write a glowing statement and present it as something they said.

Then ask permission to turn the work into a case study. Offer a redacted version when the workflow or data is sensitive. Describe the original problem, your scope, important decisions, tested behavior, and observed result. If the result is only successful technical delivery, say that. A clear, honest account can still be persuasive. Your case study should help the next buyer evaluate a similar problem, not convert confidential detail into marketing material.

A referral request can be: “If another team you know has a similar browser workflow or small integration need, I would appreciate an introduction. This short description explains the kind of work I am taking on.” Make it easy to forward. Ask without pressure and accept that the customer may not know anyone. Repeat work and referrals are outcomes of a good relationship, not contractual obligations you can demand after finishing a project.

## Offer recurring work when it has a real job

For extensions, continuing work may include checking supported pages after changes, updating dependencies, triaging reported defects, and implementing small approved improvements. For web applications, it may include monitoring critical flows, reviewing failures, and maintaining dependencies. For tutorials, it may include version updates or a recurring set of examples. Each has an identifiable recurring output or reserved capacity. Explain it so the customer can decide whether it is worth buying.

A $300 monthly maintenance example with two included hours is not automatically $150 hourly profit. Count review, communication, invoicing, context switching, reserved availability, and tool costs. Define what happens if the customer needs six hours or no hours. Decide whether unused capacity expires or rolls over and whether emergency work is included. A retainer with vague availability can consume your calendar even when little billable implementation occurs.

Your first repeat offer could simply be another scoped sprint after the first result proves useful. That may be better than a subscription. Repeated fixed-scope projects let both parties learn the workflow and economics without creating an always-on expectation. Over time, if requests become predictable, a recurring package can make sense. Let the observed work determine the business model.

## Improve economics before increasing volume

After each engagement, compare estimated and actual hours by category: acquisition, discovery, implementation, testing, communication, revisions, handover, and support. Identify the source of variance. If testing expanded because the supported environment was unclear, improve discovery. If revisions expanded because several people gave conflicting feedback, require a consolidating approver. If acquisition was expensive, ask whether a partner route could produce more relevant conversations. Faster coding is only one possible improvement.

Raise prices when the scope, proof, demand, and economics justify it. You do not need to wait for an arbitrary number of years, but do not base a price increase solely on a viral post. Test the change on a comparable scope and track the response. A higher quote with no viable buyer is not a business improvement; a lower quote that reliably produces unprofitable work is not one either. Your objective is a repeatable exchange that both parties value.

Subcontracting can increase capacity, but it adds review, coordination, access, ownership, and customer-consent questions. Do not quietly outsource work that the agreement expects you to perform personally. Start by documenting your own process and identifying a truly separable task. The margin must cover supervision and risk, not just the subcontractor's invoice. A small, profitable solo practice may suit your side-income goal better than building an agency.

## A ninety-day plan with decision gates

In days one through thirty, choose the offer, prepare proof, research accounts, hold fit conversations, and seek a paid diagnostic or pilot. Review the pipeline weekly. If you cannot find repeated pain, revise the buyer or workflow hypothesis. Do not use a new tool subscription or a larger portfolio as a substitute for that evidence. The milestones are controllable actions and learning, not promised sales.

In days thirty-one through sixty, aim to deliver the first suitable engagement and measure total effort. Obtain feedback and, where permitted, a case study. Continue a modest acquisition routine while delivering. Review whether the offer was understandable, whether acceptance worked, and whether support was manageable. If the work was useful but unprofitable, change scope, process, or price before trying to fill the calendar with more of it.

In days sixty-one through ninety, test one repeat channel: a second agency engagement, a referral, another similar direct customer, or a technical tutorial commission. Look for repeated patterns that justify a reusable foundation. Only then consider a more specialized service page, a carefully chosen directory application, or a recurring package. If no repeat pattern exists, keep the business small and exploratory rather than building infrastructure for demand you have not established.

## Your immediate next action

Choose one service sentence from chapter 1, record a short demonstration of existing work, and prepare five genuine introduction requests plus five researched agency approaches. Keep them as drafts until you check the relationships, observations, and appropriate contact routes. The templates and CSV are designed for that preparation. This guide has not contacted anyone, created accounts, purchased subscriptions, published marketing, or established a live sales pipeline.

Use the first conversations to test a real question: who has a specific problem that you can solve, at a price and scope that supports your available time? Your browser tools, web work, and teaching give you credible ways to begin. The next improvement should come from customer evidence. Build the smallest useful engagement, explain it clearly, deliver it reliably, and use what you learn to make the next offer better.
