# Conciseness Techniques

Practical editing techniques for maximum word count reduction.

## BLUF Application

### Detecting Context-First Writing

**Pattern:** The first sentence contains "has been", "over the years", "in recent times", a definition, or historical context. The actual point appears in the last 1-2 sentences.

**Transformation process:**
1. Find the last sentence of the paragraph — that's usually the point
2. Move it to the front
3. Cut or condense the context that followed
4. Ask: does the reader need the context at all?

**Example:**
> Over the past several releases, we've been working on improving the performance of our database queries. The team conducted extensive benchmarking and identified several bottlenecks in our ORM layer. After evaluating multiple approaches, we decided to implement query caching with Redis.

**BLUF rewrite:**
> We added Redis query caching to fix ORM bottleneck. Benchmarks showed 3x improvement on the slowest endpoints.

## Filler Deletion

| Filler Phrase | Replacement |
|---------------|-------------|
| It's important to note that | *(delete)* |
| It's worth mentioning that | *(delete)* |
| It should be noted that | *(delete)* |
| As a matter of fact | *(delete)* |
| For all intents and purposes | *(delete)* |
| At the end of the day | *(delete)* |
| It goes without saying | *(delete)* |
| As previously mentioned | *(delete)* |
| Let's take a moment to | *(delete)* |
| In this section, we will | *(delete)* |
| First and foremost | First |
| In order to | To |
| Due to the fact that | Because |
| In the event that | If |
| At this point in time | Now |
| On a regular basis | Regularly |
| In a timely manner | Quickly *(or specific time)* |
| A large number of | Many *(or specific count)* |
| In the vast majority of cases | Usually |
| With the exception of | Except |
| In close proximity to | Near |
| Has the capability to | Can |
| During the course of | During |

## Word Replacement Tables

### Verb Simplification

| Verbose | Direct |
|---------|--------|
| utilize | use |
| facilitate | help |
| implement | build, add, create |
| leverage | use, apply |
| optimize | speed up, improve |
| architect | design, build |
| operationalize | run, deploy |
| instantiate | create |
| decommission | remove, shut down |
| componentize | split |
| incentivize | encourage |
| ideate | brainstorm |
| onboard | set up, train |
| sunset | remove, end |

### Adjective Simplification

| Verbose | Direct |
|---------|--------|
| comprehensive | full, complete |
| robust | strong, reliable, tested |
| scalable | *(specify: "handles 10K rps")* |
| performant | fast |
| seamless | smooth |
| innovative | new |
| cutting-edge | new, latest |
| enterprise-grade | production-ready |
| mission-critical | required, essential |
| world-class | *(delete or use specific metric)* |

### Phrase Simplification

| Verbose | Direct |
|---------|--------|
| a wide range of | many |
| in terms of | for, about |
| with regard to | about |
| on the basis of | based on |
| for the purpose of | to, for |
| in the process of | *(delete — use present tense)* |
| with the goal of | to |
| in conjunction with | with |
| in accordance with | per, following |
| in the context of | in, for |
| from the perspective of | for |
| serves as a mechanism for | *(use direct verb)* |

## Nominalization Reversal

| Nominalization | Active Form |
|---------------|-------------|
| make a decision | decide |
| perform an analysis | analyze |
| conduct an investigation | investigate |
| provide assistance | help |
| give consideration to | consider |
| come to a conclusion | conclude |
| make an improvement | improve |
| carry out an assessment | assess |
| reach an agreement | agree |
| take action | act |
| have a discussion | discuss |
| do an evaluation | evaluate |
| effect a transformation | transform |
| achieve a reduction | reduce |
| make a modification | change |

**Detection pattern:** Look for "make/perform/conduct/provide/give/carry out/reach/take/have/do" + "a/an" + noun. The noun is almost always a hidden verb.

## Active Voice Conversion

### Detection

Passive voice: **[form of "to be"] + [past participle]**

**Quick test:** Insert "by zombies" after the past participle. If grammatically correct, it's passive.

> "The request was processed [by zombies]." — Passive.
> "The server processed the request [by zombies]." — Not passive.

### Conversion

1. Find the actor (often in a "by" phrase, or implied)
2. Make the actor the subject
3. Make the past participle an active verb

| Passive | Active |
|---------|--------|
| The config is loaded by the server at startup | The server loads config at startup |
| Errors are logged to CloudWatch | The app logs errors to CloudWatch |
| The migration was run by the deploy script | The deploy script runs the migration |
| Tests should be written before implementation | Write tests before implementing |

### When Passive is Acceptable

- Actor is unknown: "The database was corrupted overnight"
- Actor is irrelevant: "Logs are rotated every 24 hours"
- Recipient matters more: "Three users were affected by the outage"

Target: under 20% of total sentences.

## Sentence Splitting

Split any sentence that exceeds 25 words, contains "and" connecting independent clauses, or has nested parentheticals.

**Split at "and":**
> The system validates the token and checks permissions and logs the access attempt.
>
> The system validates the token and checks permissions. It logs each access attempt.

**Split at "which":**
> The cache layer stores responses in Redis, which reduces database load by 60% during peak traffic.
>
> The cache layer stores responses in Redis. This reduces database load by 60% during peak traffic.

## 30-50% Reduction Checklist

Apply in order — highest savings first:

1. **Delete filler phrases** — 10-15% savings
2. **Apply BLUF** — 5-10% savings
3. **Replace verbose words** — 3-5% savings
4. **Reverse nominalizations** — 3-5% savings
5. **Activate passive sentences** — 2-4% savings
6. **Split and trim long sentences** — 3-5% savings
7. **Merge short related points** — 2-3% savings
8. **Convert prose to structured format** — 5-15% savings

Stop when you hit the 30-50% target. Over-editing beyond 50% risks losing necessary detail.
