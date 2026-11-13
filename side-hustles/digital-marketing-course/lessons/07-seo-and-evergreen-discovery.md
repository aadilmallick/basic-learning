# 7. Search, evergreen content, and discoverability

[Previous](06-short-video-and-recording.md) · [Course home](../README.md) · [Next: email](08-email-and-customer-relationships.md)

## Reach people while they are looking for help

Social content usually interrupts a stream of other material. Search content meets someone who has expressed a question. A developer searching for a cancellation explanation may already be experiencing the problem your guide addresses. That does not guarantee a purchase, but the context can be more specific than a broad social impression.

Search engine optimization, or SEO, helps people and search systems understand and find useful pages. It is neither a payment for placement nor a guarantee of ranking. Google's starter guide emphasizes useful content, understandable organization, and crawlable pages; it also states that inclusion and ranking are not guaranteed. See [R1](../SOURCES.md#r1-google-search).

This lesson teaches how to choose search topics, write useful technical articles, connect them to a product, and diagnose discoverability problems. It assumes you have a product scope and can publish public pages somewhere. The exact publishing software is a separate implementation choice.

## Understand intent before choosing keywords

A keyword is a query or phrase used to search. Search intent is the task behind it. “What is a coroutine?” suggests a foundational explanation. “Kotlin cancellation exception swallowed” suggests a specific problem. “Best Kotlin concurrency course” suggests comparison. “Coroutine Field Guide download” suggests a known destination or product.

Do not assume that every query containing your subject has equal commercial value. A developer who needs a one-line syntax reminder may not want a complete course. A person comparing paid resources may need prerequisites, sample lessons, maintenance information, and price.

Group potential articles by the reader's task. Your first set might include one foundational concept, two recurring debugging questions, one end-to-end example, and one honest guide to choosing learning resources. This is a planning example rather than a fixed content requirement.

Avoid generating many near-identical pages for every wording variation. If two queries require the same explanation, one clear page may serve them. Create a separate page when the task, prerequisite level, or answer differs enough to justify it.

## Research topics from real questions

Start with the customer-research notes from Lesson 2. Add questions from your own support inbox, public discussions, and the gaps you noticed while studying competing explanations. Record the actual problem and why your treatment would be useful.

Search the question yourself and inspect the current results. What do the pages assume? Do they show working examples? Do they explain the failure mode? Are they solving a different interpretation of the query? Do not just count how often a word appears.

Volume estimates from keyword tools are estimates. Low reported volume does not prove that nobody has a valuable problem, especially for narrow technical questions. High volume does not establish purchase intent. At an early stage, fit with your offer and the quality of the explanation you can provide may be more actionable than an uncertain volume number.

Maintain a small topic table with query, intended reader, underlying task, proposed answer, relation to the product, and maintenance burden. You are selecting useful assets, not accumulating a list of keywords to insert into text.

## Build a complete answer path

A useful technical article should let a reader understand the setup, inspect the example, see the result, and connect it to the explanation. Begin with the answer or orientation, then teach the reasoning. A long personal introduction can delay the help the reader came for.

For an article about cancellation, an outline might be: the exact scenario, required setup, minimal example, observed behavior, ownership explanation, a variation that changes behavior, common misunderstandings, and a related next resource. The article should be useful even if the reader never buys.

Be explicit about scope. “This example uses this library version and this lifecycle arrangement” is more reliable than presenting one framework's behavior as universal. Maintain the examples when your claims depend on evolving software.

Use titles that name the task rather than promise mysterious shortcuts. “Tracing cancellation in a parent-child coroutine example” is descriptive. A page title is a label for a decision; it should help the right person recognize relevance.

## Give each page a coherent job

Your website can contain several complementary page types:

| Page | Reader's main task | Appropriate next step |
| --- | --- | --- |
| Concept explanation | Understand one idea | Related example or deeper guide |
| Debugging article | Diagnose a specific behavior | Worked lab or reference |
| Sample chapter | Evaluate teaching and fit | Subscribe with clear terms or buy |
| Product page | Understand and compare the offer | Inspect sample or purchase |
| Resource comparison | Choose among approaches | Visit the approach that fits |
| Update note | Understand changed assumptions | Get the relevant current material |

Do not force every article to sell at the same intensity. A focused next-step box can explain that the guide provides the complete sequence. The transition should follow from the reader's task.

If a comparison includes your own product, say that you made it. Represent alternatives fairly. Explain tradeoffs and link to their authoritative pages where useful. A comparison that secretly pretends to be independent can damage trust.

## Organize a small site clearly

A practical structure might include a home page, a product page, a sample page, an articles section, an about page, and support and policy information appropriate to your business. Navigation should help a reader find both learning resources and commercial terms.

Use descriptive links between related pages. A cancellation article can link to a prerequisite scope explanation and a deeper lab. The product page can link to the representative sample. Avoid isolated articles that no visible navigation reaches.

Technical discoverability has a few conceptual components: the page must be publicly accessible when you want it discovered, the content must be understandable, and search systems need ways to find the URL. Publishing systems differ in how they handle indexing controls, canonical URLs, and sitemaps. Check your actual system rather than assuming its default settings are correct.

Do not put paid content on a public URL and rely on obscurity to protect it. Discovery controls are not access control. Paid files need an appropriate delivery mechanism. The public sample should be deliberately chosen and clearly distinguished from the paid product.

## Read a minimal page example

This fragment illustrates page structure; it is not a complete storefront or an SEO guarantee:

```html
<title>Trace Kotlin cancellation with a parent-child example</title>
<meta name="description"
      content="Follow a small cancellation example, inspect its logs, and understand which scope owns the work.">
<h1>Trace Kotlin cancellation with a parent-child example</h1>
<p>This example assumes basic Kotlin and introductory coroutine usage.</p>
<h2>The scenario</h2>
<p>Describe the exact application behavior and relevant assumptions.</p>
<h2>The worked example</h2>
<p>Include the tested code, result, and explanation here.</p>
<p><a href="/coroutine-guide/sample">Read a sample of the complete debugging guide</a></p>
```

The title identifies the page's topic. The description is a proposed summary, not a guarantee of the text a search engine displays. The main heading orients the reader. Descriptive link text explains where the next page leads. The sample code's prose instructions are intentionally illustrative; replace them with the real article before publication.

You do not need to handwrite HTML if your publishing system provides these fields. You do need to understand what the fields communicate.

## Measure stages instead of only rankings

For search discovery, distinguish whether a page is discoverable, whether it receives impressions for relevant queries, whether people visit, whether they find the answer, and whether an appropriate portion takes a next step. A ranking change is only one observation in that sequence.

Use the search engine's site-owner tools where available to inspect indexing and query information. Compare that with your own aggregate visits and purchases. A page may rank for an unintended query, generate irrelevant visits, and produce poor sales. Increasing traffic to that page would not necessarily help the business.

Search performance varies with competition, query interpretation, seasonality, and changes outside your control. Evaluate a body of work over a suitable period rather than reacting to every daily fluctuation. The appropriate period depends on how much traffic and change you observe, not a universal number of days.

## Diagnose problems in order

If a new article receives no search visits, first check that it is publicly accessible and intended for indexing. Then check whether your site links to it and whether the search tool reports discovery. Next examine whether the query is relevant and whether your answer is meaningfully useful. Only then spend time on cosmetic keyword changes.

If the article gets impressions but few visits, inspect whether the title and summary communicate the intended task. If visits arrive but readers immediately leave, inspect answer relevance, loading behavior, and mobile readability. A quick exit is not automatically failure; the reader may have found a short answer. Use other evidence before interpreting it.

If article readers never inspect the sample, ask whether the article attracts the intended buyer and whether the next step adds something relevant. Do not bury a large sales banner in every paragraph to compensate for weak fit.

## Maintain content as a product asset

Technical content becomes stale. Keep a record of examples, library assumptions, publication dates, and update triggers. Prioritize maintenance for pages that attract relevant visitors or support important product claims.

An article that attracts a reader with an outdated explanation can damage the trust you hoped to build. When a concept changes, update both the free article and the paid material where necessary. If a page is obsolete, decide deliberately whether to revise it, clearly label it, or direct readers to a current explanation.

Avoid creating an enormous publication schedule you cannot maintain. A smaller collection of genuinely useful, current answers can be a better fit for a solo creator than a large archive of interchangeable posts.

## Optional application: create one durable entry point

Choose a real question from your research. Write a complete answer with an original example, clear assumptions, a useful title, and one relevant next step. Inspect it on mobile, verify the example, and confirm that the destination works. Add it to your content map with a future maintenance trigger.

Search becomes valuable when it connects a specific question to a useful answer and then, where appropriate, to a deeper learning product. It is a discovery channel you can improve, not a promise that your content will outrank every alternative.
