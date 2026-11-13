# Learn SEO and AEO by framework

> [@First Principles Coding Coach](plugin://gpt-0dbcc877a99734ed25e7e95afab64010@workspace-shared-with-me) Can you teach me SEO and AEO from beginnign to advanced, what a freelancer like me should know? Tailor it specifically to single page HTML websites, react-vite sites, nextjs, astro, etc. consider tradeoffs for each concept according to the different frameworks and how to assuage those issues for each (I know React has lots of problems with SEO due to client-side rendering, but anyway to assuage that or do I just have to move to a different framework), teach framework from a coding lens as well as a general lens, interleaving the concepts so i can understand how to best add SEO and AEO to any web app I create. Also in this modern landscape, point out useful free AI tools, skills, or SEO/AEO tools for testing SEO, improving SEO, performing research, etc., include them logically throughout the lessons.

<details><summary>6 previous messages</summary>

> I’ll use the First Principles Coding Coach skill to build a practical learning path, with code examples and framework tradeoffs woven into each stage. I’ll also check current search-engine guidance and tool offerings so the lessons reflect how SEO and AI search work today.
>
> <details><summary>Ran a command, searched the web</summary>
>
> - Ran `Get-Content -LiteralPath 'C:\Users\amallick.ENGINEERS\.codex\plugins\cache\workspace-shared-with-me\gpt-0dbcc877a99734ed25e7e95afab64010\0.3.1+bundle.053dd2c6e205b232cb2c9fb1f93d9a9b\skills\instructions\SKILL.md'`
>
> Searched the web for `site.developers.google.com/search AI features website SEO JavaScript rendering ...`
>
> Searched the web for `site.bing.com webmaster AI performance citations public preview ...`
>
> Searched the web for `https://developers.google.com/search/docs/appearance/ai-features`
>
> </details>
>
> The key distinction is React versus how you deliver a page’s HTML. You can keep React and make public pages much easier to crawl through prerendering or server rendering. I’m also separating documented search requirements from AEO tactics that are useful experiments but cannot guarantee citations.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site.developers.google.com/search llms.txt AI no special schema ...`
>
> <details><summary>Explored a file</summary>
>
> - Read `~/.agents/skills/find-skills/SKILL.md`
>
> </details>
>
> Searched the web for `https://pagespeed.web.dev/`
>
> </details>
>
> I’m using the Find Skills guidance to check reusable development skills alongside the free testing tools. One important update for the lessons: Google retired FAQ rich results in 2026, so older tutorials that sell FAQ markup as an easy visibility boost are out of date.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://skills.sh/`
>
> Searched the web for `'install'`
>
> Searched the web for `https://support.google.com/webmasters/answer/16984139`
>
> </details>
</details>

**You can keep React and achieve strong SEO.** The key is how each public URL delivers its content. A React site that sends useful HTML immediately has a very different starting point from one that sends an empty container and waits for JavaScript.

I’ll assume you know basic HTML, JavaScript, and React. We’ll use a fictional freelance business, **Northstar Web Studio**, to connect the marketing concepts to implementation. This is a condensed course, moving from fundamentals into architecture, debugging, and client work. Tool availability and search guidance were checked for **November 2026**.

**1. What SEO and AEO are trying to accomplish**

**SEO—search engine optimization—**helps people discover your website through search engines.

**AEO—answer engine optimization—**usually means making your information useful to systems that directly answer questions: featured snippets, AI search, conversational assistants, and similar experiences. You’ll also encounter **GEO**, or generative engine optimization. These industry terms overlap; there is no universal AEO certification or technical standard.

The business objectives can differ:

| Objective | Example |
|---|---|
| Search visibility | Your service page appears for “freelance React developer.” |
| Answer visibility | An answer cites your explanation of website maintenance costs. |
| Conversion | A visitor requests a proposal. |
| Business outcome | That proposal becomes a profitable project. |

A citation is useful exposure, but it does not automatically produce visits or customers.

For Google’s AI search features, established SEO remains the foundation. Google does not prescribe a special AEO schema or AI-specific writing format. Other platforms have their own retrieval systems and policies, so Google’s guidance does not describe every answer engine. [Google’s AI optimization guidance](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide)

The practical question throughout this course is:

**Can a system discover, retrieve, understand, and trust information that helps a potential customer?**

---

**2. Understand what happens between publishing and appearing in search**

Think of this as a sequence:

**Discover URL → fetch response → process/render content → consider indexing → select results for a query**

These are separate events.

- **Discovery:** The engine learns that a URL exists, often through links or a sitemap.
- **Fetching:** It requests that URL from your server.
- **Rendering:** Where supported, it executes JavaScript to understand the resulting page.
- **Indexing:** It decides whether and how to store the information.
- **Selection/ranking:** It decides whether the page is useful for a particular search.

Publishing a page does not guarantee indexing. Indexing does not guarantee meaningful visibility.

This explains a common debugging mistake:

> “My page has the right keywords, so why doesn’t it rank?”

Perhaps the crawler receives a login screen. Perhaps the URL returns an error. Perhaps Google selects another canonical URL. Perhaps the page is accessible but contributes little useful information.

**Diagnose earlier stages before changing later ones.**

For your first free tools, use browser developer tools and Google Search Console. Search Console connects your implementation to what Google actually observes; a generic SEO score cannot substitute for that.

---

**3. Rendering: the concept that determines your framework strategy**

A browser receives HTML before it runs your application.

A basic React–Vite SPA often starts with something resembling this intentionally simplified response:

```html
<body>
  <div id="root"></div>
  <script type="module" src="/assets/app.js"></script>
</body>
```

JavaScript must then create the page.

A prerendered page can instead arrive with:

```html
<body>
  <main>
    <h1>Website development for independent businesses</h1>
    <p>Northstar builds accessible websites and web applications.</p>
  </main>
  <script type="module" src="/assets/app.js"></script>
</body>
```

Both can use React. The second already contains useful content before JavaScript executes.

Here are the terms you need:

| Approach | When useful HTML is generated | Main tradeoff |
|---|---|---|
| Static HTML | When you author the file | Simple delivery; repeated content needs maintenance. |
| SSG / build-time prerendering | During a build | Fast delivery; changes require rebuilding or regeneration. |
| SSR | When a request is handled | Supports fresh data; adds server work and caching decisions. |
| CSR | In the visitor’s browser | Convenient for rich applications; important content depends on JavaScript. |
| Hydration | After HTML arrives | Adds interactivity to existing HTML; requires browser JavaScript. |

**Hydration does not mean “generate all content in the browser.”** It can attach React behavior to content already rendered elsewhere.

Google can render JavaScript, but rendering introduces additional dependencies and potential failures. Other bots may not execute JavaScript. Google itself recommends considering server rendering or prerendering. [Google’s JavaScript SEO guidance](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)

My architectural recommendations:

| Project | Practical starting choice |
|---|---|
| One focused landing page | Plain HTML or Astro |
| Portfolio, service site, publication | Astro; add React where interaction helps |
| Existing React–Vite marketing site | Investigate prerendering before rewriting |
| Public application with substantial dynamic functionality | Next.js or another React framework with server rendering |
| Private dashboard | React–Vite CSR is often entirely appropriate |
| SaaS marketing plus private product | Render public pages as HTML; use the app architecture appropriate for private screens |

These are engineering recommendations, not framework ranking bonuses.

---

**4. Research intent before creating routes**

A keyword is a clue to someone’s task.

Compare:

| Search | Likely task | Useful page |
|---|---|---|
| “what is website maintenance” | Understand a concept | Explanation |
| “website maintenance cost” | Evaluate a purchase | Pricing guide with assumptions |
| “website maintenance freelancer” | Find a provider | Service page |
| “Northstar maintenance” | Find a known business | Relevant branded page |

A service page should help someone evaluate and hire you. An educational page should explain the subject. Trying to make every page perform every task usually produces confusing content.

A useful research process:

1. Write down the customer’s problem in their words.
2. Search several versions of that problem.
3. Inspect which page types appear.
4. Record questions that existing results leave unanswered.
5. Decide what evidence or experience you can contribute.

For example, your maintenance article could explain what your actual maintenance agreement includes, with a sample task log. That is more useful than another generic definition.

Use **[Google Trends](https://trends.google.com/trends/)** to compare terminology and seasonality. Treat its values as relative interest, not absolute monthly search volume. Once a site has traffic, Search Console provides actual queries associated with that site.

AI can help group customer questions and draft research hypotheses. It cannot reliably invent search volumes, customer interviews, or competitive evidence.

**Framework connection:** Research determines your URL structure before React, Next.js, or Astro enters the decision.

---

**5. Single-page websites have a content limitation as well as a technical one**

First, separate two meanings:

- A **single-page website** has one main document.
- A **single-page application** can expose many URLs through client-side routing.

A React SPA can have fifty pages. An HTML website can have only one.

For a small portfolio, one document might work well:

```text
/
  #services
  #projects
  #process
  #contact
```

Those fragments help visitors navigate sections. They generally do not give you independent search landing pages with their own titles, descriptions, and content.

Suppose you want to explain four substantially different services:

```text
/services/website-development/
/services/accessibility-audits/
/services/website-maintenance/
/services/performance-optimization/
```

Separate URLs let each page answer a distinct customer need.

**Create separate pages when the user’s task warrants a separate answer.** Avoid generating dozens of near-identical pages merely to target keyword variations.

For a one-page site, choose one clear primary proposition and support it with services, examples, process, and contact information. Expand when there is enough meaningful material for additional pages.

This applies equally to HTML, React, Next.js, and Astro.

---

**6. Build the smallest useful SEO page in HTML**

Frameworks ultimately produce web documents. Understanding that output makes every framework easier to evaluate.

Here is a complete minimal page. The business and domain are examples:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Website Development | Northstar Web Studio</title>
    <meta
      name="description"
      content="Custom websites for independent businesses, with accessible design, clear content, and ongoing support."
    >
    <link rel="canonical" href="https://example.com/">
  </head>

  <body>
    <header>
      <a href="/">Northstar Web Studio</a>
      <nav aria-label="Main navigation">
        <a href="#services">Services</a>
        <a href="#contact">Contact</a>
      </nav>
    </header>

    <main>
      <h1>Custom websites for independent businesses</h1>
      <p>
        I design and develop accessible websites that make your
        services easier to understand and your business easier to contact.
      </p>

      <section id="services">
        <h2>Website development</h2>
        <p>
          Projects include content planning, development, deployment,
          and a documented handover.
        </p>
      </section>

      <section id="contact">
        <h2>Discuss your project</h2>
        <a href="mailto:hello@example.com">Email Northstar</a>
      </section>
    </main>
  </body>
</html>
```

Understand the responsibilities:

| Element | Responsibility |
|---|---|
| `<title>` | Names the document; can influence the search result title. |
| Meta description | Suggests a summary; engines may choose another snippet. |
| Canonical link | Signals the preferred URL for equivalent content. |
| `<h1>` | States the page’s main subject visibly. |
| `<h2>` | Organizes supporting sections. |
| `<a href>` | Provides an actual navigable link. |
| Semantic elements | Communicate document structure and support accessibility. |

Write titles and descriptions for clarity. Common character-count recommendations are editing heuristics, not guaranteed display limits.

A single clear H1 is a useful convention, not a magic ranking requirement. Meta keywords are unnecessary for Google. Open Graph metadata is useful for sharing previews, but it does not replace page content or technical accessibility. [Google’s SEO starter guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

For navigation, prefer real links to clickable elements that only run JavaScript. React Router’s `Link` and Next.js’s `Link` normally produce anchors; verify the rendered output when using custom components. [Crawlable link guidance](https://developers.google.com/search/docs/crawling-indexing/links-crawlable)

---

**7. Apply the same document principles to each framework**

**React–Vite: improve delivery without automatically rebuilding everything**

Adding metadata to Vite’s `index.html` helps a genuinely single-document website. It does not automatically give every client-side route unique initial HTML.

Likewise, a head-management library can update tags after JavaScript runs. It does not, by itself, implement server rendering or prerendering.

You have several options:

| Option | Appropriate situation | Cost |
|---|---|---|
| Improve the existing CSR site | Search is secondary; migration budget is limited | Some crawler and rendering dependence remains. |
| Prerender public routes | Services, articles, product landing pages change predictably | Build process must enumerate routes and obtain their data. |
| Add SSR | Public information needs request-time rendering | Server deployment, caching, error handling. |
| Use Astro around React components | Most of the site is content | Page composition changes; React components can often be reused. |
| Move into Next.js | Broader application requirements justify it | Routing, data access, and deployment migration. |

Vite supports SSR primitives, but its official SSR guide describes a low-level integration. For freelance delivery, a maintained framework often reduces the amount of infrastructure you must own. [Vite SSR documentation](https://vite.dev/guide/ssr)

For example, **in an already configured React Router Framework Mode project**, this configuration prerenders selected routes:

```ts
// react-router.config.ts
import type { Config } from "@react-router/dev/config";

export default {
  ssr: false,
  prerender: ["/", "/services", "/contact"],
} satisfies Config;
```

`ssr: false` disables a runtime rendering server; `prerender` still creates HTML during the build.

This is **not a drop-in setting for every Vite project**. Framework Mode requires its corresponding setup. Route content must also be available during prerendering: data loaded only in a browser effect will still be missing from the generated HTML. [React Router prerendering](https://reactrouter.com/how-to/pre-rendering)

[Vike](https://vike.dev/pre-rendering) is another maintained Vite-based option worth evaluating.

**Next.js: keep public content available during rendering**

In an existing App Router project, a complete page module can look like this:

```tsx
// app/services/page.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Website Development | Northstar Web Studio",
  description:
    "Accessible custom websites for independent businesses.",
  alternates: {
    canonical: "https://example.com/services",
  },
};

export default function ServicesPage() {
  return (
    <main>
      <h1>Website development for independent businesses</h1>
      <p>
        Projects include planning, development, deployment,
        and a documented handover.
      </p>
      <a href="/contact">Discuss your project</a>
    </main>
  );
}
```

The metadata export describes the document. The component provides its visible content.

Use `generateMetadata` when metadata depends on route data. Keep metadata exports in Server Components. [Next.js metadata API](https://nextjs.org/docs/app/api-reference/functions/generate-metadata)

Two important distinctions:

- Server Components and static/request-time rendering are different concepts.
- `"use client"` does **not** automatically mean a component has no initial HTML.

A Client Component can participate in initial HTML rendering. However, content fetched only in `useEffect` arrives after hydration. Keep the core public description available during rendering, and put interactive behavior where needed. [Next.js Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)

**Astro: render content and add interaction selectively**

A complete Astro page can express the same document:

```astro
---
// src/pages/services.astro
const title = "Website Development | Northstar Web Studio";
const description =
  "Accessible custom websites for independent businesses.";
---

<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link
      rel="canonical"
      href="https://example.com/services"
    />
  </head>
  <body>
    <main>
      <h1>Website development for independent businesses</h1>
      <p>
        Projects include planning, development, deployment,
        and a documented handover.
      </p>
      <a href="/contact">Discuss your project</a>
    </main>
  </body>
</html>
```

In a larger site, move the shared document structure into a layout.

Astro’s islands architecture lets you add interactive components without making the whole document depend on their JavaScript. [Astro islands](https://docs.astro.build/en/concepts/islands/)

With the React integration installed, these illustrative component usages have different behavior:

```astro
<PricingCalculator client:visible />
```

This renders the component’s HTML and hydrates it when appropriate.

```astro
<PricingCalculator client:only="react" />
```

This skips server rendering for that component.

Use `client:only` deliberately. It is a poor place for the only copy of your essential service description. [Astro framework component guidance](https://docs.astro.build/en/guides/framework-components/)

---

**8. Learn the controls that govern crawling, indexing, and duplication**

These controls solve different problems:

| Mechanism | What it does | Frequent mistake |
|---|---|---|
| `robots.txt` | Requests crawler access restrictions | Treating it as a guaranteed way to remove a URL from search. |
| `noindex` | Requests exclusion from the index | Blocking crawling so the engine cannot see the directive. |
| Canonical | Signals the preferred equivalent URL | Pointing every service page to the homepage. |
| Redirect | Moves requests to another URL | Redirecting every missing page to the homepage. |
| Sitemap | Lists URLs you want discovered | Assuming inclusion guarantees indexing. |

A crawlable page can carry:

```html
<meta name="robots" content="noindex">
```

For example, this may suit a public confirmation page that should not appear in search. It is not access control. Private data needs authentication. [Robots.txt guidance](https://developers.google.com/search/docs/crawling-indexing/robots/intro)

A canonical is a signal, not an absolute command. Use it for equivalent versions, such as a normal URL and a tracking-parameter version. Distinct service pages should generally identify their own preferred URLs. [Canonicalization guidance](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls)

Framework implementation differs:

- **HTML:** Maintain files directly or generate them.
- **Vite/Astro:** Public assets can supply static robots and sitemap files; larger sites benefit from generation.
- **Next.js:** Use its robots and sitemap file conventions.
- **Every framework:** Validate the deployed response, including hosting rules.

A sitemap should list preferred, indexable URLs that successfully load. For a tiny, well-linked website, it is a discovery aid rather than the most important task. [Sitemap guidance](https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview)

**Watch SPA hosting fallbacks.** Serving your app for every unknown URL can turn `/this-page-does-not-exist` into a `200` response. A visible “not found” message does not necessarily fix the HTTP response.

Learn these status codes:

- `200`: Successful content.
- `301` / `308`: Permanent move.
- `404` / `410`: Missing or removed content.
- `5xx`: Server failure.

Error content delivered as success can be treated as a soft 404. [Google’s status-code guidance](https://developers.google.com/crawling/docs/troubleshooting/http-status-codes)

---

**9. Make information useful for answers**

Suppose a potential customer asks:

> “Does website maintenance include redesigning my website?”

A useful answer could be:

> Website maintenance usually covers keeping an existing website operational: updates, backups, monitoring, and agreed fixes. A redesign changes the site’s structure or appearance and is normally scoped separately. At Northstar, small content edits are included up to the allowance in your agreement.

This works because it defines the concept, establishes a boundary, and supplies the business-specific detail.

A practical writing pattern is:

**Question or task → direct response → explanation → evidence or example → limitations**

Use this when it helps readers. It is not an algorithmic requirement, and there is no universal “perfect answer length.”

Useful additions include:

- Original project examples.
- Specific inclusions and exclusions.
- Comparison tables with explicit criteria.
- Dates for time-sensitive claims.
- Named authors and relevant experience.
- Sources supporting factual statements.
- Clear business identity and contact information.

Google’s guidance emphasizes helpful, reliable content and evidence of experience and expertise. E-E-A-T is a quality framework, not a score you can insert into metadata. [Helpful content guidance](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)

**Framework connection:** Keep these answers in crawlable page content. An FAQ whose text already exists in HTML and expands on click has a different dependency from an answer fetched only after the click.

Two current AEO misconceptions:

- **`llms.txt` is not a Google ranking requirement.** Google says it does not use it to improve search visibility. Other services may use such files.
- **FAQ markup does not unlock Google FAQ rich results today.** Google stopped displaying that feature in May 2026. Helpful FAQ content can still serve readers. [AI guidance](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide), [Google’s documentation updates](https://developers.google.com/search/updates)

---

**10. Structured data describes facts already present**

Structured data provides explicit machine-readable descriptions of entities and content.

For example, this intentionally small HTML fragment describes the fictional business:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Northstar Web Studio",
  "url": "https://example.com/"
}
</script>
```

- `application/ld+json` identifies data rather than executable JavaScript.
- `@context` identifies the vocabulary.
- `@type` identifies the kind of entity.
- The remaining fields describe it.

Choose types that match reality: an organization, article, product, local business, and so on. Schema.org supports many concepts that do not have a corresponding Google rich result.

Structured data can support eligible search features. It does not guarantee those features, rankings, or AI citations. Never invent reviews, credentials, prices, or business locations. [Google’s structured-data introduction](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data)

Use both free validators for different purposes:

| Tool | Purpose |
|---|---|
| [Schema Markup Validator](https://validator.schema.org/) | Validate Schema.org markup broadly. |
| [Google Rich Results Test](https://search.google.com/test/rich-results) | Check supported Google rich-result markup and issues. |

For larger applications, generate visible content, metadata, and structured data from the same underlying record. This reduces contradictions.

When inserting dynamic JSON-LD into a script element, use safe serialization appropriate to the framework; raw untrusted strings can introduce injection vulnerabilities.

---

**11. Performance: measure the actual bottleneck**

A page can deliver HTML immediately and still perform poorly because of huge images, excessive JavaScript, or third-party scripts.

The current Core Web Vitals are:

| Metric | What it measures | “Good” threshold |
|---|---|---|
| LCP | Main content loading | ≤ 2.5 seconds |
| INP | Responsiveness to interactions | ≤ 200 milliseconds |
| CLS | Unexpected layout movement | ≤ 0.1 |

Evaluate field performance at the 75th percentile. These are experience targets, not promises of rankings. [Core Web Vitals reporting](https://support.google.com/webmasters/answer/9205520)

Use **[PageSpeed Insights](https://pagespeed.web.dev/)** and browser Lighthouse:

- **Lab data** helps reproduce and diagnose problems.
- **Field data** reflects actual visitors, when sufficient data exists.
- A new site may have no field data.
- A high Lighthouse SEO score does not prove search demand, indexing, authority, or conversions.

Common fixes by stack:

| Stack | Typical problem | Practical response |
|---|---|---|
| HTML | Oversized hero image, blocking scripts | Resize/compress images; defer nonessential scripts. |
| React–Vite | Large application bundle | Split routes and heavy tools; reconsider unnecessary dependencies. |
| Next.js | Excessive client JavaScript or slow server data | Reduce client boundaries; investigate data waterfalls and caching. |
| Astro | Too many hydrated islands | Hydrate only components that require browser behavior. |

Across all four, reserve image dimensions, avoid lazy-loading the primary hero image, and inspect chat widgets, analytics, fonts, and animation libraries.

A useful optional agent skill here is **[Vercel React Best Practices](https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices)**. It covers React/Next.js performance rather than complete SEO. The directory showed approximately 864,000 installs when checked; its official repository had approximately 33,400 stars. Popularity is supporting context, not proof that every recommendation suits your project. [Repository](https://github.com/vercel-labs/agent-skills)

Its listed installation command is:

```bash
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices
```

Installing the skill is separate from using it effectively: give it a measured problem and request evidence for proposed changes.

---

**12. Build credibility beyond your code**

A technically correct website still needs a reason to be selected.

For freelancers, useful assets include:

- Case studies explaining the problem, constraints, decisions, and results.
- Demonstrations of work you actually performed.
- Accurate service descriptions.
- Authentic client feedback used with permission.
- Relevant partnerships, directories, or editorial coverage.
- Useful resources that people have a reason to reference.

Avoid buying bulk links or manufacturing mentions. Generating large quantities of low-value pages can also create spam problems, whether the text was produced by a person or AI. [Google spam policies](https://developers.google.com/search/docs/essentials/spam-policies)

For local clients, the website is only part of the work. Accurate Business Profile information, appropriate categories, genuine reviews, and location information matter. Local results also depend on distance, which frontend code cannot control. [Google local ranking guidance](https://support.google.com/business/answer/7091)

Do not create fake offices or duplicate city pages with only the place name changed.

---

**13. Advanced SEO is managing systems and exceptions**

Once the basics are sound, the harder work involves keeping thousands of decisions consistent.

| Situation | What to reason about | Framework implications |
|---|---|---|
| CMS publishes new content | Does a real URL appear with content, links, and metadata? | Static builds need rebuild triggers; server-rendered sites need correct cache invalidation. |
| Product filters create many URLs | Which combinations deserve independent search pages? | Define URL and indexing policy before implementing filters. |
| Multiple languages | Can each version be discovered at its own URL? | Generate localized routes and reciprocal `hreflang`; avoid browser-only language swaps. |
| Infinite scrolling | Can additional items be reached without scrolling scripts? | Provide linked, addressable pages where appropriate. |
| Large catalogs | Are templates producing useful, distinct pages? | Monitor indexability and quality by template, not only individual URL. |
| Framework migration | Do old URLs still reach equivalent content? | Preserve paths where possible; map permanent redirects and update internal references. |
| Personalized content | What does an anonymous crawler receive? | Keep stable public information available without a login or personalized state. |

For translated equivalents, each language version should reference itself and the other versions through appropriate `hreflang` annotations. Do not canonicalize every translation to the English page. [Localized-page guidance](https://developers.google.com/search/docs/specialty/international/localized-versions)

**Caching deserves particular attention.** If a product is removed in your database but the cached page, sitemap, and metadata still advertise it, the system is inconsistent.

For static sites, freshness usually depends on rebuilding. For server-rendered sites, freshness depends on rendering and cache policies. Choose based on how quickly the information must change.

For migrations, establish a baseline before changing frameworks: URLs, traffic, content, metadata, status codes, and redirects. A migration can introduce URL and content changes that have much greater consequences than the framework choice itself.

---

**14. Test in layers and interpret the evidence**

Use the smallest tool that answers the question:

| Question | Useful free tool |
|---|---|
| What did the server send? | Browser Network panel or View Source |
| What exists after JavaScript runs? | Browser Elements panel |
| What does Google observe? | Search Console URL Inspection |
| Are titles, links, and redirects consistent across pages? | Screaming Frog’s free crawler |
| What is slow? | PageSpeed Insights and Lighthouse |
| Is structured data valid? | Schema Validator and Rich Results Test |
| Which searches produce visibility? | Search Console performance reporting |
| Which pages appear in supported AI experiences? | Google and Bing’s first-party AI reports |

[Screaming Frog’s free version](https://www.screamingfrog.co.uk/seo-spider/) crawls up to 500 URLs. Its JavaScript rendering is a paid capability, so do not mistake a free HTML crawl for a full rendered-SPA audit.

[Ahrefs’ free tools](https://help.ahrefs.com/en/articles/13002606-what-can-i-use-for-free-in-ahrefs) can supplement audits and research; access and limits differ by feature.

For current AEO measurement:

- Google documents a **Generative AI performance report** for AI Overviews and AI Mode impressions. It may not appear for a site with insufficient impressions. [Google report documentation](https://support.google.com/webmasters/answer/16984139)
- Bing’s **AI Performance** report covers citations in supported Microsoft and partner experiences. Its scope is not every AI platform. [Bing report documentation](https://www.bing.com/webmasters/help/ai-performance-9f8e7d6c)

Track business outcomes separately:

**Visibility → visits → qualified enquiries → customers**

If you manually test AI answers, record the prompt, platform, date, locale, and cited URLs. Repeated samples are exploratory evidence. One answer is not a stable ranking report.

---

**15. Use free AI tools for bounded, verifiable work**

**[Google AI Studio](https://aistudio.google.com/)** is useful for experimenting with research synthesis, content analysis, and code review. Free access and API allowances depend on model, region, and current limits; API billing is a separate consideration. [Current pricing and availability](https://ai.google.dev/gemini-api/docs/pricing)

Good tasks for an AI assistant include:

| Task | Give it | Verify afterward |
|---|---|---|
| Group search intent | Actual queries and customer questions | Whether the proposed groups match real tasks |
| Improve metadata | Page content and audience | Accuracy, uniqueness, and deployed output |
| Find content gaps | Existing copy and verified business facts | Whether the missing information is genuinely useful |
| Diagnose rendering | Initial HTML, rendered HTML, framework details | Production responses and crawler tools |
| Draft structured data | Verified entity/product records | Schema validity and factual consistency |
| Analyze audit exports | Crawl or Search Console data | Calculations, samples, and causal claims |

A reusable audit prompt:

Audit this public page using its initial HTML, rendered HTML, response headers, and visible content.

Check content availability, metadata, links, status codes, indexing directives, canonical URLs, structured data, and performance dependencies.

For each finding, provide the observed evidence, likely consequence, smallest appropriate fix for this framework, and a way to verify it.

Separate confirmed defects from hypotheses. Do not infer rankings, search volumes, backlinks, or AI citations from the source code.

That prompt works because it asks for observations before recommendations.

Use AI to accelerate analysis and implementation. Keep client facts, measurements, and final editorial judgment grounded in evidence.

---

**16. What to deliver as a freelancer**

A defensible SEO engagement has concrete acceptance criteria.

| Stage | Deliverable |
|---|---|
| Discovery | Audience, business objectives, search intent, proposed pages |
| Architecture | URL structure and rendering decision |
| Implementation | Useful content, metadata, links, status behavior, indexing controls |
| Validation | Production crawl, rendering checks, structured-data checks, performance findings |
| Launch | Search Console setup, sitemap submission where appropriate, conversion checks |
| Maintenance | Publishing checks, content updates, reporting, regression fixes |

Separate your scope into technical implementation, research/content, and ongoing monitoring. They require different work and responsibilities.

Promise deliverables you control: correct implementation, documented research, evidence-based recommendations, and measurement. Search positions and AI citations remain external outcomes.

For your own projects, use this decision rule:

**Render the public information people need, add JavaScript for useful interaction, and validate what the deployed URL actually returns.** A plain HTML page, a prerendered React route, a Next.js page, and an Astro page can all satisfy that requirement.

Applied the [First Principles Coding Coach skill](~/.codex/plugins/cache/workspace-shared-with-me/gpt-0dbcc877a99734ed25e7e95afab64010/0.3.1+bundle.053dd2c6e205b232cb2c9fb1f93d9a9b/skills/instructions/SKILL.md).

> continue

<details><summary>2 previous messages</summary>

> Let’s go deeper into diagnosing rendering problems. We’ll follow a page from the server response to the browser, then compare how to fix missing content in HTML, React–Vite, Next.js, and Astro.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics`
>
> </details>
</details>

Let’s turn the overview into a practical skill: **determining whether a public page’s important content is available to search systems—and fixing the cause when it isn’t.**

We’ll continue with Northstar Web Studio. Imagine its `/services` page looks perfect in your browser, but you’re unsure whether its React implementation is suitable for SEO and AEO.

**Start with three different representations of the page**

A webpage exists in several forms:

| Representation | What it contains | How to inspect it |
|---|---|---|
| Server response | HTML delivered when the URL is requested | Developer Tools → Network → document request → Response |
| Browser DOM | The document after the browser processes HTML and JavaScript | Developer Tools → Elements |
| Search engine’s processed page | What that engine retrieved and rendered | Google Search Console → URL Inspection |

The **DOM**, or Document Object Model, is the browser’s representation of the document. JavaScript can add, remove, or change its elements.

That distinction explains why inspecting Elements alone can mislead you. You might see a complete service description that did not exist until several scripts and an API request finished.

Google can process JavaScript, but rendering depends on resources being accessible and code succeeding. Server rendering or prerendering can reduce those dependencies. [Google’s JavaScript SEO guidance](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)

**A useful first inspection**

On a deployed public page:

1. Open Developer Tools and select **Network**.
2. Reload the page.
3. Select the main request, usually identified as **document**.
4. Check its status and open **Response**.
5. Look for the heading, service description, and important links.
6. Compare that response with **Elements**.

You’re looking for actual page markup, such as:

```html
<h1>Website maintenance for independent businesses</h1>
<p>Monthly maintenance includes backups and agreed updates.</p>
```

Finding the same words inside a JavaScript bundle or serialized data block is weaker evidence: that does not establish that they were delivered as readable page content.

Also, HTML may stream in several pieces. “Server-rendered HTML” does not require everything to arrive in the first network packet.

Here is how to interpret common findings:

| Observation | Likely explanation | Next investigation |
|---|---|---|
| Response and Elements contain the content | HTML delivery is working for this content | Indexing, relevance, quality, and other factors |
| Response contains an empty root; Elements contains content | Browser rendering creates the page | Prerendering or SSR options |
| Response contains headings; description appears later | Some content depends on browser-side data | Where and when that data loads |
| Response contains a login or challenge screen | Anonymous access is restricted | Authentication, hosting, or bot protection |
| A nonexistent URL returns your normal app with `200` | Hosting fallback handles every path | Route and HTTP error behavior |

These are diagnostic clues. None independently proves that a page will or will not rank.

**The subtle problem: adding SSR doesn’t fix every browser dependency**

Consider this complete `App.jsx` example for an existing React–Vite project:

```jsx
import { useEffect, useState } from "react";

export default function App() {
  const [service, setService] = useState(null);

  useEffect(() => {
    // Simulates obtaining data after browser rendering.
    Promise.resolve({
      title: "Website maintenance",
      description: "Backups, updates, and agreed website fixes.",
    }).then(setService);
  }, []);

  if (!service) {
    return <p>Loading service details…</p>;
  }

  return (
    <main>
      <h1>{service.title}</h1>
      <p>{service.description}</p>
    </main>
  );
}
```

Follow the sequence:

1. `useState(null)` establishes the initial value.
2. The initial render sees `service === null`.
3. React returns the loading paragraph.
4. In the browser, `useEffect` runs.
5. The promise resolves and `setService` updates state.
6. React renders the service description.

The example uses a promise to isolate the timing issue. A real implementation might fetch from a CMS or API.

**Effects do not run during server rendering.** If you simply add server rendering around this component, its server output still contains the loading state.

There are therefore two separate questions:

- **Can your setup generate HTML outside the browser?**
- **Is the necessary content available when that generation happens?**

Both must be addressed.

**Move stable content into the rendering process**

For information you already know, you can remove the effect:

```jsx
const service = {
  title: "Website maintenance",
  description: "Backups, updates, and agreed website fixes.",
};

export default function App() {
  return (
    <main>
      <h1>{service.title}</h1>
      <p>{service.description}</p>
    </main>
  );
}
```

This component can immediately render the service information wherever React executes it.

However, **a conventional Vite CSR setup still executes that rendering in the browser**. Changing the component improves its data availability; you still need prerendering or SSR to deliver its markup in the HTML response.

For CMS content, the equivalent solution is to obtain the data during a build or server request and pass it into the component.

| Content source | Useful approach |
|---|---|
| Text committed with your code | Import or define it before rendering |
| CMS content updated occasionally | Fetch during the build and rebuild after publishing |
| Frequently changing public records | Fetch during server rendering with a suitable caching policy |
| Visitor’s private account details | Fetch securely for that visitor; public indexing usually isn’t needed |

Notice that the decision comes from the content’s requirements.

**How this translates across your frameworks**

| Stack | Where to make public content available | Common failure |
|---|---|---|
| Plain HTML | Directly in the document | Replacing essential text with JavaScript-only widgets |
| React–Vite with prerendering | During build-time route rendering | Data remains in `useEffect` |
| React with SSR | During request rendering | Server sends only the initial loading state |
| Next.js App Router | During server rendering or prerendering | Essential content fetched only after hydration |
| Astro | In page/component rendering at build or request time | Essential content placed inside a client-only component |

React Router’s Framework Mode supports prerendering routes and running their loaders during that process. That gives public route data a place to load before HTML is generated. It requires adopting the corresponding framework setup. [React Router prerendering](https://reactrouter.com/how-to/pre-rendering)

In Next.js, public content can remain in a Server Component while a smaller Client Component handles an interactive feature. Client Components can also receive initial server-rendered HTML; the important distinction is whether the content depends on browser-only execution. [Next.js component guidance](https://nextjs.org/docs/app/getting-started/server-and-client-components)

In Astro, framework components can render to HTML and receive client hydration when necessary. `client:only` explicitly skips server rendering for that component. [Astro framework components](https://docs.astro.build/en/guides/framework-components/)

**Separate the information from the interaction**

Suppose your service page includes a maintenance-cost calculator.

The page has two responsibilities:

| Responsibility | Example |
|---|---|
| Explain the service | What maintenance includes, exclusions, pricing assumptions |
| Respond to visitor input | Calculate an estimate from selected options |

A robust arrangement is:

```text
Service page
├── Heading and service explanation → delivered as HTML
├── Inclusions and exclusions      → delivered as HTML
├── Pricing assumptions            → delivered as HTML
├── Interactive calculator         → browser behavior
└── Contact link                   → delivered as HTML
```

The calculator can enhance the page without being the only way to discover what the service costs or includes.

This is particularly useful for AEO. A system researching maintenance costs can retrieve your explanation and assumptions even if it does not operate your calculator.

The same pattern works for product configurators, comparison tools, booking interfaces, and interactive portfolios.

**When should you keep CSR?**

CSR remains useful. The decision depends on what must be discoverable.

Imagine a SaaS application:

```text
/                         Marketing
/features                 Public product information
/pricing                  Public pricing
/guides/exporting-data    Public documentation
/app/projects             Private workspace
/app/settings             Private settings
```

The first four routes benefit from reliable public content delivery. The private workspace has different priorities: authentication, responsiveness, and application state.

You can use different rendering strategies for these areas. You do not need to migrate a functioning private React application merely because its marketing pages need better delivery.

For an existing freelance project, evaluate the smallest appropriate change:

| Situation | Reasonable action |
|---|---|
| Five stable public pages | Prerender those pages |
| Content site with a few interactive widgets | Consider Astro with reusable React components |
| Public data changes frequently | Consider SSR and explicit caching |
| Mostly private application | Keep CSR where appropriate; improve public entry pages separately |
| Existing site already delivers useful HTML | Investigate other causes before changing frameworks |

**Understand the freshness tradeoff before promising a solution**

Suppose you prerender a maintenance page on Monday. The client changes its package in the CMS on Tuesday.

Without a rebuild, the deployed HTML can continue describing Monday’s package.

If browser JavaScript then fetches Tuesday’s data, visitors may see newer information than a reader relying on the generated HTML.

That creates a consistency problem.

Your implementation needs an explicit publishing rule:

- **Static approach:** CMS publishing triggers a successful rebuild and deployment.
- **Server approach:** Requests obtain sufficiently fresh data through a defined cache policy.
- **Mixed approach:** Public facts remain consistent across generated HTML and browser updates.

Ask a concrete engineering question: **How long is it acceptable for this information to remain outdated?**

An author biography may tolerate a delay. A limited-time offer or product availability may require a different policy.

**Use free tools in the right order**

For this particular problem, you can learn a great deal without purchasing an SEO platform:

1. **Network Response:** Establish what the server sends.
2. **Elements:** Identify what JavaScript adds.
3. **Disable JavaScript and reload:** Explore which content and navigation depend on it.
4. **Console and Network errors:** Find failed scripts and data requests.
5. **Search Console URL Inspection:** Compare your observations with Google’s processing.

Disabling JavaScript is a useful experiment, but it does **not** simulate Googlebot exactly. Likewise, changing your browser’s user-agent string does not prove how a real crawler is treated.

An AI assistant can help interpret the evidence. Supply the response HTML, rendered markup, relevant component, and data-loading code. Ask it to identify when each important piece becomes available. That is much more actionable than asking whether “React is bad for SEO.”

For your next public page, the practical acceptance criterion is:

> A direct visit to every intended public URL delivers its essential explanation and links through the chosen rendering strategy, with a defined process for keeping that content current.

Once that is established, content research and metadata improvements have a reliable technical foundation.

> continue

<details><summary>2 previous messages</summary>

> Next we’ll connect search intent to page structure: deciding which pages a client needs, what each page should answer, and how those decisions become URLs, content, and metadata across your frameworks.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/appearance/title-link`
>
> </details>
</details>

Now that you can inspect how content reaches a crawler, the next question is **what content deserves a page in the first place**.

This decision affects your search strategy, navigation, routes, components, and client budget.

**Search intent connects a phrase to a task**

Suppose Northstar offers website maintenance. A potential customer might search for:

| Search phrase | What the person likely needs |
|---|---|
| “what is website maintenance” | An explanation |
| “website maintenance checklist” | Instructions they can follow |
| “website maintenance cost” | Pricing context |
| “website maintenance freelancer” | Someone to hire |
| “Northstar website maintenance” | Information about a particular provider |

These are hypotheses about intent. You validate them by examining search results and talking to customers.

A technically excellent page can still perform poorly if it answers a different question from the one people are asking.

For example, someone looking for a checklist may leave a page that immediately asks them to book a consultation. Someone trying to hire you needs more than a definition.

**Research the task before writing the page**

A practical research process for a small freelance project:

1. **Collect customer language.** Look at enquiries, sales conversations, support questions, and the client’s own explanations.
2. **Write a small set of searches.** Include problems, comparisons, costs, and provider searches.
3. **Inspect the results.** Notice whether they predominantly contain service pages, tutorials, directories, videos, or tools.
4. **Identify missing information.** Ask what you can explain with greater specificity or better evidence.
5. **Choose the page’s job.** Decide what the visitor should understand or accomplish.

Search results are evidence about what engines currently select. They are not instructions to copy competitors.

For a local client, inspect searches in the relevant location. For a technical product, the intended audience’s terminology matters: a developer and a business owner may describe the same problem differently.

Use **Google Trends** when comparing terms or investigating seasonality. Its 0–100 values represent normalized relative interest, rather than a count of searches. A value of zero can also reflect insufficient data. [How Trends data works](https://support.google.com/trends/answer/4365533?hl=en)

For an existing website, Search Console queries help reveal how people already encounter its pages.

**One page can answer several related questions**

You do not need a separate URL for every search phrase.

These searches could reasonably lead to the same service page:

```text
website maintenance services
freelance website maintenance
monthly website maintenance
website maintenance provider
```

The visitor’s task is broadly similar: evaluate a provider.

That page can explain the service, describe packages, establish credibility, and offer a relevant next step.

By contrast, a detailed maintenance checklist may warrant its own page because it serves a different task.

A useful decision test is:

> Would separating this material make it easier for a visitor to complete a distinct task?

Avoid creating pages solely because a keyword tool lists another phrase.

**Turn the research into a page map**

For Northstar, an initial map might look like this:

| URL | Main job | Supporting evidence | Visitor’s next step |
|---|---|---|---|
| `/services/website-maintenance` | Evaluate the service | Scope, exclusions, process, examples | Request a maintenance proposal |
| `/guides/website-maintenance-checklist` | Understand maintenance tasks | Task explanations and examples | Use the checklist; explore assistance |
| `/guides/website-maintenance-cost` | Understand pricing | Cost drivers, assumptions, sample scope | Compare options |
| `/work/maintenance-case-study` | Assess experience | Actual work and documented outcomes | Review the relevant service |

This is a **page map**: a connection between audience needs and website structure.

It also creates natural internal links. The pricing guide can link to the service page when discussing available help. The service page can link to the case study as evidence.

These links should help readers continue their task. You don’t need to force the same exact keyword into every link.

**Handle a one-page budget deliberately**

Suppose the client can afford only one page.

You can still cover a focused buying task:

```text
Main proposition
Service inclusions
Who the service suits
Process
Evidence
Pricing approach
Common questions
Contact
```

The tradeoff is that everything shares one document’s title, primary URL, and overall context.

A substantial educational guide may eventually deserve a separate URL. You can plan for that without expanding the initial scope.

Across frameworks:

| Stack | How the page map becomes implementation |
|---|---|
| Plain HTML | Separate documents or directories |
| React–Vite | Routes plus an explicit content-delivery strategy |
| Next.js | Route segments and page modules |
| Astro | Page files and generated routes |

**Adding routes does not automatically produce useful initial HTML.** Apply the rendering checks from the previous lesson to each public route.

**Write the visible answer before polishing metadata**

Consider this introduction:

> We deliver innovative, comprehensive website maintenance solutions tailored to your unique digital needs.

It leaves important questions unanswered.

A more informative fictional example:

> Northstar maintains existing small-business websites through scheduled updates, backups, and agreed fixes. Before work begins, we document your platform, maintenance tasks, response arrangements, and exclusions. Major redesigns are scoped separately.

The second version establishes:

- What the service covers.
- Who it serves.
- How scope is agreed.
- A meaningful boundary.

For a real client, verify every statement. Don’t let generated copy invent response times, certifications, guarantees, or services.

Google’s guidance encourages useful content with original information, clear sourcing, and evidence of relevant experience. [Helpful-content guidance](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)

**Connect that content to AEO**

A person or answer engine may need one specific detail:

> Does this maintenance service include redesigns?

Make the answer explicit in the page:

```html
<section aria-labelledby="redesign-question">
  <h2 id="redesign-question">
    Does maintenance include a website redesign?
  </h2>
  <p>
    Major redesigns are scoped separately. Your maintenance agreement
    lists the updates and fixes included in your package.
  </p>
</section>
```

This fragment gives the answer a clear context. It works in plain HTML and can be rendered through React, Next.js, or Astro.

Its usefulness comes from the explicit information. Neither the heading nor the question format guarantees an AI citation.

Also notice that this answer describes **Northstar’s service**. It does not make an unsupported claim about every maintenance provider.

That distinction matters: precise scope makes content easier to interpret accurately.

**Make titles, headings, and descriptions agree**

These elements have related but different jobs:

| Element | Example | Job |
|---|---|---|
| Document title | `Website Maintenance Services \| Northstar` | Identify the page in browser and search contexts |
| H1 | `Website maintenance for small businesses` | Introduce the visible page |
| Meta description | `Explore Northstar’s maintenance scope, process, and exclusions. Request a proposal for your existing website.` | Suggest a useful search summary |
| Opening paragraph | Concrete explanation of the service | Fulfil the promise |

They can use different wording while remaining consistent.

Avoid this mismatch:

```text
Title: Free Website Maintenance Checklist
H1: Hire Northstar
Content: A sales page with no checklist
```

The problem is a broken promise to the visitor.

Google generates search titles from several sources, including the title element and prominent page content. A title you specify can be changed in the displayed result. [Title-link guidance](https://developers.google.com/search/docs/appearance/title-link)

Google also generates query-dependent snippets, primarily from page content, sometimes using the meta description. A rewritten snippet is not automatically an implementation defect. [Snippet guidance](https://developers.google.com/search/docs/appearance/snippet)

**Represent page decisions as data when reuse helps**

In a JavaScript project, you might keep a small service record:

```js
// An illustrative module; it can be imported by page code.
export const maintenancePage = {
  path: "/services/website-maintenance",
  title: "Website Maintenance Services | Northstar",
  heading: "Website maintenance for small businesses",
  description:
    "Explore Northstar’s maintenance scope, process, and exclusions.",
  introduction:
    "Northstar maintains existing small-business websites through " +
    "scheduled updates, backups, and agreed fixes.",
};
```

Each field has a deliberate responsibility:

- `path` identifies the route.
- `title` describes the document.
- `heading` introduces the visible content.
- `description` provides a metadata summary.
- `introduction` supplies visible explanatory text.

This avoids accidentally using a short navigation label everywhere.

How you consume it depends on the stack:

| Stack | Appropriate use |
|---|---|
| Plain HTML | Write the corresponding values into the document; introduce templating when repetition justifies it |
| React–Vite | Render visible fields and manage metadata; prerender or server-render where required |
| Next.js | Use the record in page content and the metadata API |
| Astro | Import it during page rendering and pass values to a layout |

The data object itself provides no SEO benefit until the deployed document uses it correctly.

**Recognize problematic page overlap**

“Keyword cannibalization” is often used too broadly. Two pages mentioning maintenance are not automatically competing in a harmful way.

A more useful question is whether they offer distinct value.

Compare:

```text
/services/website-maintenance
/services/monthly-website-maintenance
/services/website-maintenance-services
```

If all three describe the same package with slightly rewritten text, you may have created unnecessary overlap.

Possible remedies include:

- Consolidating equivalent material into one stronger page.
- Giving genuinely different offerings clear boundaries.
- Redirecting retired URLs to their relevant replacement.
- Updating internal links to the intended destination.

Do not automatically canonicalize distinct articles to a service page because they share vocabulary. Canonicals concern equivalent content; page planning concerns audience tasks.

**Use AI as a research assistant with explicit limits**

Give your assistant actual evidence:

```text
Customer questions:
- Who updates the website after launch?
- What happens if an update breaks something?
- Can you maintain a website someone else built?

Verified service facts:
- We assess existing websites before accepting maintenance.
- The agreement defines included tasks.
- Redesigns require a separate scope.
```

Ask it to propose question groups, page outlines, and missing information. Require it to distinguish supplied facts from suggestions requiring client confirmation.

Then compare the proposal with customer needs and real search results.

For freelance work, this produces a concrete deliverable before development: **an agreed page map and content brief identifying each page’s audience, purpose, evidence, and next step.** That gives you something meaningful to implement—and something specific against which to review the finished website.

> continue

<details><summary>2 previous messages</summary>

> Next we’ll cover URL identity and indexing controls: how redirects, canonical tags, `robots.txt`, and `noindex` work together—and how to avoid excluding useful pages or exposing duplicate ones.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls`
>
> </details>
</details>

Your page map now tells you which pages should exist. The next step is to make sure your website gives search engines consistent instructions about **which URLs represent those pages and which pages belong in search**.

This becomes especially important when you add tracking parameters, client-side routing, preview deployments, or a CMS.

**One page can accidentally have several addresses**

Imagine these URLs all display Northstar’s maintenance service:

```text
http://example.com/services/maintenance
https://example.com/services/maintenance
https://www.example.com/services/maintenance
https://example.com/services/maintenance/
https://example.com/services/maintenance?utm_source=newsletter
```

They differ in protocol, hostname, trailing slash, or query parameters.

Search engines can often recognize duplicates, but you should establish a consistent preferred address. Otherwise, your internal links, sitemap, analytics, and search signals can describe the same content differently.

For this example, choose:

```text
https://example.com/services/maintenance
```

There is no inherent SEO advantage to choosing `www` over the bare domain, or universally using trailing slashes over omitting them. Consistent implementation matters.

**A redirect moves the visitor; a canonical describes the preferred version**

These mechanisms have different observable behavior.

A redirect returns an HTTP response such as:

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/services/maintenance
```

The browser requests the destination. Its address bar changes.

A canonical appears in the page:

```html
<link
  rel="canonical"
  href="https://example.com/services/maintenance"
>
```

The visitor stays on the current URL. The tag signals which equivalent URL you prefer search engines to consolidate around.

| Situation | Appropriate starting approach |
|---|---|
| HTTP should always become HTTPS | Redirect |
| You permanently renamed a page | Redirect the old address to its replacement |
| Tracking parameters display equivalent content | Canonical to the preferred clean URL |
| Two pages describe distinct services | Give each its own preferred URL |
| Content was removed without a relevant replacement | Return an appropriate missing-page response |

Google treats canonical annotations as signals and can select a different canonical. Permanent redirects are also canonicalization signals. [Canonical guidance](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls), [redirect guidance](https://developers.google.com/search/docs/crawling-indexing/301-redirects)

**Never point every page’s canonical at the homepage**

Consider:

```text
/services/maintenance
/services/accessibility
/guides/maintenance-checklist
```

These pages serve different purposes. A shared homepage canonical incorrectly suggests that the homepage is their equivalent preferred version.

Each should usually identify itself:

```html
<!-- On the maintenance service page -->
<link
  rel="canonical"
  href="https://example.com/services/maintenance"
>
```

This is called a **self-referencing canonical**.

It helps keep the preferred address explicit, including when tracking parameters are attached.

**Query parameters require a content decision**

A parameter is the part after `?`:

```text
/products?sort=price
```

Parameters are not inherently bad for SEO. Their meaning determines your policy.

| Parameter | Effect | Question to resolve |
|---|---|---|
| `utm_source=newsletter` | Tracks acquisition | Does the page remain equivalent? |
| `sort=price` | Changes ordering | Is this a useful independent search destination? |
| `page=2` | Shows another set of items | Does it contain different content that needs discovery? |
| `category=accessibility` | Filters content | Does this represent a valuable landing page? |

Avoid automatically stripping every parameter from canonical URLs. For example, canonicalizing every paginated page to page one can misrepresent pages containing different items.

This is where a developer needs product context: **which URL variations represent meaningful public resources?**

For a small service website, the policy can be simple. For a marketplace with thousands of filters, it becomes a major architectural decision.

**Implement URL policy at the right layer**

| Stack | Canonical implementation | Redirect implementation |
|---|---|---|
| Plain HTML | Link element in each document’s head | Hosting or web-server rules |
| React–Vite | Route-aware metadata, ideally included in generated HTML | Hosting or server rules |
| Next.js | Metadata API | Framework or hosting configuration |
| Astro | Layout/page head | Framework or hosting configuration, depending on deployment |

A React router navigation operation is not necessarily an HTTP redirect. If the browser must download and execute JavaScript before moving, you have added dependencies that a server redirect avoids.

Similarly, a hosting **rewrite** can serve one file while keeping the original URL. It does not necessarily return a redirect status or change the address bar.

That distinction explains many SPA deployment mistakes.

**Crawling permission and indexing permission are separate**

Now consider two questions:

1. May a crawler fetch this URL?
2. Should this page appear in the search index?

`robots.txt` mainly addresses the first. `noindex` addresses the second.

A basic `robots.txt` for our fictional public website could contain:

```text
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

- `User-agent: *` targets crawlers generally.
- `Allow: /` explicitly permits crawling; with no blocking rules, it is generally redundant.
- `Sitemap` identifies the sitemap location.

This file belongs at the site root:

```text
https://example.com/robots.txt
```

It is a crawler instruction file, not a security boundary. A disallowed URL can still appear in search when discovered elsewhere, even if its content cannot be fetched. [Robots.txt guidance](https://developers.google.com/search/docs/crawling-indexing/robots/intro)

**Use `noindex` when a public page should stay out of search**

A generic enquiry confirmation page may be accessible to visitors but have no value as a search result.

Its HTML can include:

```html
<meta name="robots" content="noindex">
```

An HTTP header can express the same instruction:

```http
X-Robots-Tag: noindex
```

The header is also useful for resources such as PDFs that do not have an HTML head.

The crawler must be able to retrieve the response to discover the directive. Therefore, blocking the page in `robots.txt` can prevent it from seeing `noindex`. Google does not support placing a `noindex` directive inside `robots.txt`. [Google’s noindex documentation](https://developers.google.com/search/docs/crawling-indexing/block-indexing)

Use authentication for private client information. A page excluded from search is still accessible to anyone who can request it.

**An exclusion can come from outside your component**

Suppose you inspect the document and find no `noindex` tag. That does not finish the investigation.

A hosting platform or server might add:

```http
X-Robots-Tag: noindex
```

Likewise, a shared layout might accidentally add the tag to every page.

Inspect both:

- The HTML response.
- The response headers.

This matters during launches. Preview environments sometimes intentionally exclude indexing. Production needs its own deliberate policy.

For confidential previews, password protection provides access control; `noindex` alone does not.

**Generate robots and sitemap files in Next.js**

In an existing App Router project, this complete module generates `robots.txt`:

```ts
// app/robots.ts
import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
    },
    sitemap: "https://example.com/sitemap.xml",
  };
}
```

The function returns a structured description. Next.js converts it into the text response. [Next.js robots convention](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots)

A minimal sitemap module:

```ts
// app/sitemap.ts
import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const origin = "https://example.com";

  return [
    { url: origin },
    { url: `${origin}/services/maintenance` },
    { url: `${origin}/guides/maintenance-checklist` },
  ];
}
```

Each object describes a URL you want discovered. [Next.js sitemap convention](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap)

For CMS content, generate entries from published records. Ensure the same records actually produce working pages.

If you include modification dates, use meaningful content-update dates. Setting every page’s date to the current time on every request gives inaccurate information.

For plain HTML, React–Vite, and Astro, static files or build-time generation can provide the same output. The format seen by crawlers matters more than the authoring mechanism.

**Check that the sitemap tells the same story as the site**

For Northstar, the intended configuration might be:

| URL | Response | Indexing policy | Canonical | In sitemap? |
|---|---:|---|---|---|
| `/services/maintenance` | `200` | Eligible | Self | Yes |
| `/guides/maintenance-checklist` | `200` | Eligible | Self | Yes |
| `/services/maintenance?utm_source=email` | `200` | Eligible for consolidation | Clean service URL | No |
| `/old-maintenance` | Permanent redirect | Destination takes over | Not needed on redirect response | No |
| `/thank-you` | `200` | `noindex` | Usually unnecessary | No |
| `/nonexistent-page` | `404` | Missing page | Not needed | No |

“Eligible” means your controls allow consideration. It does not mean indexing is guaranteed.

This table is a useful freelance deliverable because it turns vague SEO configuration into behavior you can verify.

**Connect URL consistency to AEO**

Answer systems need retrievable sources too. Stable public URLs provide addresses that can be linked and cited.

A service description available only after a temporary browser interaction is harder to reference than a stable public page. A fragment such as `#maintenance` can help navigation within a document, but the fragment itself is not sent to the server and does not create a separately fetched page.

Crawler identities and supported directives vary across answer platforms. Permission to crawl for search, permission to train models, and user-triggered retrieval are separate policy questions; consult each provider’s documentation before creating rules.

**Verify with the deployed site**

For this lesson, use browser Developer Tools and Search Console:

1. Request the preferred page directly and inspect its HTML and headers.
2. Request an old or alternate address and observe whether it redirects.
3. Open `/robots.txt` and the sitemap directly.
4. Check whether excluded pages expose `noindex`.
5. Inspect a nonexistent path.
6. In Search Console, compare your declared canonical with Google’s selected canonical when available.

An AI assistant can review an exported URL table for contradictions. It should flag patterns such as “listed in sitemap but marked `noindex`” and “canonical points to a redirect,” with evidence for each finding.

Your acceptance criterion is concrete: **every public URL should have an intentional purpose, response, indexing policy, and preferred address—and those decisions should agree across the deployed site.**

> continue

<details><summary>2 previous messages</summary>

> Next we’ll work through structured data: choosing the right types, generating accurate JSON-LD, and testing it across HTML, React–Vite, Next.js, and Astro.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/appearance/structured-data/sd-policies`
>
> Searched the web for `https://developers.google.com/search/docs/appearance/structured-data/search-gallery`
>
> </details>
</details>

We’ve established what your pages say, how they render, and which URLs represent them. Now we can describe their meaning explicitly through **structured data**.

The central rule is: **structured data should describe facts your website already communicates accurately.**

**Understand the problem structured data solves**

Consider this visible text:

> Northstar Web Studio provides website maintenance.

A human can infer two things:

- Northstar is the provider.
- Website maintenance is the service.

Structured data expresses those relationships using a shared vocabulary.

Three terms matter:

| Term | Meaning |
|---|---|
| **Schema.org** | A vocabulary defining types such as `Person`, `Organization`, and `Service`, with their properties |
| **JSON-LD** | A format for expressing linked structured data using JSON |
| **Rich result** | A search presentation that can include features beyond an ordinary text result |

These are related but distinct. Valid Schema.org markup does not automatically qualify for a Google rich result. Google supports particular features with their own requirements. [Google’s supported structured-data gallery](https://developers.google.com/search/docs/appearance/structured-data/search-gallery)

**Start with a small, accurate description**

Here is an HTML fragment for our fictional maintenance page:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Service",
  "name": "Website maintenance",
  "description": "Scheduled updates, backups, and agreed website fixes.",
  "url": "https://example.com/services/maintenance",
  "provider": {
    "@type": "Organization",
    "name": "Northstar Web Studio",
    "url": "https://example.com/"
  }
}
</script>
```

Read it as a set of statements:

| Property | Meaning |
|---|---|
| `@context` | Interpret these terms using Schema.org |
| `@type: "Service"` | The thing being described is a service |
| `name` | Its name |
| `description` | A factual explanation |
| `url` | A page associated with it |
| `provider` | The person or organization providing it |

`provider` contains another object because the provider has its own type and properties. Schema.org documents these relationships for `Service`. [Service definition](https://schema.org/Service)

The script’s type, `application/ld+json`, identifies data. The browser does not execute it as ordinary JavaScript.

You can include JSON-LD in the document’s head or body.

**Choose types according to what exists**

For freelance work, these distinctions are useful:

| What you describe | Possible type | Important distinction |
|---|---|---|
| You as an individual | `Person` | Your professional identity |
| A studio or business organization | `Organization` | The business entity |
| A qualifying local business | Appropriate `LocalBusiness` subtype | Choose based on the actual business |
| A service offering | `Service` | What the provider does |
| An educational article | `Article` or a suitable subtype | The published work |
| The webpage containing information | `WebPage` | The document itself |

A freelancer can be a person and operate a business. You do not need to force those identities into one object.

Likewise, a service is not the same thing as its webpage. One is the offering; the other describes that offering.

Avoid choosing a type because a tutorial promises better rankings. Start with its definition and the client’s actual facts. [Person](https://schema.org/Person), [Organization](https://schema.org/Organization)

**Keep visible content and structured data consistent**

Suppose your page says:

> Contact us for a maintenance proposal.

But its structured data says:

```json
{
  "price": "49",
  "priceCurrency": "USD"
}
```

Where did that price come from? If it is an invented example left in production, the markup misrepresents the offer.

Common inconsistencies include:

- Old prices surviving after a redesign.
- A service marked as a product without considering its meaning.
- Invented ratings or review counts.
- A business address copied from a template.
- Article dates changing on every deployment.
- Structured data describing content absent from the page.

Google’s policies require relevant, accurate markup and impose additional rules for particular features. Passing a syntax validator does not establish factual accuracy or policy compliance. [Structured-data policies](https://developers.google.com/search/docs/appearance/structured-data/sd-policies)

**Generate both representations from the same record**

This is where your coding choices can prevent editorial mistakes.

In an existing React project, the following is a complete page component. It can serve as `App.jsx` in a basic Vite project or a page module in an existing Next.js App Router application:

```jsx
const service = {
  name: "Website maintenance",
  description: "Scheduled updates, backups, and agreed website fixes.",
  url: "https://example.com/services/maintenance",
  provider: {
    name: "Northstar Web Studio",
    url: "https://example.com/",
  },
};

export default function MaintenancePage() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Service",
    name: service.name,
    description: service.description,
    url: service.url,
    provider: {
      "@type": "Organization",
      name: service.provider.name,
      url: service.provider.url,
    },
  };

  const serialized = JSON.stringify(jsonLd).replace(/</g, "\\u003c");

  return (
    <main>
      <h1>{service.name}</h1>
      <p>{service.description}</p>

      <p>
        Provided by{" "}
        <a href={service.provider.url}>
          {service.provider.name}
        </a>.
      </p>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: serialized }}
      />
    </main>
  );
}
```

Several parts deserve explanation.

`service` is your content record. Both the visible page and JSON-LD use its values, reducing the chance that one changes without the other.

`JSON.stringify()` converts the JavaScript object into JSON text. Manually assembling JSON with string concatenation makes quoting errors much easier.

The replacement converts literal `<` characters into a JSON Unicode escape. This helps prevent an embedded value containing something like `</script>` from prematurely closing the HTML script element.

`dangerouslySetInnerHTML` inserts the serialized text directly. Its name reminds you that raw insertion requires care. Do not replace this serialization step with unchecked string interpolation.

Next.js documents this JSON-LD insertion pattern and uses a native script element for the data. [Next.js JSON-LD guidance](https://nextjs.org/docs/app/guides/json-ld)

**The same component has different delivery behavior across setups**

The JSX above does not determine where it executes.

| Setup | What happens |
|---|---|
| Conventional React–Vite CSR | JavaScript adds the page and JSON-LD in the browser |
| Prerendered React–Vite | Build-time rendering can include both in generated HTML |
| React SSR | Request rendering can include both |
| Next.js server-rendered/prerendered page | Both can be delivered through the page’s HTML |

For predictable public delivery, include the structured data during the same rendering process that produces the important content.

Adding JSON-LD to a CSR page does not fix missing server-delivered content. The rendering decisions from our earlier lesson still apply.

Also ensure route changes replace page-specific markup correctly. A service page should not retain the previous article’s structured data after client-side navigation.

**Apply the same approach in Astro**

Astro supports inserting JSON-LD using `set:html`. This intentionally abbreviated fragment assumes `jsonLd` has been constructed in the page’s frontmatter:

```astro
<script
  type="application/ld+json"
  set:html={JSON.stringify(jsonLd).replace(/</g, "\\u003c")}
/>
```

`set:html` inserts content without normal HTML escaping, so serialization still matters. Astro documents JSON-LD as a use case for the directive. [Astro directive reference](https://docs.astro.build/en/reference/directives-reference/#sethtml)

In plain HTML, maintain the JSON-LD directly for a small site. Once the site has many pages, generating content and markup from shared records becomes more valuable.

**Use stable identifiers when relationships become more complex**

Later, you may describe the same organization across many pages.

An identifier such as:

```json
{
  "@id": "https://example.com/#organization"
}
```

can establish a consistent identity within your linked data.

An organization definition might include that ID, while a service’s `provider` references it. A definition must also be available to give the reference useful meaning.

The `#organization` portion here is an entity identifier. It does not create a separate server route or search landing page.

You’ll also encounter `@graph`, which holds multiple related objects in one JSON-LD document. Introduce it when you have relationships worth expressing; a small site does not need a large graph merely to look sophisticated.

**Test three separate things**

| Check | Question | Tool or method |
|---|---|---|
| Structure | Does the markup use valid syntax and vocabulary? | [Schema Markup Validator](https://validator.schema.org/) |
| Google feature eligibility | Does supported markup meet relevant requirements? | [Rich Results Test](https://search.google.com/test/rich-results) |
| Truth and delivery | Is it accurate, relevant, and present on the deployed page? | Content review and response inspection |

A valid `Service` object may not produce a dedicated rich-result preview. That does not necessarily mean the JSON-LD is broken.

Conversely, a successful rich-result test is not a promise that the feature will appear.

Test the deployed URL as well as pasted code. Pasted code cannot reveal that production is serving an old build, adding conflicting markup, or omitting the script.

**Understand its role in AEO**

Structured data provides explicit descriptions and relationships. Whether a particular answer system uses those fields, and how, depends on that system.

Google states that its generative search features do not require special Schema.org markup. Structured data remains useful for supported search features, but it does not guarantee AI citations. [Google’s AI guidance](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide)

Keep investing in the underlying answer: accurate scope, useful explanations, original evidence, and accessible content.

**Use AI to draft from verified facts**

An AI assistant can map supplied business records into candidate markup. Give it the visible page content and ask it to:

- Use only verified facts.
- Explain why each type fits.
- Flag missing information without inventing values.
- Distinguish general Schema.org markup from Google-supported features.
- Identify inconsistencies between the page and generated data.

Then validate the output and inspect production.

For a freelance handover, document which records generate the markup and how updates reach the live site. Your acceptance criterion is that **the structured data accurately describes the page, stays synchronized with its content, and survives deployment and navigation checks.**

> continue

<details><summary>2 previous messages</summary>

> Next we’ll cover performance: how to measure loading speed, responsiveness, and layout stability, then choose fixes that fit HTML, React–Vite, Next.js, or Astro.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://web.dev/articles/vitals`
>
> </details>
</details>

A page can be crawlable, relevant, and correctly marked up while still making visitors wait. Performance affects whether people can read your answer, use your tools, and complete an enquiry.

The engineering skill is **finding which stage is slow before choosing an optimization**.

**Think about three separate experiences**

Imagine someone opening Northstar’s portfolio on a modest phone:

1. They wait for the main content to appear.
2. They tap a project filter.
3. A late-loading image pushes the contact button down.

These correspond to the current Core Web Vitals:

| Metric | Experience measured | Good threshold |
|---|---|---|
| **LCP — Largest Contentful Paint** | When the largest eligible visible content element appears | ≤ 2.5 seconds |
| **INP — Interaction to Next Paint** | How quickly the page visually responds to interactions | ≤ 200 milliseconds |
| **CLS — Cumulative Layout Shift** | Unexpected movement of page elements | ≤ 0.1 |

Assessment uses the **75th percentile** of visits, evaluated separately for mobile and desktop. That means at least 75% of the measured experiences should meet the relevant threshold. [Web Vitals guidance](https://web.dev/articles/vitals)

These metrics describe different problems. Compressing images might improve loading without fixing a slow filter button.

**Understand the difference between lab and field measurements**

A lab test runs a page under controlled conditions. Field data measures experiences from actual users.

| Evidence | Useful for | Limitation |
|---|---|---|
| Lighthouse test | Reproducing loading problems and finding opportunities | One simulated visit cannot represent every visitor |
| Chrome performance recording | Investigating specific work and interactions | Requires interpreting a trace |
| PageSpeed Insights field data | Understanding real-world experience | Requires sufficient eligible traffic |
| Your own real-user measurement | Investigating your audience and routes | Requires implementation and data interpretation |

PageSpeed Insights combines Lighthouse lab testing with Chrome UX Report field data. Its field data covers a rolling period rather than changing immediately after a deployment. Check whether the report describes the individual URL or the wider origin. [PageSpeed Insights documentation](https://developers.google.com/speed/docs/insights/v5/about)

A new site with no field data has **unknown field performance**. It has not automatically passed or failed.

Also, a normal navigation-only Lighthouse run cannot reproduce all the interactions visitors perform. Its Total Blocking Time metric can reveal responsiveness risks, but it is not the same measurement as INP.

**Diagnose LCP by finding the largest content element**

On Northstar’s homepage, the LCP element might be a large heading or a hero image.

For an image, several delays can accumulate:

```text
Request page
→ wait for HTML
→ discover image
→ download image
→ display image
```

Different causes require different fixes:

| Cause | Suitable investigation |
|---|---|
| HTML arrives slowly | Server response, database work, caching |
| Image discovered late | Browser-only insertion, CSS dependencies |
| Image downloads slowly | Dimensions, compression, delivery |
| Downloaded image remains hidden | Animation, styling, rendering work |

An image inserted only after browser-side data loading can start downloading late even if its file is small.

For an important hero image, avoid lazy loading. Make it discoverable in the HTML and use priority hints selectively. Marking every image high priority defeats the purpose. [LCP optimization guidance](https://web.dev/articles/optimize-lcp)

Here is an illustrative HTML fragment, assuming these image files exist:

```html
<img
  src="/images/studio-960.webp"
  srcset="
    /images/studio-480.webp 480w,
    /images/studio-960.webp 960w,
    /images/studio-1440.webp 1440w
  "
  sizes="(max-width: 700px) 100vw, 700px"
  width="1440"
  height="960"
  fetchpriority="high"
  alt="Northstar’s workspace with website sketches and a laptop"
  style="display: block; width: 100%; max-width: 700px; height: auto;"
>
```

The attributes have different jobs:

- `srcset` offers image candidates at different widths.
- `sizes` describes the expected displayed width, helping the browser choose.
- `width` and `height` establish the image’s proportions.
- `fetchpriority` expresses a loading preference.
- `alt` describes meaningful image content for accessibility.

The `sizes` value must match your actual layout. Copying it unchanged into a different design can cause unnecessarily large downloads.

**Choose image tooling according to the framework**

| Stack | Practical approach | Tradeoff |
|---|---|---|
| HTML | Generate variants and write responsive markup | You maintain the image pipeline |
| React–Vite | Use standard image markup or an image-processing integration | Importing an image alone does not create a complete optimization pipeline |
| Next.js | Use `next/image` where appropriate | Understand sizing, deployment, and optimizer configuration |
| Astro | Use its image tooling for supported assets | Understand which assets are processed and how |

Next.js’s Image component can generate responsive image output, but you still need correct layout information and sensible loading choices. [Next.js Image documentation](https://nextjs.org/docs/app/api-reference/components/image)

Astro can process supported local images through its image components. Assets served directly from its public directory need deliberate handling; do not assume every image is automatically transformed. [Astro image guidance](https://docs.astro.build/en/guides/images/)

A framework image component helps implement a strategy. It does not decide which image the visitor needs or whether your design requires a giant hero photograph.

**Diagnose INP by following an interaction**

Suppose a visitor selects “React projects” in your portfolio filter.

The browser must:

```text
Receive interaction
→ run event-related work
→ update the interface
→ paint the result
```

A delayed response can come from work already blocking the browser, an expensive handler, or expensive rendering afterward.

Useful investigations include:

- Large synchronous calculations.
- Filtering and rendering thousands of items.
- Third-party scripts occupying the main thread.
- Repeated layout reads and writes.
- Excessive UI updates.

Record the actual interaction in Chrome’s Performance panel. Optimize the work shown there rather than adding memoization everywhere. A network request can also delay the final result; show prompt pending feedback while it runs. [INP optimization guidance](https://web.dev/articles/optimize-inp)

**Load optional features when they become useful**

A portfolio homepage might include a substantial interactive estimator. Visitors should not necessarily download its code before reading the service description.

In an existing React project, these two files demonstrate conditional code loading.

```jsx
// App.jsx
import { lazy, Suspense, useState } from "react";

const Estimator = lazy(() => import("./Estimator.jsx"));

export default function App() {
  const [showEstimator, setShowEstimator] = useState(false);

  return (
    <main>
      <h1>Website development for independent businesses</h1>
      <p>Explore the project scope before requesting a proposal.</p>

      <button
        type="button"
        onClick={() => setShowEstimator(true)}
      >
        Open estimator
      </button>

      {showEstimator && (
        <Suspense fallback={<p>Loading estimator…</p>}>
          <Estimator />
        </Suspense>
      )}
    </main>
  );
}
```

```jsx
// Estimator.jsx
export default function Estimator() {
  return (
    <section aria-label="Project estimator">
      <p>A real estimator would collect project requirements here.</p>
    </section>
  );
}
```

`lazy()` loads the component’s code when React first attempts to render it. The conditional delays that attempt until the button is activated. `Suspense` provides temporary content during loading. [React lazy documentation](https://react.dev/reference/react/lazy)

The demonstration estimator is tiny, so splitting it would offer little benefit. Apply this pattern when the optional feature has meaningful code or dependencies.

Code splitting does not make an expensive calculation faster once it runs. It changes when code is loaded.

For SEO and AEO, keep the essential explanation outside this optional feature. Visitors and retrieval systems should be able to understand your offering without operating the estimator.

**Diagnose CLS by identifying what moves**

Imagine a visitor starts reading a case study. An image loads above the paragraph and pushes it downward.

Common causes include missing image dimensions, inserted banners, embeds without reserved space, and font changes that alter text layout.

Typical fixes:

| Cause | Fix |
|---|---|
| Image occupies space only after loading | Provide dimensions or an appropriate aspect ratio |
| Embedded video expands later | Reserve its expected space |
| Loading placeholder is much shorter than final content | Use a representative layout |
| Banner is inserted above existing content | Allocate space or change the placement |
| Font swap changes line wrapping | Investigate font delivery and fallback metrics |

Some shifts following recent user input are excluded, but delayed shifts can still count. Test the full visitor journey, not just the initial screen. [CLS optimization guidance](https://web.dev/articles/optimize-cls)

**Compare the architectural tradeoffs**

| Stack | Performance opportunity | Failure to watch for |
|---|---|---|
| Plain HTML | Little application JavaScript | Huge media and third-party widgets can still dominate |
| React–Vite CSR | Rich interaction and route splitting | Initial content may wait on JavaScript and data |
| Next.js | HTML delivery and selective client interaction | Slow server work or excessive client JavaScript |
| Astro | Content rendered with selective hydration | Hydrating unnecessary components or shipping oversized media |

Server rendering can improve content availability while increasing server response time if data access is slow. Static generation avoids request-time rendering but requires a publishing strategy for freshness.

Choose based on measured behavior and project requirements.

**Watch the costs added after your initial build**

A client may later add:

- A chat widget.
- Scheduling software.
- Multiple analytics tools.
- A video background.
- Social feeds.
- An animation package.

Each addition can affect loading, responsiveness, or layout stability.

For an embedded scheduler, you might initially display an explanation and a button that loads it on request. That saves initial work but makes opening the scheduler slower. Decide whether that tradeoff fits the page’s purpose.

Measure these additions individually where possible.

**Report evidence that a client can understand**

Instead of saying:

> Performance improved from 76 to 94.

Explain:

> The mobile test downloaded an oversized hero image. We added responsive variants and reduced unnecessary image transfer. Under the same test conditions, the main image appeared sooner. Real-user data will take time to reflect the change.

A useful report records:

| Field | Example |
|---|---|
| Page and conditions | Homepage, mobile lab test |
| Observed problem | Hero image downloaded at desktop size |
| Change | Responsive variants and corrected sizing |
| Verification | Network inspection and comparable repeat tests |
| Remaining uncertainty | Insufficient page-level field data |

AI can help interpret traces or audit findings, but require it to connect each recommendation to observed evidence.

For your freelance work, the acceptance criterion is **a usable experience under representative conditions, supported by measurements and a clear explanation of any remaining constraints**.

> continue

<details><summary>2 previous messages</summary>

> Next we’ll focus on AEO: how search-based AI answers find sources, what makes your content useful to cite, and how to measure visibility without mistaking a single AI response for a stable result.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/appearance/ai-features`
>
> Searched the web for `site.blogs.bing.com "AI Performance" "2026" ...`
>
> </details>
</details>

Now we can connect the technical foundations to AEO more directly: **how to publish information that an answer system can find, interpret, and use accurately.**

There are three different outcomes to distinguish:

| Outcome | Example |
|---|---|
| Your information informs an answer | The system uses information resembling your explanation |
| Your page receives a citation | The answer links to your page |
| Your business receives a recommendation | The answer names you as a potential provider |

These outcomes require different evidence. Finding your wording in an answer does not prove that your page was its source.

**Understand retrieval before trying to influence answers**

For search-based AI answers, a useful simplified model is:

```text
User question
→ related searches or retrieval requests
→ candidate sources
→ information selection
→ generated answer with supporting links
```

This is a teaching model, not a description of every product’s internal architecture.

Some systems can search for several aspects of a question. Google describes **query fan-out**: issuing related searches across subtopics and sources when developing certain AI answers. [Google’s AI feature documentation](https://developers.google.com/search/docs/appearance/ai-features)

For example:

> “Should a small consultancy use Astro or Next.js for its website?”

That question contains several decisions:

- How much interaction does the site need?
- Who publishes content?
- How frequently does information change?
- What are the hosting and maintenance constraints?
- Does the project include a private application?

A useful source might answer one of those decisions particularly well. You do not have to write a giant article addressing every possible variation.

**Separate knowledge learned during training from current retrieval**

A model may produce an answer using previously learned information, retrieved sources, or a combination.

For your website, those distinctions matter:

- Publishing a page does not establish that a model has trained on it.
- Allowing a training crawler does not guarantee search visibility.
- Receiving a search citation does not establish training inclusion.
- Updating your website does not immediately update every model’s knowledge.

Treat discoverability, crawler policies, and model training as separate subjects. When implementing platform-specific access rules, consult that provider’s current documentation.

For Google’s AI search supporting links, indexing and snippet eligibility remain technical prerequisites. Passing those prerequisites does not guarantee selection. [Google’s eligibility guidance](https://developers.google.com/search/docs/appearance/ai-features)

**Create information that contributes something specific**

Suppose Northstar publishes:

> Astro is fast. Next.js is powerful. Choose the framework that suits your needs.

That offers little help.

A more useful explanation might say:

> For a consultancy site with service pages, case studies, and a contact form, Astro is a practical option when most content can be generated during publishing. Next.js becomes more attractive when the project also needs substantial application behavior, request-specific public data, or a shared architecture with an existing Next.js product.

This is an engineering recommendation with stated conditions. It gives the reader a basis for deciding.

The next improvement is evidence:

- Show the actual requirements.
- Explain alternatives considered.
- Describe implementation constraints.
- Provide measurements where relevant.
- State what the example cannot establish.

Google’s content guidance emphasizes original information, clear sourcing, and evidence of relevant experience. [Helpful-content guidance](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)

**Make claims precise enough to survive quotation**

A sentence may be read separately from the surrounding article.

Compare:

> It is always cheaper.

With:

> A static deployment can reduce server-operation requirements for a small content site, but total cost still depends on publishing, integrations, hosting limits, and maintenance.

The second sentence carries its own scope.

This is useful editorial practice for humans and machines. It is not a guaranteed citation technique.

Watch for ambiguous claims:

| Ambiguous claim | Information needed |
|---|---|
| “Our websites are faster” | Faster than what, measured how? |
| “React has bad SEO” | Which rendering strategy and which failure? |
| “Maintenance includes updates” | Which updates, with what exclusions? |
| “Prices start at $500” | Currency, deliverables, and conditions |
| “Results improved by 40%” | Metric, baseline, period, and method |

Precision can make content less dramatic while making it more useful.

**Distinguish evidence from illustration**

This is especially important when using AI to write case studies.

| Material | Appropriate treatment |
|---|---|
| Actual project measurements | Explain conditions and preserve supporting records |
| Client-reported outcome | Attribute it to the client |
| Hypothetical scenario | Label it as hypothetical |
| External technical claim | Link to an appropriate source |
| Your recommendation | Explain its assumptions and reasoning |

Do not turn a demonstration into an apparent client success story.

For a performance case study, record the page, test conditions, changes, and limitations. A faster lab measurement does not establish an increase in revenue.

For a business-service page, the evidence may simply be a verified service agreement and authentic examples. Every claim does not need an academic citation.

**Model important facts so they stay consistent**

Imagine a hypothetical Northstar policy: redesigns are scoped separately from maintenance.

You could represent that fact in a content record:

```js
export const maintenancePolicy = {
  question: "Does maintenance include a redesign?",
  answer:
    "Major redesigns are scoped separately from maintenance.",
  qualification:
    "Your agreement defines the updates and fixes included.",
};
```

Then render it in a reusable React component:

```jsx
import { maintenancePolicy } from "./maintenancePolicy.js";

export default function MaintenancePolicy() {
  return (
    <section aria-labelledby="redesign-policy">
      <h2 id="redesign-policy">
        {maintenancePolicy.question}
      </h2>

      <p>{maintenancePolicy.answer}</p>
      <p>{maintenancePolicy.qualification}</p>
    </section>
  );
}
```

In an existing React project, these are complete modules. The record contains the hypothetical policy; the component presents it.

The architectural benefit is consistency. The same verified record can inform page content and other appropriate outputs.

However, avoid publishing identical blocks across dozens of pages merely to increase repetition. Reuse should support the visitor’s task.

Across your stacks:

| Stack | How to keep facts reliable |
|---|---|
| Plain HTML | Review repeated facts during updates; introduce templates when useful |
| React–Vite | Share content records; ensure public content is delivered through your chosen rendering strategy |
| Next.js | Use consistent records across page rendering and metadata; invalidate affected caches |
| Astro | Use shared records or content collections; rebuild affected output after publication |

A sophisticated content model cannot compensate for an outdated production deployment.

**Give users the explanation before requiring interaction**

Suppose you build a framework recommendation tool.

A visitor selects requirements and receives “Astro” or “Next.js.”

The tool is useful, but it should also have a readable explanation of its criteria:

```text
Public explanation
├── What the tool considers
├── When static generation fits
├── When request-time rendering fits
├── Hosting and maintenance considerations
└── Limitations of the recommendation
```

This makes the resource useful even when someone does not operate it.

It also gives other pages a stable explanation to reference. Important assumptions should not exist only inside JavaScript event handlers.

For single-page websites, provide meaningful sections within the document. For larger sites, give substantial tools and guides their own stable URLs when their purpose warrants it.

**Avoid treating writing patterns as ranking rules**

You will encounter advice such as:

- Every answer must contain exactly 40–60 words.
- Every heading must be a question.
- Every page needs an FAQ.
- Every paragraph must be a separate “AI chunk.”
- Adding `llms.txt` unlocks AI visibility.

These are not universal requirements.

Question headings, concise answers, tables, and summaries can improve readability when appropriate. Google explicitly says special AI files and particular chunking practices are unnecessary for its search visibility. Its guidance does not establish how every other service behaves. [Google’s AI optimization guidance](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide)

Choose the format that explains the subject accurately. A comparison may need a table; a debugging procedure may need ordered steps; a nuanced recommendation may need several connected paragraphs.

**Measure visibility and business impact separately**

You need several kinds of evidence:

| Question | Evidence |
|---|---|
| Is the page retrievable? | Response inspection and crawler tools |
| Is it appearing in supported AI experiences? | Available first-party platform reporting |
| Does a particular answer cite it? | Recorded observation of that answer |
| Do visitors arrive? | Analytics and server data |
| Do those visits help the business? | Qualified enquiries, sales, or another defined conversion |

Bing’s AI Performance reporting covers supported Microsoft and selected partner experiences. Its scope should not be interpreted as all AI search. [Bing’s AI Performance announcement](https://blogs.bing.com/webmaster/2026/2/Introducing-AI-Performance-in-Bing-Webmaster-Tools-Public-Preview/)

Referring-traffic reports are also incomplete evidence. Some visits may lack useful attribution, and a citation can occur without a visit.

**Run small, documented experiments**

For a freelance client, a useful experiment could be:

1. Select a genuine customer question.
2. Record the current page and available visibility data.
3. Improve missing facts, evidence, or explanation.
4. Verify the deployed content and technical accessibility.
5. Review subsequent observations over a defined period.
6. Record other changes that could affect the outcome.

For manual AI checks, keep the question, platform, date, locale, whether search was enabled, and cited URLs.

Repeated answers can vary. A small prompt sample is exploratory evidence, not a representative measurement of market-wide visibility.

If citations increase after an edit, describe it as an observed association unless your evidence supports a stronger causal conclusion.

**Use free AI assistance for evidence review**

Useful tasks include:

- Finding claims that lack scope or support.
- Comparing a draft against verified business facts.
- Identifying contradictions between pages.
- Suggesting questions a customer might still have.
- Checking whether a linked source supports the sentence citing it.
- Producing a change log from supplied before-and-after content.

Require the assistant to distinguish confirmed findings from suggestions. Verify quoted claims and source links yourself.

For a client, the concrete output is a page that answers a real question, explains its assumptions, provides appropriate evidence, and remains accessible at a stable URL—with reporting that distinguishes observed visibility from promised results.

> continue

<details><summary>2 previous messages</summary>

> Next we’ll cover internal links and semantic navigation: how visitors and crawlers find your pages, and how to build menus, tabs, filters, and pagination without hiding important content behind interactions.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/crawling-indexing/links-crawlable`
>
> </details>
</details>

A useful page can still be difficult to discover if your site gives visitors and crawlers no clear path to it. **Internal linking connects your page strategy to the website people actually navigate.**

This lesson brings together information architecture, HTML semantics, client-side routing, and interactive content.

**Think of the website as pages connected by links**

Northstar might have this structure:

```text
Home
→ Services
  → Website maintenance
    → Maintenance case study
    → Maintenance checklist
→ Work
  → Maintenance case study
→ Guides
  → Maintenance checklist
```

A page can have several useful paths leading to it. Those paths explain relationships: the case study demonstrates the service, while the checklist teaches related tasks.

A page with no discoverable internal links is often called an **orphan page**. A sitemap may expose its URL, but it does not provide visitors with a navigation path or contextual explanation.

Google recommends that important pages receive links from other pages on your site, with descriptive link text. [Google’s link guidance](https://developers.google.com/search/docs/crawling-indexing/links-crawlable)

**Use links for destinations and buttons for actions**

Compare two React fragments.

This uses an action handler to navigate:

```jsx
<div onClick={() => {
  window.location.href = "/services/maintenance";
}}>
  Website maintenance
</div>
```

This expresses the destination directly:

```jsx
<a href="/services/maintenance">
  Website maintenance
</a>
```

The anchor provides native link behavior: keyboard access, copying the address, opening another tab, and a destination that software can inspect.

Buttons suit actions such as opening a menu, submitting a form, or applying an in-place filter:

```html
<button type="button">
  Open project filters
</button>
```

The explicit `type="button"` prevents accidental form submission if the button appears inside a form. [HTML button behavior](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/button)

A practical distinction:

| Visitor intention | Element |
|---|---|
| Read another page | Link |
| Jump to a section | Link with a fragment |
| Open a dialog | Button |
| Submit a form | Submit button |
| Change a local interface setting | Appropriate form control or button |

Choosing the right element improves usability and makes intent explicit. It does not independently guarantee rankings or AI visibility.

**Framework navigation can preserve real links**

You do not need to abandon client-side navigation to provide anchors.

In a React Router application, this component assumes an existing router context:

```jsx
import { Link } from "react-router";

export default function ServiceNavigation() {
  return (
    <nav aria-label="Services">
      <Link to="/services/maintenance">
        Website maintenance
      </Link>
    </nav>
  );
}
```

React Router’s `Link` provides an anchor with enhanced navigation behavior. [React Router Link documentation](https://reactrouter.com/api/components/Link)

The corresponding component in Next.js:

```jsx
import Link from "next/link";

export default function ServiceNavigation() {
  return (
    <nav aria-label="Services">
      <Link href="/services/maintenance">
        Website maintenance
      </Link>
    </nav>
  );
}
```

Next.js’s `Link` also extends anchor behavior. [Next.js Link documentation](https://nextjs.org/docs/app/api-reference/components/link)

Plain HTML and Astro can use ordinary anchors:

```html
<a href="/services/maintenance">Website maintenance</a>
```

After styling or wrapping these components, inspect their output. A design-system component named `Link` might accidentally render a `div`, omit its destination, or nest interactive controls incorrectly.

**A working link requires a working destination**

Client-side navigation can conceal deployment problems.

Suppose this sequence works:

```text
Open homepage → click Services → click Maintenance
```

But opening `/services/maintenance` directly returns a hosting error.

Your browser router understands the route, but the hosting configuration does not serve it correctly.

Test each important destination through:

- A direct address-bar visit.
- A page reload.
- An internal link.
- Browser back and forward navigation.

| Stack | Common source of failure |
|---|---|
| Plain HTML | Link points to an output path that was never deployed |
| React–Vite SPA | Host cannot serve deep routes |
| Prerendered React | Generated route files do not match hosting rules |
| Next.js | Deployment configuration or route handling differs from expectations |
| Astro | Generated paths, slash policy, or hosting configuration disagree |

For an SPA, a fallback can make valid deep routes work. As discussed earlier, distinguish that from returning a successful app shell for every nonexistent address.

**Write link text that explains the next step**

Compare:

```html
<p>
  We completed a maintenance project.
  <a href="/work/maintenance-case-study">Click here</a>.
</p>
```

With:

```html
<p>
  Read our
  <a href="/work/maintenance-case-study">
    website maintenance case study
  </a>
  for the project scope and implementation details.
</p>
```

The second version tells the reader what to expect. Avoid forcing long keyword lists into links. Natural, specific descriptions are enough.

For linked project cards, make the project title a meaningful link. Be cautious with a clickable whole-card implementation that contains additional links or buttons: nested interactive elements can create confusing behavior.

**Build useful hubs before adding endless navigation links**

A **hub page** organizes a collection:

```text
/services → available services
/work     → case studies
/guides   → educational resources
```

A useful hub does more than list titles. It can explain the collection and help visitors choose.

For example:

> Maintenance guides cover routine tasks, cost considerations, and when professional help may be appropriate.

Then show the relevant resources.

For a small portfolio, the homepage might already perform this function. Additional hubs become useful as the collection grows.

Do not interpret “shallow architecture” as a requirement to put every URL in the main menu. Prioritize clear paths through meaningful groups.

**Make essential content available beyond interface interactions**

Consider two implementations of a maintenance FAQ.

In the first, the answer is already in the document:

```html
<details>
  <summary>Can you maintain a website built by someone else?</summary>
  <p>
    Existing websites are assessed before a maintenance agreement
    is offered. The assessment identifies platform and support constraints.
  </p>
</details>
```

In the second, clicking a question triggers an API request that fetches the answer.

Both may work for visitors. The second introduces an additional interaction and retrieval dependency.

For important public explanations, delivering the text with the page is generally a more robust starting point. The example above is a hypothetical business policy; use the client’s verified policy in production.

You can apply the same reasoning to tabs:

| Content | Appropriate consideration |
|---|---|
| Essential service description | Include in page rendering |
| Optional interactive demonstration | Can load on demand |
| Different public services | Consider separate linked pages |
| Private account information | Retrieve securely for the visitor |

Hiding content visually and failing to deliver it at all are different situations. Inspect the actual document before diagnosing a problem.

**Pagination gives collections addressable parts**

Suppose a portfolio has sixty projects. A “Load more” button reveals everything after the first twelve.

A crawler should not have to operate that button to discover all project pages.

A robust approach can provide independently accessible collection pages:

```text
/work?page=1
/work?page=2
/work?page=3
```

Each page contains its own project subset and links to other parts of the collection. JavaScript can enhance that experience.

Google’s pagination guidance recommends unique URLs and crawlable links for incremental content. It also advises against canonicalizing all paginated pages to the first page when their content differs. [Pagination guidance](https://developers.google.com/search/docs/specialty/ecommerce/pagination-and-incremental-page-loading)

Apply this across frameworks:

- **HTML:** Generate collection documents.
- **React–Vite:** Ensure collection URLs and project links exist through the chosen rendering strategy.
- **Next.js:** Render the requested collection state and its links.
- **Astro:** Generate known collection pages or render them on request.

Do not add pagination to a six-project portfolio merely for SEO. Introduce it when the collection warrants it.

**Filters need an explicit URL policy**

A project filter can represent either:

- Temporary interface state.
- A meaningful public collection.

“Show only React projects” might initially be a local convenience. A substantial React case-study collection might eventually deserve its own public page.

Ask:

1. Is this collection useful independently?
2. Does it contain enough relevant material?
3. Should someone be able to share it?
4. Should it be eligible for search?
5. What happens on a direct visit?

Avoid generating indexable pages for every possible combination of technology, year, industry, and sort order without assessing their value.

This connects directly to our earlier lesson on canonical URLs and indexing controls.

**Test navigation with free tools**

A useful testing sequence:

| Tool or method | What to inspect |
|---|---|
| Keyboard navigation | Can you reach and activate links and controls? |
| Browser Elements panel | Are destinations represented by anchors with valid `href` values? |
| Browser accessibility tree | Do controls have understandable names and roles? |
| Lighthouse accessibility audit | Automated checks for some common defects |
| Screaming Frog’s free HTML crawl | Which linked URLs are discovered, and which responses do they return? |

Automated accessibility checks cover only part of accessibility. Manual keyboard and usability checks remain necessary.

A link crawl can also miss orphan pages by definition. Compare its discovered URLs with your CMS records, intended route list, and sitemap.

For AEO, semantic navigation and accessible explanations make your site easier to interpret and traverse. Treat that as sound web engineering; do not promise a citation increase from changing a button into a link.

When handing over a freelance site, document where new pages must be linked. Publishing a record in the CMS should also place it in an appropriate collection or contextual path, so future content remains discoverable.

> continue

<details><summary>2 previous messages</summary>

> Next we’ll cover measurement: how to use search, analytics, and enquiry data to decide what to improve—and how to explain the results to a freelance client.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://support.google.com/webmasters/answer/7576553?hl=en`
>
> Searched the web for `site.developers.google.com/analytics "generate_lead" "gtag" ...`
>
> </details>
</details>

You now know how to build pages that are discoverable, understandable, and usable. The next skill is **determining whether your work is helping the business—and identifying what to change next**.

For freelancers, this is also how you turn “SEO improvements” into a defensible service.

**Measure a sequence of outcomes**

For Northstar, the customer journey might be:

```text
Search appearance
→ website visit
→ service evaluation
→ enquiry
→ qualified opportunity
→ paid project
```

Each step answers a different question:

| Stage | Question | Useful evidence |
|---|---|---|
| Search visibility | Are people encountering relevant pages? | Search Console |
| Visits | Are people arriving and where do they land? | Website analytics |
| Evaluation | Are they using relevant content and features? | Events and usability observations |
| Enquiries | Are submissions reaching the business? | Form records |
| Qualification | Are those enquiries suitable? | Client review or CRM |
| Revenue | Does the work produce customers? | Business records |

A rise in impressions is useful context. It is not equivalent to a rise in customers.

**Separate search data from website data**

Search Console primarily describes Google Search activity. Website analytics describes activity measured on your site.

Their numbers will not necessarily match.

For example:

- A search click may occur without your analytics recording a visit.
- One visit can contain multiple page views.
- Client-side tracking can be blocked or fail.
- Tools can use different time zones and attribution rules.
- Search reporting may assign data to a canonical URL.

Google recommends using the tools together while understanding their different measurement methods. [Search Console and Analytics guidance](https://developers.google.com/search/docs/monitor-debug/google-analytics-search-console)

Do not spend hours trying to make two differently defined metrics identical.

**Read Search Console metrics carefully**

Four basic metrics appear in its performance reporting:

| Metric | Meaning |
|---|---|
| Impressions | Recorded search appearances under the relevant counting rules |
| Clicks | Recorded clicks to your site |
| CTR | Clicks divided by impressions |
| Average position | An average position measure across recorded impressions |

You can examine these by page, query, country, device, and other available dimensions. [Search Console performance documentation](https://support.google.com/webmasters/answer/7576553?hl=en)

The calculation is:

```text
CTR = clicks ÷ impressions × 100
```

If a page receives 80 clicks from 4,000 impressions:

```text
80 ÷ 4,000 × 100 = 2%
```

But there is no universal “good CTR” that applies equally to every query, position, device, and search presentation.

**A falling average can hide useful growth**

Consider this fictional example:

| Search group | Period A impressions | Period A clicks | Period B impressions | Period B clicks |
|---|---:|---:|---:|---:|
| Searches containing the brand | 2,000 | 100 | 2,000 | 100 |
| Searches without the brand | 4,000 | 20 | 12,000 | 60 |
| **Total** | **6,000** | **120** | **14,000** | **160** |

The branded group has a 5% CTR in both periods.

The other group has a 0.5% CTR in both periods.

Yet the overall CTR falls:

```text
Period A: 120 ÷ 6,000  = 2.00%
Period B: 160 ÷ 14,000 ≈ 1.14%
```

Nothing declined within either group. The site gained more exposure in the lower-CTR group and received more clicks overall.

This is why you investigate **which traffic changed**, rather than reacting to a headline average.

Likewise, average position is not a fixed rank that every searcher sees. Search appearance and counting rules vary. [Google’s metric definitions](https://support.google.com/webmasters/answer/7042828?hl=en)

**Segment by questions that matter to the client**

For Northstar, useful groups might include:

- Brand searches.
- Service-related searches.
- Educational searches.
- Target locations.
- Mobile visitors.
- Individual service pages.

An educational article attracting thousands of unrelated visitors may contribute less than a service page producing a few suitable enquiries.

Branded versus non-branded classification is also imperfect. Account for name variations, and do not assume every query is available in exported data.

**Define a conversion before adding tracking**

A **conversion** is an action you choose to treat as valuable.

For a freelancer’s website:

| Action | What it establishes |
|---|---|
| Click “Contact” | Contact interest |
| Start enquiry form | Form engagement |
| Submit valid enquiry successfully | A recorded enquiry |
| Click email address | An email application may open |
| Book an appointment successfully | A booking, if confirmed by the booking system |

These are not interchangeable.

A click on “Submit” might produce a validation error. A click on an email link does not prove an email was sent.

Name events according to what actually happened.

**Trigger lead measurement after confirmed success**

Google Analytics provides a recommended `generate_lead` event. [Recommended event reference](https://developers.google.com/analytics/devguides/collection/ga4/reference/events?hl=en)

Assuming the Google tag is already configured appropriately on the site, this helper sends that event:

```js
// analytics.js
export function trackProjectEnquiry() {
  if (
    typeof window !== "undefined" &&
    typeof window.gtag === "function"
  ) {
    window.gtag("event", "generate_lead", {
      form_name: "project_enquiry",
    });
  }
}
```

The helper checks whether it is running in a browser and whether the analytics function exists.

Call it in the successful submission branch of your application, **after your server confirms that the enquiry was accepted**.

That call site is an integration point, not a complete submission implementation:

```js
// After your existing submission code confirms success:
trackProjectEnquiry();
```

Do not call it merely because:

- The submit button was clicked.
- A loading state appeared.
- A confirmation component mounted.
- Someone opened a publicly accessible thank-you URL.

Those choices can inflate the count.

`form_name` is an example custom parameter; using it in particular reports may require additional analytics configuration. Do not send the visitor’s message, email address, or other personal details in these event parameters.

Also remember that browser measurement can fail. The server’s enquiry record remains evidence that the submission reached your system.

**Frameworks create different tracking traps**

| Stack | Common trap | Verification |
|---|---|---|
| Plain HTML | Thank-you reloads count as additional leads | Test reload and direct access |
| React–Vite | Initial visit is measured but route changes are missed—or counted twice | Navigate between routes and inspect events |
| Next.js | Shared layouts and client navigation cause duplicated or missing measurement | Test both direct loads and in-app transitions |
| Astro | Optional client routing changes when scripts execute | Test the configured navigation behavior |
| Any stack | Embedded booking/form provider owns the final success state | Use its supported confirmation integration |

Avoid installing several overlapping page-view mechanisms without understanding them. Automatic history measurement plus a custom route listener can double-count.

For a one-page website, scrolling to `#contact` is usually an interaction within the page. Decide whether it deserves an event; do not assume it represents a new document visit.

**Validate analytics like application behavior**

Test a small set of meaningful scenarios:

1. A successful enquiry records one lead.
2. A validation failure records none.
3. A server failure records none.
4. Re-rendering the success interface does not create another event.
5. The enquiry still succeeds if analytics is unavailable.
6. Route changes produce the intended page-view behavior.

Use analytics debugging tools and browser Network inspection where appropriate.

For a low-traffic freelance site, these checks often matter more than building an elaborate dashboard. Small counting errors can distort the entire report.

**Diagnose changes in the order the journey occurs**

Suppose enquiries decline.

Start by locating the change:

| Observation | Investigation |
|---|---|
| Search clicks fall | Demand, visibility, indexing, affected queries |
| Search clicks remain similar; measured visits fall | Tracking, loading, redirects, attribution |
| Visits remain similar; enquiries fall | Form failures, offer changes, visitor relevance |
| Enquiries remain similar; qualified enquiries fall | Targeting, messaging, service fit |
| Qualified opportunities remain similar; sales fall | Business process and commercial factors |

A traffic decline can also come from seasonality, technical changes, reporting issues, or changes in search selection. Avoid immediately blaming a framework or algorithm update. [Google’s traffic-drop guidance](https://developers.google.com/search/docs/monitor-debug/debugging-search-traffic-drops?hl=en)

**Keep a change log**

A short record makes later analysis much easier:

```text
Date:
Affected URLs:
Change:
Reason:
Expected effect:
Verification:
Other changes during this period:
```

For example, changing the page title, pricing, form, and analytics setup simultaneously makes a later increase difficult to attribute.

A change log does not establish causation, but it helps you avoid unsupported explanations.

Compare periods thoughtfully. Matching weekdays can help; seasonal businesses may also need year-over-year context. There is no universal waiting period that makes every experiment conclusive.

**Report AEO as a separate visibility layer**

Keep the distinctions from our earlier AEO lesson:

- First-party AI visibility data has platform-specific scope.
- Manual prompt checks are samples.
- A citation may produce no visit.
- A visit attributed to an AI service may not produce an enquiry.
- An enquiry may involve several earlier discovery channels.

Do not combine citations, impressions, visits, and leads into a single unexplained “AEO score.”

**Use AI to analyze supplied evidence**

A useful assistant task is:

> Compare these two periods by landing page and query group. Calculate changes, identify where the totals are concentrated, and separate observations from possible explanations. Check for changes in tracking and page availability before recommending content edits.

Give it actual exports and your change log. Verify its arithmetic, denominators, and treatment of missing values.

Your client report can then follow a simple sequence:

**What changed → evidence → likely explanation → uncertainty → next action.**

For example:

> Non-branded service-page clicks increased, while branded clicks remained stable. Three suitable enquiries mentioned maintenance. Tracking checks passed. We cannot attribute the increase solely to the recent copy changes; the next step is to review which service queries and landing pages contributed.

That gives the client a decision they can understand and gives you a reasoned basis for the next round of work.

> Cool, now can you perform research into the landscape of agent skills and modern SEO and AEO tools I can use and explain how to use them, what they are, explain them, give me a complete guide to how to use these tools and the use cases

<details><summary>6 previous messages</summary>

> I’ll research the current tools and agent skills, then build a practical guide organized around freelance work: research, implementation, audits, AI visibility, and reporting. I’ll include setup steps, examples, free-plan limits, and guidance on which tools you actually need.
>
> <details><summary>Searched the web</summary>
>
> <details><summary>Explored a file</summary>
>
> - Read `~/.agents/skills/find-skills/SKILL.md`
>
> </details>
>
> Searched the web for `site.skills.sh seo-audit ai-seo ...`
>
> Searched the web for `https://skills.sh/coreyhaines31/marketingskills/seo-audit`
>
> </details>
>
> The clearest distinction so far is between skills that guide an agent’s work and tools that supply evidence. I’m checking both: a popular SEO skill can provide a useful checklist, but it still needs crawl data, browser inspection, and search reporting to support its findings.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://raw.githubusercontent.com/coreyhaines31/marketingskills/main/skills/seo-audit/SKILL.md`
>
> Searched the web for `site.support.google.com/google-ads keyword planner free account setup billing information ...`
>
> Searched the web for `https://support.google.com/notebooklm/answer/16215270?hl=en`
>
> Searched the web for `site.github.com addyosmani web quality skills seo core web vitals ...`
>
> Searched the web for `https://github.com/addyosmani/web-quality-skills`
>
> </details>
>
> I found two details that change the recommendations. Next.js has moved its skills into the main framework repository, so some older install commands are stale. I also found broad claims in a popular AEO skill about ideal answer lengths and visibility gains; I’ll flag those as hypotheses to test, rather than reliable rules.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site.support.google.com/gemininotebook free limits sources notebooks ...`
>
> </details>
</details>

**For your freelance work, I’d build a mostly free toolkit around Search Console, Bing Webmaster Tools, a crawler, browser diagnostics, and a small set of carefully chosen agent skills.** Add paid research or AEO monitoring when a client’s needs justify it.

I reviewed official documentation, current pricing pages, repositories, and several actual skill files. This guide reflects that research as of **November 12, 2026**; it is not a hands-on benchmark of every product.

The most useful distinction is between **instructions, tools, and evidence**.

**1. Understand what you’re installing or buying**

| Category | What it provides | Example |
|---|---|---|
| **Agent skill** | Instructions, checklists, examples, sometimes scripts | An SEO audit skill |
| **MCP server** | A connection through which an agent operates tools or accesses data | Chrome DevTools MCP |
| **Crawler** | A systematic inventory of linked URLs and their properties | Screaming Frog |
| **Search reporting** | Measurements from a particular search platform | Search Console |
| **Research database** | Estimated keywords, backlinks, competitors, or search results | Ahrefs |
| **AEO monitor** | Repeated observations of selected AI answers | OtterlyAI, Peec AI |
| **Validation tool** | Checks a specific implementation | Rich Results Test |

An agent skill commonly consists of a folder containing `SKILL.md`, with optional supporting resources. Installing it gives your agent a workflow; it does not automatically provide search-volume data, browser access, or account credentials. [Agent Skills specification overview](https://agentskills.io/home)

A useful working arrangement is:

```text
Skill guides the investigation
→ tools collect evidence
→ agent interprets findings
→ you review changes
→ tools verify the result
```

An “SEO expert” skill without evidence can still produce a confident, inaccurate audit.

---

**2. Agent skills worth considering**

These are the strongest starting candidates I found for your needs. Counts are approximate directory figures observed during research, not quality scores.

| Skill | Source and observed adoption | Best use | My assessment |
|---|---|---|---|
| [SEO](https://www.skills.sh/addyosmani/web-quality-skills/seo) | Addy Osmani’s Web Quality Skills; ~55,200 installs; repository ~3,100 stars | Technical implementation and audits | Good starting choice across your frameworks |
| [Core Web Vitals](https://www.skills.sh/addyosmani/web-quality-skills/core-web-vitals) | Same collection; ~34,900 installs | Performance diagnosis | Particularly useful with browser traces |
| [Vercel React Best Practices](https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices) | Vercel; ~894,700 installs; repository ~34,000 stars | React and Next.js performance | Useful specialist companion |
| [SEO Audit](https://www.skills.sh/coreyhaines31/marketingskills/seo-audit) | Corey Haines’s community collection; ~253,300 installs; repository ~60,000 stars | Broader SEO investigation and prioritization | Useful with evidence and editorial review |
| [AI SEO](https://www.skills.sh/coreyhaines31/marketingskills/ai-seo) | Same collection; ~163,800 installs | AEO research and content-review workflows | Optional; apply greater skepticism to its platform claims |

The first two are community-maintained resources, rather than official Google Search policy. Vercel’s collection is an official Vercel source.

**How to install selected skills**

You need Node.js/npm available. Run commands from your intended project directory and follow the installer’s agent and scope choices.

For example:

```powershell
npx skills add addyosmani/web-quality-skills --skill seo
```

```powershell
npx skills add addyosmani/web-quality-skills --skill core-web-vitals
```

```powershell
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices
```

For the broader marketing audit:

```powershell
npx skills add coreyhaines31/marketingskills --skill seo-audit
```

The CLI downloads skills and configures them for supported agents. Check the resulting files and installer output to confirm their scope. [Skills CLI documentation](https://www.skills.sh/docs/cli)

Start with a small set. Multiple overlapping skills can introduce conflicting assumptions and unnecessary instructions.

**How to use them effectively**

Give the agent:

- Your framework and version.
- The local project or public URL.
- The purpose of the website.
- Representative public routes.
- Available crawl, performance, or search data.
- A specific requested outcome.

The Web Quality SEO skill explicitly distinguishes technical checks from ranking predictions. Its Core Web Vitals companion asks for measurements before declaring a metric defective. Those are useful properties in an audit workflow. [SEO skill source](https://raw.githubusercontent.com/addyosmani/web-quality-skills/main/skills/seo/SKILL.md), [Core Web Vitals workflow](https://www.skills.sh/addyosmani/web-quality-skills/core-web-vitals)

A reusable instruction:

Use the installed SEO skill to audit this project and its deployed public pages.

First identify the framework, rendering strategy, intended audience, and business objective. Compare response HTML with rendered content on representative routes.

For each finding, provide:
- Evidence and affected URLs or files.
- Whether it is a confirmed defect, a hypothesis, or a suggestion.
- Likely user or search consequence.
- The smallest appropriate fix.
- A verification method.

Prioritize access, rendering, status codes, indexing controls, canonical consistency, and broken navigation before cosmetic metadata changes.

Do not infer rankings, search volumes, backlinks, Core Web Vitals failures, or AI citation gains without relevant measurements.

**What I found when reading the actual skill files**

Popularity does not remove the need to review instructions.

For example, the community AEO skill includes prescriptive answer-length recommendations and numerical visibility claims. Treat those as claims requiring source review and testing, rather than dependable outcomes for your clients. [AI SEO skill source](https://raw.githubusercontent.com/coreyhaines31/marketingskills/main/skills/ai-seo/SKILL.md)

Likewise, distinguish these statements:

- An HTML-to-text reader may discard script tags.
- A raw HTTP response contains server-delivered JSON-LD.
- Neither necessarily reveals JSON-LD inserted later by browser JavaScript.

That precision matters when an audit reports “no structured data.”

**A current Next.js change**

Older tutorials recommend installing `next-best-practices` from `vercel-labs/next-skills`. That repository now says the skills moved into the main Next.js repository. It also says that former reference knowledge is provided through bundled documentation and generated agent rules in newer Next.js versions.

Use the current repository’s instructions rather than copying an old command. [Next.js skills migration notice](https://github.com/vercel-labs/next-skills)

---

**3. Browser MCP tools: give your agent something to inspect**

For a developer, these are often more valuable than adding another SEO checklist.

**Chrome DevTools MCP**

**What it is:** An official Chrome DevTools project that lets compatible agents inspect browser behavior, network activity, and performance.

**Use cases:** Diagnose a slow hero image, inspect failed requests, investigate rendering, or compare a fix against a trace.

Its generic MCP configuration is:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

This is an example configuration shape; your client may use a different settings format. The project requires a supported Node.js LTS release, Chrome, and npm. [Chrome DevTools MCP setup](https://github.com/ChromeDevTools/chrome-devtools-mcp)

After connecting it:

1. Serve the production build locally or supply the deployed URL.
2. Ask the agent to record a performance trace.
3. Request evidence identifying the bottleneck.
4. Make one focused change.
5. Repeat under equivalent conditions.

The package also includes specialized skills, including LCP debugging. It does not reproduce Googlebot or prove indexing.

**Microsoft Playwright MCP**

**What it is:** A browser-automation connection maintained by Microsoft.

**Use cases:** Test navigation, direct route visits, menus, forms, mobile layouts, and rendered document structure.

Generic configuration:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

[Official Playwright MCP repository](https://github.com/microsoft/playwright-mcp)

A useful task is:

> Visit every public route directly, reload it, inspect headings and links, follow the main navigation, and report broken destinations or content missing after loading.

Use browser tools against public or test environments when investigating forms. Keep genuine enquiry submission separate from navigation testing.

**Which should you choose?**

My recommendation:

- Start with **Chrome DevTools MCP** for performance and technical diagnosis.
- Add **Playwright MCP** when repeated user-flow checks become useful.
- You do not need both for every project.

The software can be free while your agent usage still incurs model costs.

---

**4. Google Search Console: establish what Google observes**

**What it is:** Google’s first-party search reporting and diagnostic service.

**Best use cases:** Indexing investigation, query research, canonical diagnosis, search-performance reporting.

**Setup**

1. Add the client’s site.
2. Prefer a Domain property when you can verify DNS and need domain-wide coverage.
3. Otherwise, use an appropriate URL-prefix property and supported verification method.
4. Have the client retain ownership and grant you suitable access.
5. Submit the sitemap where appropriate.

Verification proves control; it does not cause ranking improvements. [Ownership verification documentation](https://support.google.com/webmasters/answer/9008080?hl=en)

**Your recurring workflow**

1. Inspect an important URL.
2. Review its indexing status and available crawl details.
3. Compare the declared canonical with Google’s selection.
4. Open performance reporting.
5. Filter by page, query, device, or country.
6. Compare meaningful periods.
7. Export evidence for analysis.

The performance report provides clicks, impressions, CTR, and average-position information with several dimensions. [Performance reporting](https://support.google.com/webmasters/answer/7576553?hl=en)

**Example:** A maintenance guide gets impressions for pricing searches. Check whether it actually answers cost questions before creating another page.

**Limit:** Search Console describes Google’s observations, not a complete picture of all search engines or customer behavior.

**Current AEO capability**

Google documents a Generative AI performance report for supported Search features. It reports impressions, and may not appear when the property has insufficient relevant impressions. Read its definitions before comparing it with other vendors’ citation metrics. [Generative AI reporting](https://support.google.com/webmasters/answer/16984139)

---

**5. Bing Webmaster Tools and IndexNow**

**What they are:** Bing’s first-party webmaster reporting, plus a protocol for notifying participating engines about changed URLs.

**Best use cases:** Bing discovery, indexing diagnosis, and visibility in supported Microsoft AI experiences.

**Setup and use**

1. Sign into Bing Webmaster Tools.
2. Add and verify the site, or use its Search Console import option.
3. Review sitemap and URL information.
4. Inspect crawl and search findings.
5. Review AI Performance where available.

Bing supports importing verified sites from Search Console. [Bing setup guidance](https://blogs.bing.com/webmaster/2025/6/Start-Using-Bing-Webmaster-Tools-to-Improve-Your-Site-Visibility/)

**IndexNow workflow**

1. Follow the protocol’s key-verification setup.
2. Notify participating engines when public URLs are added, updated, or deleted.
3. Connect notifications to your publishing process.
4. Check resulting reports.

For Astro or prerendered React, notify after the new content is deployed. For a CMS-driven Next.js site, coordinate notifications with publication and cache updates.

IndexNow is a notification mechanism. It does not guarantee crawling or indexing, and it is not a universal Google indexing shortcut. [IndexNow documentation](https://www.bing.com/indexnow/getstarted)

Bing’s AI reporting covers supported Microsoft and selected partner experiences. It does not measure every AI assistant. [AI Performance announcement](https://blogs.bing.com/webmaster/2026/2/Introducing-AI-Performance-in-Bing-Webmaster-Tools-Public-Preview/)

---

**6. Research tools: discover demand and understand the customer**

**Google Trends**

**What it is:** A tool showing normalized relative search interest.

**Use it for:** Terminology comparisons, regional interest, and seasonality.

**Workflow**

1. Compare candidate terms.
2. Set the target geography.
3. Examine a longer period.
4. Check related topics or queries.
5. Record findings as directional evidence.

A score of 100 is a relative peak, not 100 searches. Low-volume niche queries may have insufficient data. [Trends methodology](https://support.google.com/trends/answer/4365533?hl=en)

**Example:** Compare “website maintenance” and “website support” before deciding which language to investigate further.

**Google Keyword Planner**

**What it is:** An advertising research tool that supplies keyword ideas and search estimates.

**Use it for:** Expanding a seed list, investigating demand, and understanding commercially relevant terminology.

**Workflow**

1. Complete the required Google Ads account setup.
2. Open Keyword Planner.
3. Start with service terms or a relevant website.
4. Set location and language.
5. Export candidates.
6. Classify them by user task.
7. Inspect actual search results before planning pages.

Google’s current help says billing information and completed setup are required for basic access. Do not assume older “no setup required” tutorials still apply. [Keyword Planner documentation](https://support.google.com/google-ads/answer/7337243?hl=en-en)

Advertising competition is not a direct measure of organic ranking difficulty.

**Ahrefs Free**

**What it is:** Limited access to several Ahrefs tools, including verified-site auditing and site research.

The current help page lists:

- Site Audit: **5,000 crawl credits per month per project**.
- Site Explorer: **1,000 backlinks and keywords visible at once**.
- Ownership verification for those capabilities.

[Ahrefs free-account limits](https://help.ahrefs.com/en/articles/13002606-what-can-i-use-for-free-in-ahrefs)

**Workflow**

1. Verify your site.
2. Run a baseline audit.
3. Review errors by affected page type.
4. Inspect available search and backlink information.
5. Export findings.
6. Recheck after fixes.

**Best fit:** Monitoring your own sites or clients who authorize verification.

**Limit:** This is not unrestricted free competitor research.

For substantial competitor keyword and backlink work, evaluate a paid research suite. **Ahrefs and Semrush** are alternatives; compare geography, data coverage, export limits, projects, and API access before subscribing. [Semrush’s current product tiers](https://www.semrush.com/pricing/seo-ai-search/)

---

**7. AI research assistants: synthesize sources without inventing evidence**

**Google’s source-grounded notebook tool**

You may know it as NotebookLM; current Google help calls it **Gemini Notebook**.

**What it is:** A research workspace that answers questions using selected imported sources and provides source references.

**Use cases:** Turn verified client documents, interviews, product information, and reference material into a content brief.

**Workflow**

1. Create a notebook for one client or topic.
2. Add approved source material.
3. Select the relevant sources.
4. Ask for customer questions, contradictions, and missing information.
5. Follow citations back to the original material.
6. Convert verified findings into page briefs.

Google’s help describes imported sources and source selection. Copies and synchronization behavior depend on source type, so check freshness. [Source handling](https://support.google.com/gemininotebook/answer/16215270?hl=en), [source-based chat](https://support.google.com/gemininotebook/answer/16179559?hl=en)

Free access exists, with usage limits and upgrade options. [Plans and access](https://support.google.com/gemininotebook/answer/16213268?hl=en-IN)

**Google AI Studio**

**What it is:** A development and experimentation environment for Gemini models.

**Use cases:** Classify search queries, review copy against supplied facts, analyze small audit exports, or prototype structured outputs.

**Workflow**

1. Choose a model available to your account.
2. Supply the task, evidence, and output format.
3. Test a small sample.
4. Check accuracy.
5. Expand only after the sample works.

Free-tier availability varies by model and account conditions; paid API access is a separate consideration. [Billing documentation](https://ai.google.dev/gemini-api/docs/billing?hl=en), [current pricing](https://aistudio.google.com/docs/pricing)

For either tool, source references do not eliminate the need to verify conclusions.

Using only the supplied client material and search data, produce a content research brief.

Identify:
- Customer tasks and questions.
- Suggested page groups.
- Verified facts supporting each page.
- Missing information requiring client input.
- Claims requiring external research.
- A suitable next step for each page’s visitor.

Do not invent search volumes, testimonials, credentials, prices, case-study results, or platform requirements. Cite the supplied source supporting each factual claim.

---

**8. Screaming Frog: build a site inventory**

**What it is:** A desktop crawler that follows links and records URL-level properties.

**Use cases:** Broken links, redirects, metadata, indexing directives, duplicate patterns, and migration checks.

The free version crawls up to **500 URLs per crawl**. JavaScript rendering, saved crawls, and various advanced capabilities require a licence. [Official feature comparison](https://www.screamingfrog.co.uk/seo-spider/pricing/)

**A practical first crawl**

1. Enter the public homepage.
2. Start the crawl.
3. Review response codes.
4. Review titles, descriptions, headings, canonicals, and directives.
5. Select a problematic URL and inspect its incoming links.
6. Export relevant findings.
7. Group issues by template or component.

Fixing one shared navigation component may repair fifty broken links. That is usually more useful than treating each row as an independent task.

**Framework-specific interpretation**

| Site | How to interpret the crawl |
|---|---|
| HTML | Raw HTML is usually representative of delivered content |
| React–Vite CSR | Raw crawl may expose an empty shell and few links |
| Prerendered React | Verify generated route content is present |
| Next.js | Check several route types, not only the homepage |
| Astro | Check generated collections and any client-only content |

With the paid version, compare text-only and JavaScript rendering when investigating browser-generated content. The rendering setting is under the spider configuration. [JavaScript crawl guidance](https://www.screamingfrog.co.uk/seo-spider/tutorials/crawl-javascript-seo/)

A crawler’s browser engine does not establish what Google indexed.

---

**9. Performance and markup validation**

These tools answer narrower questions than a general SEO platform.

| Tool | What it checks | How to use it |
|---|---|---|
| [PageSpeed Insights](https://pagespeed.web.dev/) | Lab performance and available real-user data | Test representative URLs, inspect metric-level findings |
| Chrome Lighthouse | Automated performance, accessibility, SEO, and related checks | Run against the production build |
| [Schema Markup Validator](https://validator.schema.org/) | Schema.org syntax and vocabulary | Test the actual generated markup |
| [Rich Results Test](https://search.google.com/test/rich-results) | Supported Google structured-data features | Test both draft code and deployed URL |

**A useful validation sequence**

1. Test the homepage, one service page, one article, and one complex interactive page.
2. Identify repeated failures.
3. Fix the shared cause.
4. Repeat comparable tests.
5. Record what remains unverified.

For example, a correct JSON-LD object can pass Schema validation without qualifying for a dedicated Google rich result.

Likewise, a high Lighthouse SEO score does not establish relevance, indexing, backlinks, or AI citations.

**Unlighthouse**

**What it is:** A free, open-source tool that runs Lighthouse across a site and groups the results.

**Use case:** Find whether one template performs worse than the rest.

Its documented CLI usage includes:

```powershell
npx unlighthouse --site https://example.com
```

Check the requirements for the release you choose; its newer beta has different requirements from older releases. [Unlighthouse installation](https://unlighthouse.dev/guide/getting-started/installation), [current project overview](https://unlighthouse.dev/)

Use it after the site can be crawled. It is not a substitute for a detailed trace of a failing interaction.

**Lighthouse CI**

**What it is:** Automation for repeatedly running Lighthouse and detecting regressions.

**Use case:** Catch a performance decline after adding a dependency or changing a template.

**Workflow**

1. Serve a production build.
2. Configure representative URLs.
3. Run multiple samples.
4. Set sensible warnings or assertions.
5. Preserve reports.
6. Investigate meaningful changes.

[Official getting-started guide](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md)

Automated lab checks cannot immediately prove that real-user Core Web Vitals improved.

---

**10. Paid AEO monitors: useful when you have a defined question**

These products repeatedly observe selected AI answers. Their value comes from consistent sampling, competitor comparison, source analysis, and reporting.

They do not provide access to every user conversation.

| Tool | What it offers | Current entry-point information |
|---|---|---|
| [OtterlyAI](https://otterly.ai/pricing) | Prompt monitoring, brand visibility, and citation-source tracking | Listed Lite plan: **€29/month**, 16 prompts, four of seven engines; trial offered |
| [Peec AI](https://peec.ai/pricing) | Prompt-based AI visibility, competitor and source analysis | Listed Starter: **$95/month**, 50 prompts, three selected models, one project |
| [Ahrefs Brand Radar](https://ahrefs.com/brand-radar) | Research across an answer dataset and custom prompt tracking | Separate product/entitlements; distinguish dataset research from your own tracked prompts |

Those are vendor-listed figures observed during research. Check billing selections, taxes, engine coverage, and current limits before buying.

**How to use a monitor well**

1. Define the business question.
2. Build a small, representative prompt set.
3. Separate branded and non-branded questions.
4. Set the appropriate language and market.
5. Add actual competitors.
6. Review cited sources and answer accuracy.
7. Associate content changes with dated observations.
8. Compare visibility with visits and qualified enquiries.

For a consultancy client, categories might include:

```text
Finding a provider
Comparing approaches
Understanding costs
Evaluating risks
Checking the client’s brand
```

Avoid making every prompt a variation of “Why is Northstar the best?” That tests a biased sample.

**How to interpret results**

If a competitor appears more frequently, investigate the cited pages:

- Are they the competitor’s own pages?
- A directory?
- An editorial comparison?
- A review platform?
- Official documentation?

Then decide whether the missing information belongs on your site or whether legitimate external evidence is lacking.

A metric such as “visibility” or “share of voice” is defined by the vendor’s sample and methodology. It is not necessarily market share.

**When to buy**

For a new five-page freelance website with little traffic, I would start with first-party reports and manual research.

A monitor becomes easier to justify when a client needs recurring competitor analysis, operates in a category with substantial AI-assisted research, or pays for ongoing content work that needs consistent observation.

---

**11. SEO data MCPs: connect research databases to an agent**

Browser MCPs inspect pages. Data MCPs retrieve commercial research data.

**Ahrefs MCP**

**What it does:** Lets compatible AI clients request Ahrefs data through its supported integration.

**Use cases:** Competitor pages, keyword opportunities, backlink analysis, and supported brand research.

**Setup**

1. Obtain an eligible subscription.
2. Follow Ahrefs’ current remote-server connection instructions.
3. Authorize the client.
4. Start with a bounded request.
5. Check returned dates, geography, rows, and unit usage.

Ahrefs currently documents access on **Lite and higher plans**. Calls consume integration API units, with plan-specific limits. Its free verified-site account does not imply free MCP access. [Ahrefs MCP documentation](https://help.ahrefs.com/en/articles/13913559-getting-started-with-ahrefs-mcp)

**DataForSEO MCP**

**What it does:** Exposes supported SEO and search-data APIs to an agent.

**Use cases:** Custom keyword research, location-specific search-result collection, and repeatable research pipelines.

**Setup**

1. Create the provider account.
2. Review the chosen endpoints and charges.
3. Connect the official hosted or self-hosted MCP option.
4. Set a bounded task and spending limit.
5. Save results so you do not repeatedly purchase the same data.

The MCP connection does not make the underlying data calls free. [Official DataForSEO MCP guide](https://dataforseo.com/seo-mcp-server)

For a freelancer, manually exporting data is often simpler until the same task recurs frequently.

A good request specifies:

```text
Market: United States
Language: English
Topic: website maintenance services
Maximum candidates: 30
Requested evidence: provider, date, location, and metric definitions
```

An unbounded “research everything about this industry” request can consume money and generate difficult-to-review output.

---

**12. Reporting and local-business tools**

**GA4**

Use Google Analytics to measure on-site activity and relevant events. Create a property and web data stream, implement the tag, validate collection, and define meaningful outcomes. [Analytics setup](https://support.google.com/analytics/answer/9304153?hl=en)

For your frameworks, verify both direct page loads and client navigation. Avoid double-counting through overlapping tracking implementations.

Measure successful enquiries separately from button clicks. Retain server-side enquiry records as business evidence.

**Looker Studio**

Use it when a client needs repeatable reporting across search and website data. Start with a small report: relevant search clicks, landing pages, confirmed enquiries, and a change log.

Keep Search Console and Analytics metrics distinguishable rather than forcing their counts to agree. Google documents their complementary roles and reporting differences. [Combined reporting guidance](https://developers.google.com/search/docs/monitor-debug/google-analytics-search-console)

**Google Business Profile**

For eligible local businesses, this can be more immediately useful than another website audit subscription.

1. Confirm eligibility.
2. Claim or create the profile.
3. Complete verification.
4. Maintain accurate categories, hours, services, and contact details.
5. Review customer interactions and keep information current.

Do not create fictitious locations. [Business Profile getting started](https://support.google.com/business/answer/7039811?hl=en)

---

**13. Apply the toolkit to your frameworks**

| Project type | First tools | What to investigate |
|---|---|---|
| Single-page HTML site | Raw response, Lighthouse, schema validators, Search Console | Focused content, metadata, links, images, indexing |
| React–Vite CSR | Browser inspection, raw-vs-rendered comparison, crawler, Playwright | Missing initial content, deep routes, metadata changes, hosting responses |
| Prerendered React | Crawler, production-output inspection, browser checks | Generated routes, build-time data, freshness |
| Next.js | Browser diagnostics, crawler, framework docs, React performance skill | Route variants, metadata, caching, client dependencies |
| Astro | Crawler, Lighthouse, browser inspection | Generated collections, image delivery, hydration, client-only content |

For a single-page site, duplicating sections into dozens of low-value URLs is not a tool-driven improvement. The limitation may be content scope rather than framework choice.

For React–Vite, an empty raw crawl is a diagnostic finding. It is not a complete verdict on Google’s processing.

For Next.js and Astro, framework defaults do not remove the need to inspect production.

---

**14. Three practical workflows you can sell or use yourself**

**A new small-business website**

1. Gather verified business facts.
2. Research customer language with search results and Trends.
3. Create the page map.
4. Use a source-grounded assistant to draft briefs.
5. Implement with the appropriate skill.
6. Validate rendering, navigation, markup, and performance.
7. Configure first-party reporting.
8. Verify enquiry measurement.

**Deliverables:** Page map, deployed site, validation findings, access handover, measurement plan.

**An existing React–Vite site with poor visibility**

1. Inspect the actual responses.
2. Compare raw and rendered content.
3. Review Search Console evidence.
4. Crawl available routes.
5. Separate rendering defects from content and demand problems.
6. Implement the smallest justified fix.
7. Recheck the same pages and tests.

**Deliverables:** Evidence-based diagnosis, prioritized fixes, before/after technical verification.

**An ongoing SEO/AEO client**

1. Review first-party search and enquiry data.
2. Examine affected page and query groups.
3. Investigate selected competitor sources.
4. Improve missing information or verified technical defects.
5. Use a paid AI monitor only when recurring observation is part of the engagement.
6. Report findings, uncertainty, and next actions.

**Deliverables:** Change log, source-backed recommendations, implemented improvements, measured observations.

---

**15. What I would start with in your position**

My recommended initial setup is:

- **Skills:** Web Quality SEO, Core Web Vitals, and Vercel React Best Practices when using React.
- **Agent tools:** Chrome DevTools MCP; Playwright MCP when flow testing becomes repetitive.
- **Search evidence:** Search Console and Bing Webmaster Tools.
- **Crawling:** Screaming Frog Free, supplemented by browser inspection.
- **Research:** Trends, actual search results, verified client material, and a source-grounded assistant.
- **Validation:** PageSpeed Insights and both structured-data validators.
- **Measurement:** Analytics plus confirmed enquiry records.

My first paid upgrade would depend on the work:

| Recurring need | Upgrade to consider |
|---|---|
| JavaScript crawling, saved audits, migrations | Screaming Frog licence |
| Competitor keyword/backlink research | A paid research suite |
| Repeated AI-answer monitoring | One AEO monitor |
| Custom research automation | A metered data API/MCP |
| Mostly small static builds | Continue with the free stack |

Use **one clear question per investigation**, collect evidence, make a focused change, and verify it. That process will contribute more to your freelance work than installing every SEO skill or subscribing to several overlapping dashboards.

> Go very very into depth into using the chrome devtools MCP for testing the app end to end along with different chrome profiles for auto auth, doing UX audits and performance audits, and how to use the devtools MCP to an adavnced level to get the most bang for your buck in terms of SEO, performance, UX, and accesisbility

<details><summary>6 previous messages</summary>

> I’ll check Chrome DevTools MCP’s current capabilities and profile/authentication options, then build a detailed workflow for end-to-end testing, UX, performance, SEO, and accessibility. I’ll distinguish what it can verify directly from checks that need other tools or manual review.
>
> <details><summary>Searched the web</summary>
>
> <details><summary>Explored a file</summary>
>
> - Read `~/.codex/plugins/cache/openai-curated-remote/product-design/0.1.56/skills/audit/SKILL.md`
>
> </details>
>
> Searched the web for `https://github.com/ChromeDevTools/chrome-devtools-mcp`
>
> Searched the web for `https://github.com/ChromeDevTools/chrome-devtools-mcp/tree/main/docs`
>
> Searched the web for `https://raw.githubusercontent.com/ChromeDevTools/chrome-devtools-mcp/main/docs/advanced-usage.md`
>
> </details>
>
> Authentication needs two distinct setups: persistent test profiles for routine signed-in work, and clean browser contexts for first-visit and public-page checks. I also confirmed an important detail: `--autoConnect` reuses Chrome’s selected default profile; it is not a reliable way to choose an arbitrary named profile. I’ll show a more deterministic setup for multiple accounts.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://raw.githubusercontent.com/ChromeDevTools/chrome-devtools-mcp/main/src/tools/performance.ts`
>
> Searched the web for `https://raw.githubusercontent.com/ChromeDevTools/chrome-devtools-mcp/main/src/tools/network.ts`
>
> </details>
>
> There’s another important distinction in the current tools: `lighthouse_audit` checks accessibility, SEO, best practices, and agentic browsing, but excludes performance. Performance work uses the trace tools. I’m also checking how mocks, caches, and authenticated sessions affect measurements so the guide helps you avoid misleading results.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics`
>
> </details>
</details>

**Chrome DevTools MCP is most valuable when you use it as a browser investigation and verification system.** It can explore your app, reproduce failures, connect UI behavior to network requests, inspect accessibility semantics, and diagnose performance.

For your freelance work, I recommend three testing environments:

| Environment | Purpose |
|---|---|
| **Persistent authenticated profile** | Reuse a test account for normal application testing |
| **Fresh isolated context** | Test anonymous visitors, first visits, onboarding, and session boundaries |
| **Controlled performance environment** | Compare measurements without unrelated tabs, extensions, mocks, or changing conditions |

The setup and examples below are based on the official documentation and source reviewed on **November 12, 2026**. The project evolves quickly: **your installed tool schemas take precedence over examples from a newer repository version.**

One important current distinction: the MCP’s **`lighthouse_audit` excludes performance**. It covers accessibility, SEO, best practices, and agentic browsing. Performance analysis uses the trace tools. [Current Lighthouse implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/lighthouse.ts)

---

**1. Understand the system you are controlling**

There are four separate components:

```text
Your agent
→ Chrome DevTools MCP server
→ a particular Chrome instance
→ tabs, browser contexts, and application sessions
```

Confusing these components causes many authentication and testing problems.

- **MCP server:** The process exposing tools to your agent.
- **Chrome instance:** A browser process the server launches or connects to.
- **User data directory:** Persistent browser data containing profiles.
- **Browser context:** An isolated cookie/storage environment within the browser.
- **Page:** A tab or other inspectable target.
- **Application session:** Your app’s authenticated state, usually maintained through cookies or tokens.

Logging into Chrome itself is different from logging into your application. Chrome Sync is not required to preserve an application login in a persistent test profile.

Also, two tabs do not automatically represent two independent users. Tabs in the same browser context usually share relevant cookies and storage.

**What it is particularly good at**

| Goal | Evidence you can collect |
|---|---|
| Functional testing | UI state, navigation, requests, responses, console errors |
| UX review | Screenshots, task progression, loading and recovery behavior |
| Accessibility | Accessibility-tree snapshots, keyboard behavior, automated findings |
| Performance | Traces, resource timing, main-thread work, performance insights |
| Technical SEO | Delivered HTML, rendered metadata, links, status codes, directives |
| Authentication debugging | Redirect chains, cookie attributes, session-dependent responses |

It is not a search index, a real-user analytics system, or a complete accessibility conformance assessment.

---

**2. Install it with a deliberate browser strategy**

The generic configuration is:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

Your agent’s settings may use a different configuration format. The server requires a supported Node.js LTS release, npm, and supported Chrome. The browser normally starts when a tool first needs it, rather than immediately when the MCP server connects. [Official setup](https://github.com/ChromeDevTools/chrome-devtools-mcp)

Before adding advanced settings, check the installed options:

```powershell
npx -y chrome-devtools-mcp@latest --help
```

Once a configuration works, consider pinning the package to that verified version for repeatable client work. Update the server and its companion skills together.

Keep these bundled skills available when useful:

| Skill | Use |
|---|---|
| `chrome-devtools` | General browser investigation |
| `a11y-debugging` | Accessibility investigation |
| `cookie-debugging` | Session and cookie problems |
| `debug-optimize-lcp` | Loading-performance diagnosis |
| `memory-leak-debugging` | Long-session memory problems |

The project documents supported installation methods and warns that outdated skills can describe tools or parameters that changed. [Bundled skills](https://github.com/ChromeDevTools/chrome-devtools-mcp#skills)

---

**3. Persistent profiles: log in once and reuse the session**

For routine testing, use a dedicated persistent browser directory.

Example configuration—replace `YOUR_NAME`:

```json
{
  "mcpServers": {
    "chrome-qa-member": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--user-data-dir=C:/Users/YOUR_NAME/AppData/Local/Chrome-MCP/client-a-member"
      ]
    }
  }
}
```

Then:

1. Ask the agent to open your staging application.
2. Sign into the intended test account in that browser.
3. Complete MFA or other interactive authentication yourself if required.
4. Confirm the intended account and environment.
5. Reuse the same directory for later sessions.

This is **session reuse**, rather than an authentication bypass.

It works only while the application’s session remains valid. Server-side expiration, revocation, session-only cookies, and provider policies can still require another login.

The MCP’s default browser directory is already persistent. An explicit directory makes ownership and purpose clearer, especially across clients. Only one running browser instance should own a particular directory at a time. [Profile persistence documentation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/advanced-usage.md)

**Recommended organization**

```text
Chrome-MCP/
  client-a-member/
  client-a-admin/
  client-b-member/
  performance-baseline/
```

These are separate browser-data roots. Avoid storing them in a source repository or copying your everyday browsing profile into the project.

**Understand a common directory mistake**

Chrome distinguishes:

```text
User data directory
└── Default
    or Profile 1
    or Profile 2
```

`--user-data-dir` expects the parent data directory, rather than an existing profile subfolder.

Open `chrome://version` and inspect **Profile Path** when diagnosing which profile Chrome actually opened. Its parent is the user data directory. [Chromium profile documentation](https://chromium.googlesource.com/chromium/src/+/main/docs/user_data_dir.md)

---

**4. Reuse an existing signed-in Chrome session with `--autoConnect`**

This is convenient when you are manually investigating a bug and want the agent to continue from your current state.

The documented flow is:

1. Start a supported Chrome version—this connection mechanism requires Chrome 144 or later.
2. Open `chrome://inspect/#remote-debugging`.
3. Enable incoming debugging connections.
4. Configure the MCP with `--autoConnect`.
5. Accept Chrome’s connection request.

Example:

```json
{
  "mcpServers": {
    "chrome-live-session": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--autoConnect"
      ]
    }
  }
}
```

Chrome asks permission when the debugging connection is requested. This is browser behavior, not something the agent should bypass. [Chrome’s connection walkthrough](https://developer.chrome.com/blog/chrome-devtools-mcp-debug-your-browser-session)

**The important multi-profile limitation:** current documentation says automatic connection selects Chrome’s default profile as determined by Chrome, with access to that profile’s open windows. Do not assume it selects whichever named profile you intended. [Advanced connection documentation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/advanced-usage.md)

Use this mode for deliberate live-session collaboration. For deterministic member/admin testing, use separate browser instances and endpoints.

---

**5. Deterministic multi-account authentication: separate directories and ports**

This is the setup I would choose for testing different roles reliably.

First, start a dedicated Chrome instance yourself. On Windows, an example is:

```powershell
$chromeExecutable = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$memberProfile = Join-Path $env:LOCALAPPDATA 'Chrome-MCP\client-a-member'

& $chromeExecutable `
  "--user-data-dir=$memberProfile" `
  '--remote-debugging-port=9222' `
  '--remote-debugging-address=127.0.0.1' `
  'http://localhost:4173'
```

Adjust the executable and application URL for your machine.

Sign in manually. Then connect the MCP:

```json
{
  "mcpServers": {
    "chrome-member": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--browser-url=http://127.0.0.1:9222"
      ]
    },
    "chrome-admin": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--browser-url=http://127.0.0.1:9223"
      ]
    }
  }
}
```

For the admin browser, launch another instance with a different directory and port:

| Role | Directory | Debugging endpoint |
|---|---|---|
| Member | `client-a-member` | `127.0.0.1:9222` |
| Admin | `client-a-admin` | `127.0.0.1:9223` |

The endpoint is Chrome’s debugging address. It is **not your application’s URL**.

This setup also helps when an identity provider rejects a browser launched directly through automation: authenticate in the manually started test browser, then attach.

Chrome 136 and later restrict remote-debugging switches against the normal default Chrome data directory. Use a non-default directory for this launch method. [Chrome’s remote-debugging change](https://developer.chrome.com/blog/remote-debugging-port)

Keep the debugging endpoint local. It grants browser control, so use dedicated test accounts and avoid unrelated sensitive browsing in that instance.

---

**6. Fresh contexts: test the experience your saved session hides**

Persistent authentication is convenient, but it can conceal problems:

- A first-visit consent banner blocks navigation.
- Public content accidentally depends on saved credentials.
- Onboarding works only because an earlier test created data.
- A dashboard displays cached information from another account.

Current `new_page` supports named isolated contexts.

Illustrative tool arguments:

```json
{
  "url": "https://staging.example.com/",
  "isolatedContext": "anonymous-audit-run-01"
}
```

A second page using the same context name shares that context’s cookies and storage. Use a different name for a separate clean environment. [Page/context implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/pages.ts)

Do not assume a named isolated context provides persistent login across browser restarts. Use an explicit persistent profile when that is the requirement.

**These are different operations**

| Operation | What it changes |
|---|---|
| New tab in the same context | Usually retains relevant authentication |
| New isolated context | Separates browser cookies/storage |
| Ignore HTTP cache | Changes cache usage, not login |
| Clear local storage | Does not necessarily clear cookie-based authentication |
| Log out | Invokes the application’s logout behavior |
| Reset test database | Changes server-side fixtures |

Clearing `localStorage` does not clear an `HttpOnly` session cookie. Page JavaScript cannot access those cookies. A fresh context is often the simplest way to establish a clean browser state. [Cookie-debugging guidance](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/skills/cookie-debugging/SKILL.md)

A clean browser context also does not reset server-side account data.

---

**7. Establish a browser contract before a large audit**

The agent needs to know what it may test and which evidence counts as success.

Use Chrome DevTools MCP to test the application.

Before interacting:
- Identify the environment, browser connection, account role, and relevant page IDs.
- Use a fresh isolated context for anonymous checks.
- Reuse only the designated test profile for authenticated checks.
- Confirm account identity through an appropriate visible indicator without exposing credentials or token values.
- Read the current tool schemas before constructing calls.

For each scenario, record:
- Preconditions and test data.
- User actions.
- Expected outcome.
- Observed UI and relevant network outcome.
- Evidence files.
- Pass, fail, blocked, or not tested.

Use normal UI interactions for functional checks. Use JavaScript evaluation for inspection or explicitly labeled test setup, rather than silently bypassing the flow being tested.

Use test records and test integrations. Stop at actions outside the agreed test scope.

For an actual client project, specify whether submitting forms, sending invitations, making purchases, deleting records, or publishing content is authorized.

That prevents a broad “test everything” instruction from becoming an uncontrolled production exercise.

---

**8. Learn the efficient observation-and-action loop**

The reliable loop is:

```text
Identify page
→ observe current state
→ act using observed controls
→ wait for meaningful evidence
→ verify outcome
```

Use `list_pages` to obtain actual page IDs. Current page-scoped tools generally require `pageId`.

Use `take_snapshot` for accessibility-tree structure and element UIDs. Those UIDs come from the current browser state; do not invent or reuse stale ones after the page changes. [Snapshot implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/snapshot.ts)

**Choose the cheapest sufficient observation**

| Question | Preferred evidence |
|---|---|
| Is the button present and named? | Snapshot |
| Is the layout clipped? | Screenshot |
| Which CSS declaration causes clipping? | CSS inspection |
| Did the save request succeed? | Network request plus UI |
| What is the current document title? | Small script evaluation |
| Why was the interaction slow? | Performance trace |

Use form-filling tools to fill several fields together when appropriate. However, separately test typing behavior when it matters—for example, autocomplete, debounced search, or input formatting.

**Wait for outcomes, not arbitrary delays**

A useful wait might target visible confirmation:

```json
{
  "pageId": 7,
  "text": ["Project created"],
  "visible": true,
  "timeout": 10000
}
```

Here, `7` is illustrative; replace it with the observed ID.

Current `wait_for` can match hidden text unless `visible` is true. That matters when a hidden success message already exists in the document. [Current tool reference](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md)

A text match is still only one assertion. Confirm the corresponding state or request when the action is important.

---

**9. Test end to end through meaningful scenarios**

For a small SaaS application, start with a risk-based matrix:

| Scenario | Evidence of success |
|---|---|
| Anonymous visitor opens public page | Correct content and response |
| Member opens private deep link | Correct page or intended login transition |
| User signs in | Correct account and destination |
| User creates a project | Successful request, visible record, persistence after reload |
| User submits invalid data | Useful validation; no false success |
| User edits a record | Updated data remains after revisiting |
| Network request fails | Recoverable error state; entered work preserved where appropriate |
| Member tries admin destination | Server-enforced denial |
| User logs out | Protected data is no longer accessible through normal navigation |
| Empty account opens dashboard | Useful empty state and next action |

**Example: create a project**

Test it in layers:

1. Open the project list.
2. Capture its initial state.
3. Open the creation form.
4. Submit invalid input.
5. Verify validation.
6. Enter valid test data.
7. Submit once.
8. Inspect the relevant request and response.
9. Verify the new record in the UI.
10. Reload and confirm it remains.
11. Clean up the test record if cleanup is authorized.

A success toast alone does not establish that data persisted. A `200` response alone may not establish business success either—some APIs encode errors in their response body.

**Avoid secretly bypassing the behavior**

Calling an internal application function through `evaluate_script` may be useful for setup. It does not prove a person could complete the same action through the interface.

Likewise, programmatically editing a button’s disabled state does not validate the intended flow.

**Authentication reuse needs its own test**

Most functional tests can reuse a session. Maintain separate scenarios for:

- Login.
- Session expiration.
- Logout.
- Password or account recovery.
- Role boundaries.

Otherwise, “auto auth” can eliminate the very failures you need to catch.

---

**10. Inspect network and console evidence selectively**

Start with relevant requests rather than dumping everything.

Example:

```json
{
  "pageId": 7,
  "resourceTypes": ["fetch", "xhr"],
  "pageSize": 20,
  "includePreservedRequests": true
}
```

Then inspect the specific request by its returned `reqid`.

Look for:

| Observation | Investigation |
|---|---|
| Duplicate submissions | Repeated handlers, retries, missing UI guard |
| Save succeeds but UI remains stale | State updates, refetching, cache invalidation |
| Redirect loop | Session acceptance, callback URL, cookie scope |
| Repeated identical requests | Effects, remounts, polling, query configuration |
| Large response for a small view | Overfetching or missing pagination |

The request tools expose headers and bodies, and can save bodies to files. Ask the agent to report relevant facts without echoing session credentials. [Network tools](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/network.ts)

For console investigation:

1. Filter errors, warnings, or issues.
2. Inspect the relevant message.
3. Request its stack only when needed.
4. Separate application defects from extension noise.
5. Reproduce after a clean reload.

A logged error is evidence to investigate, not automatically a blocker.

**Advanced: logpoints**

When source maps are available, logpoints can expose runtime values without editing application files or pausing execution.

Use them to answer a narrow question such as: “Did this submit handler execute twice?” Remove them after the investigation. Avoid logging entire account objects or sensitive payloads.

---

**11. Test failure recovery with controlled network conditions**

Happy-path testing misses many expensive UX defects.

Start with:

- Slow connection.
- Offline transition.
- Failed API request.
- Failed optional third-party widget.
- Delayed images or fonts.
- A session that expires during work.

Current versions expose network-mocking tools when started with:

```text
--categoryNetworkMocks
```

For example, this illustrative mock aborts one staging endpoint:

```json
{
  "pageId": 7,
  "route": "https://staging.example.com/api/projects",
  "abort": true
}
```

Apply it before the action that makes the request. After testing, remove the mock.

Do not assume the tool accepts arbitrary `statusCode`, `delay`, or JSON-response parameters. The current implementation supports specific abort, file-body, and upstream options. For a precise server `500` or timeout scenario, use a supported test-server mechanism or another suitable mocking layer. [Mock implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/network.ts)

**Important measurement consequence:** active mocks disable HTTP caching and intercept requests. Service workers can also affect whether mocks are encountered. Remove mocks before recording a production-like performance baseline.

---

**12. Perform UX audits around tasks and states**

A UX audit should explain where a person encounters confusion, friction, or failure.

Choose a task:

> A first-time visitor evaluates the maintenance service and requests a proposal.

Capture the journey:

```text
Landing page
→ service details
→ enquiry form
→ validation
→ submission
→ confirmation
```

At each step, inspect:

| Dimension | Questions |
|---|---|
| Clarity | Is the purpose understandable? |
| Discoverability | Can the next action be found? |
| Feedback | Does the interface acknowledge action? |
| Recovery | Can the person fix an error? |
| Continuity | Is entered work preserved? |
| Confidence | Are costs, scope, and consequences clear? |
| Mobile usability | Are controls reachable and content readable? |

Use screenshots at meaningful states: initial screen, open menu, form errors, loading, confirmation.

Use viewport screenshots for what the person actually sees. A full-page screenshot is useful for page-wide layout, but can hide the significance of above-the-fold decisions.

**Write findings as observable consequences**

Weak:

> The form UX could be better.

Useful:

> After an invalid submission, the page shows a generic message above the viewport while focus remains on the submit button. The user receives no clear indication of which field needs correction.

Then include reproduction steps, evidence, a proposed change, and a retest.

An agent’s critique is still expert-style evaluation. It does not replace observing representative users attempting the task.

---

**13. Emulate devices and preferences without overclaiming**

A sample mobile stress configuration is:

```json
{
  "pageId": 7,
  "viewport": "390x844x2,mobile,touch",
  "networkConditions": "Slow 4G",
  "cpuThrottlingRate": 4,
  "colorScheme": "light"
}
```

This is a chosen test condition, not an exact model of a particular phone.

Current `emulate` calls replace the other emulation settings, while extra HTTP headers have separate persistence behavior. Pass the complete intended settings each time rather than assuming a later call changes only one field. [Emulation implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/emulation.ts)

Useful variants:

- Narrow viewport.
- Desktop viewport.
- Dark mode.
- Reduced motion.
- Forced colors.
- Slow network.
- Offline.

Change one condition at a time while diagnosing a specific cause.

Browser emulation does not reproduce every aspect of a physical device, browser engine, keyboard, or assistive technology. Finish critical mobile flows on real devices where practical. [Chrome device-mode guidance](https://developer.chrome.com/docs/devtools/device-mode)

---

**14. Accessibility: combine automation, semantics, and interaction**

Use three complementary passes.

**Pass A: automated baseline**

Run `lighthouse_audit` in navigation mode for a page-load baseline:

```json
{
  "pageId": 7,
  "mode": "navigation",
  "device": "mobile"
}
```

Run snapshot mode after opening a dialog or exposing validation:

```json
{
  "pageId": 7,
  "mode": "snapshot",
  "device": "desktop"
}
```

Navigation mode reloads. Snapshot mode analyzes the current state. They are useful for different purposes.

The current implementation saves full reports while returning a smaller summary. Review failed audits and flagged nodes rather than reading the entire report into the conversation. [Lighthouse implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/lighthouse.ts)

**Pass B: semantic inspection**

Use the accessibility snapshot to investigate:

- Landmarks.
- Heading hierarchy.
- Accessible names.
- Form labels.
- Expanded/selected states.
- Dialog roles.
- Whether hidden controls remain exposed.

Compare it with the screenshot. A visually obvious icon may have no accessible name. A visually rearranged page may have an incoherent reading order. [MCP accessibility workflow](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/skills/a11y-debugging/SKILL.md)

**Pass C: keyboard behavior**

Actually use Tab, Shift+Tab, Enter, Space, Escape, and appropriate arrow keys.

For a modal dialog:

1. Open it using the keyboard.
2. Confirm focus moves inside.
3. Confirm its purpose is named.
4. Tab through its controls.
5. Confirm focus stays within the modal.
6. Close it.
7. Confirm focus returns to an appropriate place.

These are established modal-dialog behaviors. [WAI-ARIA dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)

If you inspect `document.activeElement`, use it to identify where focus went. Do not replace keyboard testing with a script that directly focuses the desired control.

**Check appearance and magnification**

- Normal text generally needs 4.5:1 contrast; qualifying large text generally needs 3:1, with specified exceptions. [Contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- WCAG 2.2’s minimum target-size criterion uses 24×24 CSS pixels, with spacing and other exceptions. Treat larger targets as a design choice where appropriate, rather than misquoting the criterion. [Target-size guidance](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)
- Test reflow at narrow equivalent widths and enlarged content. Resizing alone does not test every zoom behavior. [Reflow guidance](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html)
- Check whether sticky headers or banners obscure keyboard focus. [Focus visibility guidance](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html)

A perfect automated score does not establish full accessibility. Include screen-reader testing and human judgment for critical experiences. [W3C evaluation guidance](https://www.w3.org/WAI/test-evaluate/tools/selecting/)

---

**15. Performance: measure page loading separately from interaction**

Use a production build for meaningful performance investigation. Development servers can add debugging work and different loading behavior.

First record the conditions:

```text
Build:
URL:
Authentication role:
Chrome/MCP version:
Viewport:
CPU/network settings:
Cache policy:
Service-worker state:
Mocks:
Extensions:
```

**Page-load trace**

Navigate to the intended page first. Then:

```json
{
  "pageId": 7,
  "reload": true,
  "autoStop": true,
  "ignoreCache": true
}
```

Those are arguments to `performance_start_trace`.

The result supplies insight-set identifiers. Use the returned identifiers when requesting detailed insights—never guess them. [Performance tools](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/performance.ts)

`ignoreCache` bypasses HTTP cache for that reload. It does not recreate every aspect of a first-time visitor: browser storage, service workers, DNS, connections, and server/CDN caching are separate factors.

Test at least:

| Scenario | Purpose |
|---|---|
| Fresh-context direct visit | New visitor |
| Returning visit | Cached/repeat experience |
| Client-side route transition | In-app navigation |
| Slow-device interaction | Responsiveness under stress |

Do not run simultaneous Lighthouse audits, heap snapshots, and multiple traces while comparing timings.

**LCP: investigate the actual delay**

For an image-based LCP, inspect:

- Document response delay.
- Resource discovery delay.
- Resource transfer duration.
- Delay before rendering.

For example, a small image may still appear late because JavaScript discovers it late or an animation hides it.

Use the LCP-related insights returned by the trace, then inspect implicated requests and source. Avoid treating suggested percentage allocations as universal budgets. [LCP debugging skill](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/skills/debug-optimize-lcp/SKILL.md), [LCP optimization guidance](https://web.dev/articles/optimize-lcp)

**Interaction trace**

For a slow project filter:

1. Reach the relevant state.
2. Start tracing without reload or automatic stopping.
3. Perform the interaction through the UI.
4. Wait for the visible result.
5. Stop tracing.
6. Investigate the work around that interaction.

Illustrative start:

```json
{
  "pageId": 7,
  "reload": false,
  "autoStop": false
}
```

INP concerns responsiveness to interactions; it is not simply “how long the API request took.” An interface can acknowledge an action promptly while the final result loads. A single lab interaction also does not establish the site’s field INP distribution. [INP guidance](https://web.dev/articles/inp)

**CLS: inspect the journey after load**

Scroll, open menus, display validation, load embeds, and change tabs. Look for unexpected movement.

An initial-load trace can miss later shifts. Common causes include unreserved media space, injected content, and font/layout changes. [CLS guidance](https://web.dev/articles/optimize-cls)

**Retest without chasing noise**

Repeat comparable runs and report a median or range. If differences are small relative to variability, gather more evidence before claiming improvement.

Field Core Web Vitals still need actual visitor data. Local traces diagnose mechanisms; they do not immediately establish a field pass or a ranking improvement. [Google’s Core Web Vitals guidance](https://developers.google.com/search/docs/appearance/core-web-vitals)

---

**16. SEO: compare the delivered document with the rendered page**

Use an anonymous environment for public-page checks. A signed-in account can hide a login dependency or change what the server returns.

For each representative route:

1. Navigate directly.
2. Inspect the document request and response.
3. Check status and redirect behavior.
4. Compare delivered content with rendered content.
5. Inspect title, description, canonical, robots directives, links, and JSON-LD.
6. Follow internal links.
7. Reload deep routes.
8. Request a nonexistent URL.

A script evaluation of `document.documentElement.outerHTML` returns the **current DOM**, not the original server response.

Use the captured document response for the latter. Re-fetching through page JavaScript makes another request with its own context and is not necessarily evidence of what the original navigation received.

A compact rendered-page inventory can be passed to `evaluate_script` as its function source:

```js
() => ({
  url: location.href,
  title: document.title,
  description:
    document.querySelector('meta[name="description"]')?.content ?? null,
  canonical:
    document.querySelector('link[rel="canonical"]')?.href ?? null,
  robots: Array.from(
    document.querySelectorAll('meta[name="robots"]'),
    element => element.content
  ),
  h1: Array.from(
    document.querySelectorAll("h1"),
    element => element.textContent.trim()
  ),
  jsonLdBlocks:
    document.querySelectorAll('script[type="application/ld+json"]').length,
  internalLinkCount: Array.from(
    document.querySelectorAll("a[href]")
  ).filter(link => link.origin === location.origin).length
})
```

This is an inventory, not an SEO verdict. One JSON-LD block can be invalid; a canonical can point to the wrong destination.

Google can render JavaScript, but a local Chrome session does not prove what Google crawled or indexed. Use Search Console for that evidence. [Google’s JavaScript SEO guidance](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)

**High-value checks by framework**

| Framework | Investigate first |
|---|---|
| HTML | Documents, links, images, response configuration |
| React–Vite | Raw vs rendered content, deep routes, route-specific metadata |
| Next.js | Direct navigation vs client navigation, metadata, caching, hydration |
| Astro | Generated routes, collection links, client-only content, image delivery |

A Googlebot user-agent override does not turn Chrome into Googlebot. Use it only to investigate server behavior differences, with that limitation explicit.

---

**17. Advanced investigations that are worth the extra effort**

**Memory growth in long sessions**

Use this when the app slows after repeated navigation or opening and closing heavy views.

1. Enable supported memory debugging tools.
2. Capture a baseline.
3. Repeat the same interaction cycle.
4. Return to the starting state.
5. Capture again.
6. Compare retained objects.
7. Follow retaining paths to the likely cause.

A larger heap alone does not prove a leak. Legitimate caches can grow. Avoid loading raw heap files into the model; use summary and comparison tools. [Memory-debugging workflow](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/skills/memory-leak-debugging/SKILL.md)

**Passkey/WebAuthn testing**

Current versions offer virtual-authenticator tooling behind the relevant category flag. This can test your application’s registration and authentication behavior with test credentials.

It does not unlock an existing account or reproduce every physical authenticator. Configure it before the application invokes credential APIs. [WebAuthn tool implementation](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/src/tools/webauthn.ts)

**Selected DevTools evidence**

When you manually select a problematic element or request, supported tools can use that selection as context. This is useful when you already know where the failure is and want the agent to investigate it, rather than rediscovering the whole flow. [Live debugging collaboration](https://developer.chrome.com/blog/chrome-devtools-mcp-debug-your-browser-session)

---

**18. Reduce token cost, time, and misleading findings**

This is where you get the greatest return.

| Expensive habit | Better approach |
|---|---|
| Screenshot after every click | Snapshot for structure; screenshot meaningful visual states |
| Dump the whole DOM | Return a small, task-specific object |
| Read every network body | Filter, then inspect a particular request |
| Paste full trace JSON | Save the trace and request relevant insights |
| Audit every URL deeply | Start with representative templates |
| Rerun every test after every change | Retest affected behavior, then a small regression set |
| Keep adding debug tools | Enable specialized categories when needed |
| Let several agents drive the same page | Assign exclusive control of the page or separate instances |
| Use the agent for every future regression | Convert stable scenarios into executable tests |

The project itself emphasizes compact semantic output and storing large artifacts in files. [Design principles](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/design-principles.md)

**Use tiered coverage**

For a small client site:

- Check every route cheaply for availability and basic metadata.
- Deep-audit each distinct template.
- Thoroughly test the primary conversion flow.
- Test shared navigation and forms.
- Investigate performance where measurements identify problems.

For a larger app, prioritize high-frequency tasks, high-consequence actions, and recently changed components.

**Use MCP for exploration; preserve discoveries as tests**

Once the agent has discovered a reproducible bug, ask it to produce a durable test with explicit assertions.

Playwright Test is a useful companion for repeatable runs, isolated state, and cross-browser coverage. Authentication-state reuse there is a separate mechanism from Chrome MCP profiles. [Playwright testing practices](https://playwright.dev/docs/best-practices), [authentication-state documentation](https://playwright.dev/docs/auth)

Chrome-only success does not establish Safari or Firefox compatibility.

---

**19. Save evidence that supports a review**

A useful audit folder might contain:

```text
audit-run/
  manifest.json
  scenarios.md
  findings.md
  screenshots/
  network/
  traces/
  lighthouse/
```

Record the build, environment, account role, browser version, conditions, and test scope.

For each finding, include:

```text
Expected:
Observed:
Reproduction:
Affected route/component:
Evidence:
User consequence:
Suggested fix:
Retest result:
```

Classify results as:

- **Passed**
- **Failed**
- **Blocked**
- **Not tested**

“Could not access the admin account” is blocked coverage, not a passed admin test.

Save screenshots you actually inspected. Confirm they show the intended state before using them as evidence.

For private routes, note that performance tooling may send trace URLs to CrUX unless disabled. The documented `--no-performance-crux` option disables that lookup. Network-header redaction and telemetry controls are also available; choose settings appropriate to the client’s data. [Server configuration](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/configuration.md)

---

**20. Two reusable advanced prompts**

Use this for a functional, UX, and accessibility pass:

Test the specified user journey with Chrome DevTools MCP.

Begin by confirming the environment, account role, browser context, and page IDs. Observe the initial state before changing it.

Cover:
- Successful completion.
- Invalid input.
- Empty and loading states.
- Recoverable request failure.
- Reload and back/forward behavior.
- Keyboard operation.
- Narrow viewport.
- Relevant role/session boundaries.

Use current snapshots to target controls. Verify important outcomes through both UI state and relevant network evidence. Do not use script evaluation to bypass the interaction being tested.

Capture and inspect screenshots at meaningful states. Run automated accessibility checks on the initial page and relevant dynamic states, then test keyboard behavior separately.

Report confirmed defects, UX hypotheses, coverage gaps, and suggested fixes separately. Include reproduction steps, user consequences, evidence, and retest instructions.

Use this for performance and technical SEO:

Investigate performance and technical SEO using Chrome DevTools MCP.

Establish the production build, representative routes, anonymous/authenticated state, viewport, network/CPU conditions, cache policy, service-worker state, and active mocks.

For performance:
- Remove unintended mocks and measurement contamination.
- Record comparable page-load traces.
- Trace important interactions separately.
- Use returned insight IDs to investigate the observed bottleneck.
- Connect findings to requests, rendering work, or source code.
- Retest under equivalent conditions.
- Distinguish lab observations from field Core Web Vitals.

For SEO:
- Inspect direct document responses and rendered content separately.
- Check public access, statuses, redirects, metadata, canonicals, indexing directives, links, and structured-data presence.
- Test deep-route reloads and a nonexistent route.
- Do not infer indexing or rankings from a local browser result.

Use the Lighthouse audit tool for its supported non-performance categories. Save detailed artifacts, return compact findings, and prioritize the smallest changes with the clearest user impact.

For your own projects, I would make persistent test authentication convenient, keep anonymous testing easy, and require evidence for every reported defect. Then use deep traces and specialized tools only where the initial investigation shows they are needed.
