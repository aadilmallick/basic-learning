# Free resource and landing page

# 6 The free resource and the exact landing page

Your free resource is the AI App Shipping Checklist. Make it a short web page or downloadable document that can be used in 15 minutes. It should help someone diagnose a project even if they never buy.

## The resource body

> AI App Shipping Checklist
>
> Use this on one small AI feature before inviting another person to rely on it. Mark each item Yes, No, or Unknown and write one next action.
>
> 1. Can I name the user and the single job this feature performs?
> 2. Can I explain the request path from the interface to the server and model?
> 3. Are credentials kept out of distributed browser code and shared screenshots?
> 4. Do I validate incoming requests and the returned response structure?
> 5. Can the output be structurally valid while still being wrong, and have I checked for that?
> 6. Does the interface preserve missing information rather than inventing facts?
> 7. Do I have normal, incomplete, conflicting, and failure cases written down?
> 8. Can the user recover from a timeout or malformed response?
> 9. Are retries, duplicate requests, and usage bounded?
> 10. Have I decided what data is stored, sent, and logged?
> 11. Does a human review the result before any consequential action?
> 12. Can another person run the setup and understand the limitations?
>
> A Yes needs evidence. “The assistant said it handled that” is not evidence. Use a test, a direct inspection, or a documented manual check.
>
> Choose the highest-impact No or Unknown. Write the expected behavior. Create the smallest example that exposes the problem. Make one change. Rerun the example and the earlier cases. Record what improved and what did not.
>
> Example: a rough note says, “We might need accounts later.” A draft that states “Customer accounts are included” has turned uncertainty into scope. A useful revision keeps accounts as an open question until the user confirms them.
>
> Your next action should be specific enough to complete: “Add a case where accounts are uncertain and verify the draft asks a question.” Avoid “make the app more reliable.”
>
> This checklist is an educational starting point. Passing it does not establish suitability for every production, privacy, security, or regulated use case.
>
> If you want to practice this process with a guided project and feedback, the AI App Shipping Lab workshop is the next step.

Create a results sheet with columns Check, Evidence, Status, Next action, and Retest date. Include the ten synthetic cases from section 4 as an optional companion. Do not hide the useful checklist behind an invitation to purchase.

## Landing page copy

Headline:

> Your AI app works once. What should you check before sharing it?

Subheading:

> A practical checklist for JavaScript developers who can build a prototype and want to understand its behavior, failure cases, and release boundaries.

Bullets:

> Check the request path, output validation, missing information, recovery, data handling, and handoff.
>
> Use a fictional client-brief example to see the difference between plausible output and acceptable behavior.
>
> Leave with one concrete fix to make next.

Primary button:

> Send me the checklist

Delivery note:

> Enter your email to receive the checklist.

Separate optional marketing consent:

> Also send me Aadil’s practical AI development lessons and occasional workshop and membership invitations. I can unsubscribe at any time.

If your form cannot implement a separate optional subscription cleanly, use an immediately accessible checklist plus a clearly labeled newsletter signup. Do not treat silent consent as a requirement of receiving a file.

Author line:

> Created by Aadil Mallick, a software developer working across full-stack applications, AI evaluation, and practical engineering.

Trust material: your own labeled app demo and links to relevant public work. Add genuine learner evidence later with permission.

## The thank-you page

> Your checklist is ready.
>
> Open it now and choose one No or Unknown in your current project. If you want to see the process applied, watch the Client Brief Copilot walkthrough below.
>
> Want a live practice session? Register separately for “From AI Prototype to a Testable App.” The session teaches a small example and ends with an optional invitation to the paid lab.

Buttons: “Open the checklist” and “See workshop details.” Do not imply that submitting the first form registers the person for an event.

## Acceptance check

On a phone and a desktop, test form submission, delivery, consent choices, resource access, workshop registration, and unsubscribe handling using your own test contact. Check all wording against actual behavior.
