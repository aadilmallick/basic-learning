# Measurement and economics workbook

[Course home](../README.md)

All practice figures below are fictional. Use them to learn calculations, then replace the assumptions with your own verified costs and observations.

## 1. Unit-economics worksheet

| Input | Example | Your amount and source |
| --- | --- | --- |
| Product price before applicable tax | $39 |  |
| Payment/platform costs per order | $3 |  |
| Expected refund cost per order | $2 |  |
| Variable support cost per order | $4 |  |
| Contribution before acquisition | $30 |  |
| Cash acquisition cost per new buyer | $20 |  |
| Contribution after acquisition | $10 |  |
| Fixed cash creation/setup costs | $600 |  |
| Creation hours and value per hour | 60 × $30 |  |

**Formula:** contribution before acquisition = price − payment/platform costs − expected refund cost − variable support cost.

**Formula:** contribution after acquisition = contribution before acquisition − acquisition cost per order, when the order/customer definition matches.

**Formula:** simplified break-even orders = fixed costs ÷ contribution after acquisition. Round up when the result is not an integer. If contribution is zero or negative, increasing order volume does not recover the fixed costs under those assumptions.

Do not count refunds twice. If you model realized net sales after refunds, adjust the allowance line accordingly. Do not count taxes collected for remittance as unrestricted product revenue. Determine actual tax obligations for your selling arrangement separately.

## 2. Paid-click planning

- Contribution before acquisition:
- Desired contribution remaining after acquisition:
- Allowable CAC = contribution before acquisition − desired remainder:
- Assumed click-to-purchase rate as a decimal:
- Maximum click cost = allowable CAC × assumed purchase rate:
- Cash test budget cap:
- What would make the test inconclusive:

**Worked example:** $30 contribution − $10 desired remainder = $20 allowable CAC. At a hypothetical 2% purchase rate, $20 × 0.02 = $0.40 allowable cost per click. If purchase rate is 1%, the allowance is $0.20. Neither rate is a prediction.

## 3. Fictional campaign practice dataset

Assumptions: each order is from one new customer; all orders are for the same $39 guide; expected variable costs are $9 per order; each source contains distinct orders for this exercise; the reporting window and refund allowance are consistent. Creator time is recorded separately and not included in cash spend.

| Campaign | Product-page visits | New customers/orders | Cash acquisition spend | Creator hours |
| --- | --- | --- | --- | --- |
| Organic technical posts | 500 | 10 | $0 | 12 |
| Newsletter placement | 600 | 12 | $180 | 3 |
| Search-ad test | 400 | 8 | $300 | 4 |
| Social-ad test | 1,000 | 12 | $240 | 5 |

### Worked answer

| Campaign | Purchase rate | Gross sales | Cash CAC | Gross-sales/spend ratio | Contribution after cash acquisition |
| --- | --- | --- | --- | --- | --- |
| Organic technical posts | 2.0% | $390 | $0 | Undefined: zero denominator | $300 |
| Newsletter placement | 2.0% | $468 | $15 | 2.60 | $180 |
| Search-ad test | 2.0% | $312 | $37.50 | 1.04 | −$60 |
| Social-ad test | 1.2% | $468 | $20 | 1.95 | $120 |

The ratio is commonly called ROAS for advertising spend. This table uses the same revenue/spend calculation for a placement and labels it explicitly. Zero cash spend does not make organic work costless.

At an illustrative value of $25 per creator hour, subtract $300, $75, $100, and $125 respectively. The remaining amounts are $0, $105, −$160, and −$5 before any fixed costs not already included. These time-adjusted figures are a planning view, not accounting profit. The exercise shows why both cash and time matter.

A higher revenue/spend ratio is not enough to choose a channel. Consider scale, uncertainty, support, audience fit, and delayed outcomes. Do not claim that the fictional newsletter result predicts a real newsletter's performance.

## 4. Metric definitions

| Metric | Numerator | Denominator | Window | Unit and caveat |
| --- | --- | --- | --- | --- |
| Sample request rate |  |  |  |  |
| Confirmed subscription rate |  |  |  |  |
| Purchase rate |  |  |  |  |
| New-customer CAC |  |  |  |  |
| Refund rate |  |  |  |  |
| First-use rate |  |  |  |  |

Use matching units. State whether refunds are measured by orders, customers, or money. A partial refund changes those differently.

## 5. Event plan

| Event | Exact trigger | Source of truth | Fields actually needed | Deduplication | Privacy/consent question | How to verify |
| --- | --- | --- | --- | --- | --- | --- |
| Confirmed subscription |  |  |  |  |  |  |
| Confirmed purchase |  |  |  |  |  |  |
| Refund |  |  |  |  |  |  |
| Appropriate first use |  |  |  |  |  |  |

Never place private data in campaign links. Test purchase reporting against payment records and distinguish a browser visit from a confirmed order.

## 6. Campaign register

| Destination | Source | Medium | Campaign | Content | Publication location | Owner/date | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |

Example naming: `linkedin`, `organic_social`, `guide_pilot`, `cancellation_demo`. Use consistent lowercase labels. Do not add external acquisition labels to internal site links.

## 7. Experiment brief

- Decision this test will support:
- Evidence motivating the hypothesis:
- Hypothesis and mechanism:
- Audience and eligibility:
- Control and variant:
- Assignment method:
- Primary outcome and unit:
- Guardrails, such as refunds or delivery failures:
- Budget/time constraints:
- Analysis and stopping plan:
- Conditions that make the result inconclusive:
- Important possible confounders:

A before-and-after comparison is not randomized. A result based on one extra purchase is not automatically a reliable winner. Record these limits before interpreting the numbers.

## 8. Weekly decision note

**Period and cohort:**

**What happened:** [Numbers with definitions and customer accounts.]

**What we can infer:** [Supported conclusion.]

**What remains uncertain:** [Missing observations or competing explanations.]

**Action:** [One specific improvement or test.]

**Follow-up condition/date:**

## 9. Paid-distribution test brief

- Relevant audience and their situation:
- Why this channel may fit:
- Offer version and destination:
- Creative and factual evidence:
- Contribution assumptions:
- Budget cap and who controls spending:
- Purchase/refund measurement window:
- Required current platform checks:
- Privacy, disclosure, and applicable policy implementation:
- Technical stop conditions:
- Financial stop/continue rule and uncertainty:

A written brief authorizes no spending by itself. Use your actual account controls and decisions when implementing.
